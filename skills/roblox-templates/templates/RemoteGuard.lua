-- RemoteGuard.lua — validated, rate-limited RemoteEvents/Functions (ModuleScript in ReplicatedStorage; use from server).
-- Rules from Roblox's client-server boundary docs: never trust the client; check types, finite numbers, sizes,
-- instance location, distance; rate-limit per player.
-- local Guard = require(game.ReplicatedStorage.RemoteGuard)
-- Guard.On("BuyItem", { "string" }, { rate = 4, per = 1 }, function(player, itemId)
--     -- server decides price/ownership here
-- end)
-- Guard.OnInvoke("GetShop", {}, { rate = 2, per = 1 }, function(player) return Shop.List end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Guard = {}
local folder = ReplicatedStorage:FindFirstChild("Remotes")
if not folder and RunService:IsServer() then
	folder = Instance.new("Folder"); folder.Name = "Remotes"; folder.Parent = ReplicatedStorage
end

local MAX_STRING = 200
local buckets = {} -- [player][name] = { tokens, last }

local function finite(n) return typeof(n) == "number" and n == n and math.abs(n) ~= math.huge end
local function finiteVec(v) return finite(v.X) and finite(v.Y) and finite(v.Z) end

-- Type spec per argument: "string" | "number" | "integer" | "boolean" | "Vector3" | "Instance" | { class = "BasePart", under = workspace.Shops }
local function check(arg, spec)
	if type(spec) == "table" then
		if typeof(arg) ~= "Instance" or not arg:IsA(spec.class or "Instance") then return false end
		if spec.under and not arg:IsDescendantOf(spec.under) then return false end
		return true
	end
	if spec == "string" then return type(arg) == "string" and utf8.len(arg) ~= nil and #arg <= MAX_STRING end
	if spec == "number" then return finite(arg) end
	if spec == "integer" then return finite(arg) and arg % 1 == 0 end
	if spec == "boolean" then return type(arg) == "boolean" end
	if spec == "Vector3" then return typeof(arg) == "Vector3" and finiteVec(arg) end
	if spec == "Instance" then return typeof(arg) == "Instance" end
	return false
end

local function allowed(player, name, rate, per)
	local pb = buckets[player]; if not pb then pb = {}; buckets[player] = pb end
	local b = pb[name]; local now = os.clock()
	if not b then b = { tokens = rate, last = now }; pb[name] = b end
	b.tokens = math.min(rate, b.tokens + (now - b.last) * rate / per); b.last = now
	if b.tokens < 1 then return false end
	b.tokens -= 1; return true
end
Players.PlayerRemoving:Connect(function(p) buckets[p] = nil end)

local function validate(player, name, specs, opts, ...)
	local n = select("#", ...)
	if n ~= #specs then return false end
	for i = 1, n do if not check(select(i, ...), specs[i]) then return false end end
	if not allowed(player, name, opts.rate or 5, opts.per or 1) then return false end
	if opts.alive then
		local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not h or h.Health <= 0 then return false end
	end
	return true
end

local function get(name, class)
	local r = folder:FindFirstChild(name)
	if not r then r = Instance.new(class); r.Name = name; r.Parent = folder end
	return r
end

function Guard.On(name, specs, opts, handler)
	local remote = get(name, "RemoteEvent")
	remote.OnServerEvent:Connect(function(player, ...)
		if validate(player, name, specs, opts or {}, ...) then
			local ok, err = pcall(handler, player, ...)
			if not ok then warn("[RemoteGuard] " .. name .. ": " .. tostring(err)) end
		end
	end)
	return remote
end

function Guard.OnInvoke(name, specs, opts, handler)
	local remote = get(name, "RemoteFunction")
	remote.OnServerInvoke = function(player, ...)
		if not validate(player, name, specs, opts or {}, ...) then return nil, "rejected" end
		local ok, a, b = pcall(handler, player, ...)
		if not ok then warn("[RemoteGuard] " .. name .. ": " .. tostring(a)); return nil, "error" end
		return a, b
	end
	return remote
end

-- Server-side distance check helper (latency slack included)
function Guard.Near(player, position, maxStuds)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	return hrp ~= nil and (hrp.Position - position).Magnitude <= (maxStuds or 12) + 4
end

-- Client side: Guard.Fire("BuyItem", "sword_1")
function Guard.Fire(name, ...) folder:WaitForChild(name):FireServer(...) end
function Guard.Invoke(name, ...) return folder:WaitForChild(name):InvokeServer(...) end

return Guard
