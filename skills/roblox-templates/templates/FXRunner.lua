-- FXRunner (Build-A-Pet Scrap set v2, 2026-10-27; from ScrapKit.Runner) - a self-cleaning clock for one effect.
-- Own timeline (pausable for freeze-frame screenshots via Workspace attr FXFreeze), timers, per-frame steppers,
-- an impact hook, and a watchdog that cleans up even if the caller never does (no leftover folders).
-- Usage:
--   local FXRunner = require(path.FXRunner)
--   local R = FXRunner.new({ Name = "GearCrusher", Folder = workspace, StartTime = os.clock(),
--       Stages = { Anticipation = .22, AttackMovement = .14, Impact = .08, Recovery = .30, IdleTransition = .14 },
--       ImpactTime = os.clock() + .36, OnImpact = someBindableEvent.Event })   -- OnImpact optional
--   R:At(0.1, function() ... end)          -- at t seconds on the effect clock
--   R:Every(function(dt, t) ... return t < 1 end)  -- return false to stop
--   R:Impact(function() ... end)           -- on OnImpact, or ImpactTime + 0.08 as fallback
--   R:Own(highlightOutsideFolder)          -- destroyed at cleanup too
--   return function() R:Cleanup() end      -- caller cleanup; watchdog fires 3 s after the last stage anyway
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ORDER = { "Anticipation", "AttackMovement", "Impact", "Recovery", "IdleTransition" }

local Runner = {}
Runner.__index = Runner

local FXRunner = {}

function FXRunner.new(opts)
	local start = opts.StartTime or os.clock()
	local folder = Instance.new("Folder")
	folder.Name = "FX_" .. tostring(opts.Name or "Effect")
	folder.Archivable = false
	folder.Parent = opts.Folder or Workspace
	local R = setmetatable({
		opts = opts, Folder = folder, dead = false, t = os.clock() - start,
		timers = {}, steppers = {}, conns = {}, extra = {}, impactFns = {}, impactDone = false,
	}, Runner)
	R.ImpactT = (opts.ImpactTime or (start + 0.55)) - start
	local endT = R:Stage("IdleTransition") + ((opts.Stages or {}).IdleTransition or 0.2)
	table.insert(R.conns, RunService.Heartbeat:Connect(function(dt)
		if R.dead or Workspace:GetAttribute("FXFreeze") then return end
		R.t += math.min(dt, 1 / 15)
		local i = 1
		while i <= #R.timers do
			local tm = R.timers[i]
			if R.t >= tm[1] then
				table.remove(R.timers, i)
				local ok, err = pcall(tm[2])
				if not ok then warn("[FXRunner] timer: " .. tostring(err)) end
			else
				i += 1
			end
		end
		for k = #R.steppers, 1, -1 do
			local ok, res = pcall(R.steppers[k], dt, R.t)
			if not ok then warn("[FXRunner] step: " .. tostring(res)) end
			if not ok or res == false then table.remove(R.steppers, k) end
		end
		if not R.impactDone and (R.impactSignal or R.t >= R.ImpactT + 0.08) then R:_fireImpact() end
		if R.t > endT + 3 then R:Cleanup() end -- watchdog
	end))
	if opts.OnImpact and opts.OnImpact.Connect then
		table.insert(R.conns, opts.OnImpact:Connect(function() R.impactSignal = true end))
	end
	return R
end

function Runner:_fireImpact()
	if self.impactDone or self.dead then return end
	self.impactDone = true
	self.t = math.max(self.t, self.ImpactT)
	for _, fn in ipairs(self.impactFns) do
		local ok, err = pcall(fn)
		if not ok then warn("[FXRunner] impact: " .. tostring(err)) end
	end
end

function Runner:At(t: number, fn) table.insert(self.timers, { t, fn }) end
function Runner:After(dt: number, fn) table.insert(self.timers, { self.t + dt, fn }) end
function Runner:Every(fn) table.insert(self.steppers, fn) end
function Runner:Impact(fn) table.insert(self.impactFns, fn) end
function Runner:Own(inst: Instance): Instance table.insert(self.extra, inst) return inst end

-- start time of a stage, relative to StartTime
function Runner:Stage(name: string): number
	local s, t = self.opts.Stages or {}, 0
	for _, n in ipairs(ORDER) do
		if n == name then return t end
		t += s[n] or 0
	end
	return t
end

function Runner:Cleanup()
	if self.dead then return end
	self.dead = true
	for _, c in ipairs(self.conns) do pcall(function() c:Disconnect() end) end
	for _, x in ipairs(self.extra) do pcall(function() x:Destroy() end) end
	self.Folder:Destroy()
end

return FXRunner
