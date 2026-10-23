-- motion.lua — scripted movement for Roblox models that don't need a rig (ModuleScript).
-- version: 1
-- changelog: v1 2026-10-23 first version
-- local Motion = require(game.ReplicatedStorage.Motion)
-- Motion.Spin(coin, 90)            -- degrees per second
-- Motion.Bob(pickup, 0.6, 1.5)     -- height (studs), seconds per cycle
-- Motion.Follow(pet, player, Vector3.new(3, 1, 3))
-- Motion.Waddle(model, 6)          -- cheap "walking" wobble for simple creatures moving between points

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Motion = {}

local function pivotOf(m) return m:IsA("Model") and m:GetPivot() or m.CFrame end
local function setPivot(m, cf) if m:IsA("Model") then m:PivotTo(cf) else m.CFrame = cf end end

function Motion.Spin(obj, degPerSec)
	local base = pivotOf(obj)
	local a = 0
	return RunService.Heartbeat:Connect(function(dt)
		a += math.rad(degPerSec or 90) * dt
		setPivot(obj, base * CFrame.Angles(0, a, 0))
	end)
end

function Motion.Bob(obj, height, period)
	local base = pivotOf(obj); local t = 0
	return RunService.Heartbeat:Connect(function(dt)
		t += dt
		setPivot(obj, base + Vector3.new(0, math.sin(t / (period or 1.5) * math.pi * 2) * (height or 0.5), 0))
	end)
end

-- Smooth pet follow (run on the client for the owner, or server for everyone)
function Motion.Follow(obj, player, offset)
	offset = offset or Vector3.new(3, 0, 3)
	local t = 0
	return RunService.Heartbeat:Connect(function(dt)
		local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		t += dt
		local target = hrp.CFrame * CFrame.new(offset) * CFrame.new(0, math.sin(t * 4) * 0.25, 0)
		local cur = pivotOf(obj)
		setPivot(obj, cur:Lerp(target, math.clamp(dt * 8, 0, 1)))
	end)
end

-- Move between points with a body waddle (fake walk for simple creatures, no animation needed)
function Motion.Waddle(model, speed, points)
	speed = speed or 6
	task.spawn(function()
		local i = 1
		while model.Parent do
			local from = pivotOf(model); local to = points[i]
			local dist = (to - from.Position).Magnitude
			local t, dur = 0, dist / speed
			while t < dur and model.Parent do
				t += RunService.Heartbeat:Wait()
				local p = math.clamp(t / dur, 0, 1)
				local pos = from.Position:Lerp(to, p)
				local sway = math.sin(t * speed * 2) * 0.12
				local hop = math.abs(math.sin(t * speed * 2)) * 0.25
				setPivot(model, CFrame.lookAt(pos, Vector3.new(to.X, pos.Y, to.Z)) * CFrame.new(0, hop, 0) * CFrame.Angles(0, 0, sway))
			end
			i = i % #points + 1
		end
	end)
end

-- Satisfying pickup: scale pop + fly up + fade (use on coins/orbs when collected)
function Motion.Collect(part)
	local info = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(part, info, { Size = part.Size * 1.6, CFrame = part.CFrame + Vector3.new(0, 3, 0), Transparency = 1 }):Play()
	game:GetService("Debris"):AddItem(part, 0.4)
end

return Motion
