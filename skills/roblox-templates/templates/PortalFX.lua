-- PortalFX.lua — animated themed portals: spinning swirl, swirling particles, falling code rain, glow pulse.
-- version: 1
-- changelog: v1 2026-10-24 first version (Swirl, SwirlParticles, CodeRain, CodeCurtain, GlowPulse, client Animate)
-- ModuleScript in ReplicatedStorage. Build* functions run anywhere (server or Studio edit, via execute_luau) and only
-- create instances + CollectionService tags. PortalFX.Animate() runs on the CLIENT (one LocalScript) and moves
-- everything tagged, only while the camera is near (cheap on phones). No textures needed: built-in particle textures
-- and Text for the code rain. Pass your own texture ids in opts to match the game's style.
-- Usage (server / edit time):
--   local PortalFX = require(game.ReplicatedStorage.PortalFX)
--   PortalFX.Swirl(portal.PortalFill, {Color = Color3.fromRGB(80,255,120)})          -- fill = thin part in the opening
--   PortalFX.SwirlParticles(portal.PortalFill, {Color = Color3.fromRGB(80,255,120)})
--   PortalFX.CodeRain(pillar.Screen, Enum.NormalId.Front, {Columns = 8})              -- falling glyphs on a face
--   PortalFX.CodeCurtain(CFrame.new(0,10,0), Vector3.new(8,16,0.2), {})               -- free-standing code beam
--   PortalFX.GlowPulse(portal.Gem, {Period = 3})                                      -- Neon part / light breathes
-- Usage (client, one LocalScript):  require(game.ReplicatedStorage.PortalFX).Animate()

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local PortalFX = {}

PortalFX.TEX = {
	Swirl = "rbxasset://textures/particles/forcefield_vortex_main.dds",
	Glow = "rbxasset://textures/particles/forcefield_glow_main.dds",
	Spark = "rbxasset://textures/particles/sparkles_main.dds",
}
PortalFX.GLYPHS = { "0", "1", "0", "1", "7", "3", "9", "Z", "X", "V", "K", "=", "+", "<", ">", "*", ":", "|" }
PortalFX.CULL = 160 -- studs: nothing animates beyond this

local function opt(o, k, d)
	if o and o[k] ~= nil then
		return o[k]
	end
	return d
end

-- Spinning swirl: two layered decals-in-a-SurfaceGui per side, counter-rotating, additive look.
function PortalFX.Swirl(fill, o)
	local color = opt(o, "Color", Color3.fromRGB(80, 255, 120))
	local tex = opt(o, "Texture", PortalFX.TEX.Swirl)
	fill.Transparency = 1
	fill.CanCollide = false
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = Instance.new("SurfaceGui")
		gui.Name = "PortalSwirl_" .. face.Name
		gui.Face = face
		gui.LightInfluence = 0
		gui.Brightness = opt(o, "Brightness", 1.6)
		gui.PixelsPerStud = 40
		gui.ZOffset = 1
		gui.Parent = fill
		for i, spec in ipairs({ { 1.15, 0.15, 1 }, { 0.85, 0.35, -1.6 } }) do
			local img = Instance.new("ImageLabel")
			img.Name = "Layer" .. i
			img.BackgroundTransparency = 1
			img.AnchorPoint = Vector2.new(0.5, 0.5)
			img.Position = UDim2.fromScale(0.5, 0.5)
			img.Size = UDim2.fromScale(spec[1], spec[1])
			img.SizeConstraint = Enum.SizeConstraint.RelativeYY
			img.Image = tex
			img.ImageColor3 = color
			img.ImageTransparency = spec[2]
			img:SetAttribute("SpinSpeed", spec[3] * opt(o, "Speed", 60)) -- degrees per second
			img.Parent = gui
			CollectionService:AddTag(img, "PortalFX_Spin")
		end
	end
	return fill
end

-- Particles that spiral into the middle: an emitter on an attachment the client orbits around the rim.
function PortalFX.SwirlParticles(fill, o)
	local color = opt(o, "Color", Color3.fromRGB(80, 255, 120))
	local radius = opt(o, "Radius", math.min(fill.Size.X, fill.Size.Y) * 0.42)
	for i = 1, opt(o, "Arms", 2) do
		local a = Instance.new("Attachment")
		a.Name = "SwirlArm" .. i
		a:SetAttribute("Radius", radius)
		a:SetAttribute("Phase", (i - 1) / opt(o, "Arms", 2) * math.pi * 2)
		a:SetAttribute("Speed", opt(o, "Speed", 2.2)) -- radians per second
		a.Parent = fill
		CollectionService:AddTag(a, "PortalFX_Orbit")
		local p = Instance.new("ParticleEmitter")
		p.Texture = opt(o, "Texture", PortalFX.TEX.Spark)
		p.Color = ColorSequence.new(color)
		p.LightEmission = 1
		p.LightInfluence = 0
		p.Rate = opt(o, "Rate", 18)
		p.Lifetime = NumberRange.new(0.8, 1.4)
		p.Speed = NumberRange.new(0.5, 1.5)
		p.SpreadAngle = Vector2.new(20, 20)
		p.Drag = 2
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0) })
		p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
		p.LockedToPart = false -- leaves a spiral trail as the attachment orbits
		p.Parent = a
	end
	return fill
end

