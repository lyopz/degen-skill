-- ConfirmToken.lua — preview → confirm → commit for item machines (fuse, craft, upgrade, enchant, trade-in).
-- version: 1
-- use: ModuleScript in ServerScriptService (server only). Put the RULES in a pure shared module so the
--      client can show the same preview offline; this module makes the real action safe:
--      * Preview returns a one-use token bound to (player, inputs, choice) that expires (default 120 s).
--      * Commit re-validates on live data, runs your mutation in ONE non-yielding call, and caches the
--        result per token: a repeated/lagged Commit returns the same result and never consumes twice.
--
-- local ConfirmToken = require(game.ServerScriptService.ConfirmToken)
-- local Fuse = ConfirmToken.new({
--     name = "Fuse",                 -- creates Remotes/FusePreview + Remotes/FuseCommit (RemoteFunctions)
--     maxInputs = 5,                 -- inputs = array of item id strings from the client
--     preview = function(player, inputs, choice)          -- may read data, must not change it
--         local data = Data.Get(player); if not data then return false, "loading" end
--         return FuseRules.Preview(data, inputs, choice)   -- -> true, previewInfo | false, reason
--     end,
--     commit = function(player, inputs, choice, previewInfo) -- MUST NOT YIELD (no waits, no DataStore calls)
--         local data = Data.Get(player); if not data then return false, "loading" end
--         local ok, why = FuseRules.Preview(data, inputs, choice)  -- re-check: items may be gone now
--         if not ok then return false, why end
--         return true, FuseRules.Apply(data, inputs, choice)       -- remove inputs, add result
--     end,
--     onCommitted = function(player, result) Data.SaveSoon(player, 6) end, -- may yield
-- })
-- Client: local ok, info, token = Remotes.FusePreview:InvokeServer(ids, "tierUp")
--         ...show info + Confirm button...  local ok2, result = Remotes.FuseCommit:InvokeServer(token)
--
-- changelog: v1 2026-10-24 first version (pattern from lyopz's projects: lessons → roblox-dev §2)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ConfirmToken = {}
ConfirmToken.__index = ConfirmToken

local MAX_ID_LEN = 64
local MAX_CHOICE_LEN = 32

local function remotesFolder()
	local f = ReplicatedStorage:FindFirstChild("Remotes")
	if not f then
		f = Instance.new("Folder")
		f.Name = "Remotes"
		f.Parent = ReplicatedStorage
	end
	return f
end

local function makeRemote(name)
	local folder = remotesFolder()
	local r = folder:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteFunction")
		r.Name = name
		r.Parent = folder
	end
	return r
end

local function cleanString(s, maxLen)
	return type(s) == "string" and #s > 0 and #s <= maxLen and utf8.len(s) ~= nil
end

-- inputs: array of unique short strings, 1..maxInputs long. Returns a copy (never keep client tables).
local function cleanInputs(inputs, maxInputs)
	if type(inputs) ~= "table" then return nil end
	local n = #inputs
	if n < 1 or n > maxInputs then return nil end
	local out, seen, count = {}, {}, 0
	for k, v in pairs(inputs) do
		count = count + 1
		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or k > n then return nil end
		if not cleanString(v, MAX_ID_LEN) or seen[v] then return nil end
		seen[v] = true
		out[k] = v
	end
	if count ~= n then return nil end
	return out
end

-- Runs fn without allowing it to yield; a yield would let another request interleave with the mutation.
local function runNoYield(fn, ...)
	local co = coroutine.create(fn)
	local resumed, ok, result = coroutine.resume(co, ...)
	if not resumed then
		warn("[ConfirmToken] commit errored: " .. tostring(ok))
		return false, "error"
	end
	if coroutine.status(co) ~= "dead" then
		coroutine.close(co) -- never let a half-done mutation resume later
		warn("[ConfirmToken] commit yielded — move waits/DataStore calls to onCommitted")
		return false, "error"
	end
	return ok, result
end

function ConfirmToken.new(cfg)
	assert(type(cfg.name) == "string", "name required")
	assert(type(cfg.preview) == "function" and type(cfg.commit) == "function", "preview + commit required")
	local self = setmetatable({}, ConfirmToken)
	self.name = cfg.name
	self.ttl = cfg.ttl or 120
	self.maxInputs = cfg.maxInputs or 8
	self.minGap = cfg.minGap or 0.15 -- seconds between requests per player
	self.cfg = cfg
	self.tokens = {}   -- [player] = { [token] = { inputs, choice, info, expires, done, ok, result } }
	self.last = {}     -- [player] = os.clock() of last request

	local previewRemote = makeRemote(cfg.name .. "Preview")
	local commitRemote = makeRemote(cfg.name .. "Commit")
	previewRemote.OnServerInvoke = function(player, inputs, choice)
		return self:_preview(player, inputs, choice)
	end
	commitRemote.OnServerInvoke = function(player, token)
		return self:_commit(player, token)
	end
	Players.PlayerRemoving:Connect(function(player)
		self.tokens[player] = nil
		self.last[player] = nil
	end)
	return self
end

function ConfirmToken:_throttled(player)
	local now = os.clock()
	local last = self.last[player]
	if last and now - last < self.minGap then return true end
	self.last[player] = now
	return false
end

function ConfirmToken:_prune(player)
	local mine = self.tokens[player]
	if not mine then return end
	local now = os.clock()
	for t, rec in pairs(mine) do
		if rec.expires < now then mine[t] = nil end
	end
end

function ConfirmToken:_preview(player, inputs, choice)
	if self:_throttled(player) then return false, "slow down" end
	local clean = cleanInputs(inputs, self.maxInputs)
	if not clean then return false, "bad request" end
	if choice ~= nil and not cleanString(choice, MAX_CHOICE_LEN) then return false, "bad request" end
	local ok, info = self.cfg.preview(player, clean, choice)
	if not ok then return false, info end
	self:_prune(player)
	local mine = self.tokens[player] or {}
	self.tokens[player] = mine
	local count = 0
	for _ in pairs(mine) do count = count + 1 end
	if count >= 20 then return false, "slow down" end
	local token = HttpService:GenerateGUID(false)
	mine[token] = { inputs = clean, choice = choice, info = info, expires = os.clock() + self.ttl }
	return true, info, token
end

function ConfirmToken:_commit(player, token)
	if not cleanString(token, 40) then return false, "bad request" end
	local mine = self.tokens[player]
	local rec = mine and mine[token]
	if not rec then return false, "expired" end -- unknown, other player's, or pruned
	if rec.done then return rec.ok, rec.result end -- repeat click / retry: same answer, no second consume
	if rec.expires < os.clock() then
		mine[token] = nil
		return false, "expired"
	end
	local ok, result = runNoYield(self.cfg.commit, player, rec.inputs, rec.choice, rec.info)
	rec.done, rec.ok, rec.result = true, ok, result
	rec.expires = os.clock() + self.ttl -- keep the cached answer around for retries
	if ok then
		-- Invalidate every other open preview: they were computed on data that just changed.
		for t, other in pairs(mine) do
			if t ~= token and not other.done then mine[t] = nil end
		end
		if self.cfg.onCommitted then task.spawn(self.cfg.onCommitted, player, result) end
	end
	return ok, result
end

return ConfirmToken