-- Falling code on one face of a part (a screen, a pillar side, a floor strip).
function PortalFX.CodeRain(part, face, o)
	local color = opt(o, "Color", Color3.fromRGB(70, 255, 110))
	local gui = Instance.new("SurfaceGui")
	gui.Name = "CodeRain_" .. face.Name
	gui.Face = face
	gui.LightInfluence = 0
	gui.Brightness = opt(o, "Brightness", 1.4)
	gui.PixelsPerStud = 30
	gui.ClipsDescendants = true
	gui.Parent = part
	local cols = opt(o, "Columns", 8)
	local rows = opt(o, "Rows", 14)
	for c = 1, cols do
		local col = Instance.new("TextLabel")
		col.Name = "Col" .. c
		col.BackgroundTransparency = 1
		col.Size = UDim2.fromScale(1 / cols, 1.2)
		col.Position = UDim2.fromScale((c - 1) / cols, -1.2 + math.random())
		col.Font = Enum.Font.Code
		col.TextScaled = true
		col.RichText = true
		col.TextColor3 = color
		col.TextTransparency = opt(o, "Transparency", 0.1)
		col.TextYAlignment = Enum.TextYAlignment.Bottom
		col:SetAttribute("Rows", rows)
		col:SetAttribute("FallSpeed", 0.25 + math.random() * 0.35) -- screen heights per second
		col.Parent = gui
		CollectionService:AddTag(col, "PortalFX_Rain")
	end
	return gui
end

-- Free-standing see-through code beam (both sides), e.g. columns of falling code around a portal.
function PortalFX.CodeCurtain(cf, size, o)
	local p = Instance.new("Part")
	p.Name = opt(o, "Name", "CodeCurtain")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = size
	p.CFrame = cf
	PortalFX.CodeRain(p, Enum.NormalId.Front, o)
	PortalFX.CodeRain(p, Enum.NormalId.Back, o)
	p.Parent = opt(o, "Parent", workspace)
	return p
end

-- Slow breathing glow on a Neon part (or any part with a PointLight/SurfaceLight inside).
function PortalFX.GlowPulse(part, o)
	part:SetAttribute("PulsePeriod", opt(o, "Period", 3))
	part:SetAttribute("PulseMin", opt(o, "Min", 0.35)) -- fraction of the base brightness
	CollectionService:AddTag(part, "PortalFX_Pulse")
	return part
end

-- ---------------------------------------------------------------- client
local function randomColumn(rows)
	local t = {}
	for r = 1, rows do
		local g = PortalFX.GLYPHS[math.random(#PortalFX.GLYPHS)]
		if r == rows then
			g = '<font color="#E8FFE8">' .. g .. "</font>" -- bright head at the bottom of the stream
		end
		t[r] = g
	end
	return table.concat(t, "\n")
end

local function near(inst, cam)
	local base = inst:FindFirstAncestorWhichIsA("BasePart")
	if not base then
		return false
	end
	return (base.Position - cam.CFrame.Position).Magnitude < PortalFX.CULL
end

function PortalFX.Animate()
	assert(RunService:IsClient(), "PortalFX.Animate runs on the client")
	local base = {}
	local t0 = os.clock()
	local last = t0
	local nearCache, nextCheck = {}, 0
	RunService.RenderStepped:Connect(function()
		local now = os.clock()
		local dt = now - last
		last = now
		local t = now - t0
		local cam = workspace.CurrentCamera
		local check = now > nextCheck
		if check then
			nextCheck = now + 0.5
		end
		local function isNear(inst)
			if check or nearCache[inst] == nil then
				nearCache[inst] = near(inst, cam)
			end
			return nearCache[inst]
		end
		for _, img in ipairs(CollectionService:GetTagged("PortalFX_Spin")) do
			if isNear(img) then
				img.Rotation = (img.Rotation + img:GetAttribute("SpinSpeed") * dt) % 360
			end
		end
		for _, a in ipairs(CollectionService:GetTagged("PortalFX_Orbit")) do
			if isNear(a) then
				local ang = a:GetAttribute("Phase") + t * a:GetAttribute("Speed")
				local r = a:GetAttribute("Radius") * (0.55 + 0.45 * math.abs(math.sin(t * 0.7)))
				a.Position = Vector3.new(math.cos(ang) * r, math.sin(ang) * r, 0)
			end
		end
		for _, col in ipairs(CollectionService:GetTagged("PortalFX_Rain")) do
			if isNear(col) then
				local y = col.Position.Y.Scale + col:GetAttribute("FallSpeed") * dt
				if y > 1 or col.Text == "" then
					y = -1.2
					col.Text = randomColumn(col:GetAttribute("Rows"))
					col:SetAttribute("FallSpeed", 0.25 + math.random() * 0.35)
				end
				col.Position = UDim2.fromScale(col.Position.X.Scale, y)
			end
		end
		for _, p in ipairs(CollectionService:GetTagged("PortalFX_Pulse")) do
			if isNear(p) then
				local k = p:GetAttribute("PulseMin")
				local s = k + (1 - k) * (0.5 + 0.5 * math.sin(t * math.pi * 2 / p:GetAttribute("PulsePeriod")))
				for _, l in ipairs(p:GetDescendants()) do
					if l:IsA("Light") then
						base[l] = base[l] or l.Brightness
						l.Brightness = base[l] * s
					end
				end
				base[p] = base[p] or p.Transparency
				p.Transparency = base[p] + (1 - s) * 0.35
			end
		end
	end)
end

return PortalFX
