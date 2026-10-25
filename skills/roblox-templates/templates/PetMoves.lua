-- PetMoves.lua — procedural attack moves for pets and creatures with no rig (ModuleScript in ReplicatedStorage, CLIENT only).
-- version: 1
-- changelog: v1 2026-10-25 first version (Tackle, Slam, Spin, Beam, Shoot, Swoop, Combo, Hurt; hit-stop, cues, pop scale)
-- Works on anchored/PivotTo pets (modular part pets, store models) because it only moves the model's pivot.
-- Each move = a list of keys {t, reach, back, lift, tilt, spin, pop, face, ease, hit, cue}. Timing follows
-- anticipation -> strike -> recovery (fighting-game frame data stretched ~1.5-2x so it reads on phones), see
-- roblox-art-style/references/pet-movement.md "Attack moves". Add your own moves to PetMoves.Moves.
-- Usage (LocalScript; the SERVER decides damage and tells clients "pet X used move Y on target Z"):
--   local PetMoves = require(game.ReplicatedStorage.PetMoves)
--   followConn:Disconnect()                                    -- pause your follow loop (e.g. Motion.Follow)
--   PetMoves.Play(pet, "Tackle", {
--       target = enemyModel,                                   -- Model, BasePart or Vector3 (live-tracked)
--       rarity = "Legendary",                                  -- scales hit-stop (rarer = heavier hits)
--       onHit = function(i, pos, key) VFX.Burst(pos); VFX.Shake(key.shake or 0.3)
--           PetMoves.Hurt(enemyModel, pet:GetPivot().Position, 1) end,
--       onCue = function(name, pos) if name == "beam" then --[[start Beam]] end end,
--       onDone = function() followConn = Motion.Follow(pet, player, offset) end,
--   })
--   Already have a per-frame follow loop? Call PetMoves.Play(pet, move, {target=..., manual=true}) and in your loop
--   use `PetMoves.Step(pet, followCF)` instead of `pet:PivotTo(followCF)` (it adds the attack on top).
-- Hit-stop freezes only this pet's move clock (visual only); freeze emitters yourself in onHit if wanted.
-- Uniform pop only (Model:ScaleTo); fake stretch with tilt. Cosmetic: never decide hits or damage here.

local RunService = game:GetService("RunService")

local PetMoves = {}

-- Hit-stop multiplier per rarity (same names as PetFX / pets-and-eggs.md)
PetMoves.RarityHitStop = { Common = 0.8, Uncommon = 0.9, Rare = 1, Epic = 1.15, Legendary = 1.3, Mythic = 1.5, Secret = 1.7 }

-- reach: 0 = home, 1 = touching the target (stops `stop` studs short). back/lift in studs (x opts.power).
-- tilt: degrees nose-down (negative = lean back). spin: degrees about up. pop: uniform scale. face: 0 = keep own
-- facing, 1 = face the target. hit: hit-stop seconds (fires onHit). cue: name passed to onCue. shake: for your onHit.
local K = function(t) return t end
PetMoves.Moves = {
	Tackle = { -- quick lunge: crouch back, dash, bounce back
		K{ t = 0, face = 0 },
		K{ t = 0.18, back = 1.2, tilt = -12, pop = 0.92, ease = "out" },
		K{ t = 0.26, reach = 1, tilt = 15, pop = 1.08, ease = "in", hit = 0.1, shake = 0.35 },
		K{ t = 0.38, reach = 0.8, lift = 0.6, tilt = -5, ease = "out" },
		K{ t = 0.62, face = 0, ease = "back" },
	},
	Slam = { -- jump up over the target, drop, squash, bounce
		K{ t = 0, face = 0 },
		K{ t = 0.3, reach = 0.9, lift = 5, tilt = -10, pop = 1.05, ease = "out" },
		K{ t = 0.4, reach = 1, lift = 0, tilt = 20, pop = 0.88, ease = "in", hit = 0.22, cue = "shockwave", shake = 0.8 },
		K{ t = 0.55, reach = 0.95, lift = 1, pop = 1.04, ease = "out" },
		K{ t = 0.88, face = 0, ease = "inout" },
	},
	Spin = { -- twist back, then a 3-hit spin into the target
		K{ t = 0, face = 0 },
		K{ t = 0.15, back = 0.5, spin = -40, pop = 0.95, ease = "out" },
		K{ t = 0.3, reach = 1, spin = 360, ease = "linear", hit = 0.05, shake = 0.2 },
		K{ t = 0.45, reach = 1, spin = 720, ease = "linear", hit = 0.05, shake = 0.2 },
		K{ t = 0.6, reach = 1, spin = 1080, pop = 1.06, ease = "linear", hit = 0.12, shake = 0.45 },
		K{ t = 0.85, reach = 0.4, spin = 1100, ease = "out" },
		K{ t = 1.05, face = 0, spin = 1080, ease = "back" },
	},
	Beam = { -- gather (glow grows), recoil while the beam holds, settle. VFX via cues: charge / beam / beamEnd
		K{ t = 0, face = 0, cue = "charge" },
		K{ t = 0.6, back = 1.4, lift = 1, tilt = -8, pop = 1.1, ease = "inout" },
		K{ t = 0.66, back = 2.2, lift = 1, tilt = 6, pop = 0.95, ease = "out", hit = 0.13, cue = "beam", shake = 0.4 },
		K{ t = 1.15, back = 2, lift = 1, tilt = 4, pop = 1, ease = "linear", cue = "beamEnd" },
		K{ t = 1.45, face = 0, ease = "inout" },
	},
	Shoot = { -- rear back and spit a projectile (your projectile code does the hit)
		K{ t = 0, face = 0 },
		K{ t = 0.2, back = 1, tilt = -15, pop = 0.94, ease = "out" },
		K{ t = 0.28, back = 0.3, tilt = 10, pop = 1.06, ease = "in", cue = "fire" },
		K{ t = 0.52, face = 0, ease = "back" },
	},
	Swoop = { -- rise above, dive diagonally, arc back up (flyers)
		K{ t = 0, face = 0 },
		K{ t = 0.3, back = 1.5, lift = 6, tilt = -15, ease = "out" },
		K{ t = 0.42, reach = 1, lift = 0.5, tilt = 35, pop = 1.05, ease = "in", hit = 0.15, cue = "slash", shake = 0.5 },
		K{ t = 0.75, reach = 0.6, lift = 4, tilt = -20, ease = "out" },
		K{ t = 1.0, face = 0, ease = "inout" },
	},
	Combo = { -- jab, jab, pause, big finisher (short, short, long hit-stop)
		K{ t = 0, face = 0 },
		K{ t = 0.1, back = 0.6, pop = 0.95, ease = "out" },
		K{ t = 0.18, reach = 1, tilt = 10, ease = "in", hit = 0.05, shake = 0.15 },
		K{ t = 0.26, reach = 0.75, ease = "out" },
		K{ t = 0.34, reach = 1, tilt = 10, ease = "in", hit = 0.05, shake = 0.15 },
		K{ t = 0.42, reach = 0.7, ease = "out" },
		K{ t = 0.57, reach = 0.55, back = 0.8, lift = 1, tilt = -15, pop = 0.92, ease = "inout" },
		K{ t = 0.67, reach = 1, tilt = 22, pop = 1.12, ease = "in", hit = 0.2, cue = "finisher", shake = 0.7 },
		K{ t = 0.97, face = 0, ease = "back" },
	},
	Hurt = { -- victim: flinch away from the attacker (target = attacker position), wobble back
		K{ t = 0, face = 1 },
		K{ t = 0.06, back = 2.5, lift = 0.6, tilt = -22, pop = 0.9, ease = "out" },
		K{ t = 0.3, back = 1.5, tilt = 8, pop = 1.03, ease = "out" },
		K{ t = 0.55, face = 0, ease = "back" },
	},
}

local EASE = {
	linear = function(a) return a end,
	["in"] = function(a) return a * a end,
	out = function(a) return 1 - (1 - a) * (1 - a) end,
	inout = function(a) return a < 0.5 and 2 * a * a or 1 - (-2 * a + 2) ^ 2 / 2 end,
	back = function(a) local c = 1.70158; return 1 + (c + 1) * (a - 1) ^ 3 + c * (a - 1) ^ 2 end,
}
local FIELDS = { reach = 0, back = 0, lift = 0, tilt = 0, spin = 0, pop = 1, face = 1 }

local active = setmetatable({}, { __mode = "k" }) -- model -> state

local function targetPos(target)
	local tt = typeof(target)
	if tt == "Vector3" then return target end
	if tt == "Instance" and target.Parent then
		return target:IsA("Model") and target:GetPivot().Position or target:IsA("BasePart") and target.Position or nil
	end
	return nil
end

local function sample(keys, t)
	local last = keys[#keys]
	if t >= last.t then return last end
	for i = 2, #keys do
		local b = keys[i]
		if t < b.t then
			local a = keys[i - 1]
			local f = (EASE[b.ease or "inout"] or EASE.inout)((t - a.t) / math.max(b.t - a.t, 1e-4))
			local out = {}
			for k, d in pairs(FIELDS) do
				local va, vb = a[k] or d, b[k] or d
				out[k] = va + (vb - va) * f
			end
			return out
		end
	end
	return keys[1]
end

local function value(s, k) local v = s[k]; if v == nil then return FIELDS[k] end; return v end

-- Advance the move clock (once per frame), fire cues/hits, return the sampled pose or nil when done.
local function advance(model, st)
	local now = os.clock()
	if st.freezeEnd then
		if now < st.freezeEnd then return sample(st.keys, st.freezeAt) end
		st.pauseAccum += st.freezeLen
		st.freezeEnd = nil
	end
	local eff = now - st.start - st.pauseAccum
	for i = st.nextKey, #st.keys do
		local key = st.keys[i]
		if eff < key.t then break end
		st.nextKey = i + 1
		local pos = model:GetPivot().Position
		if key.cue and st.opts.onCue then task.spawn(st.opts.onCue, key.cue, pos, key) end
		if key.hit then
			st.hits += 1
			if st.opts.onHit then task.spawn(st.opts.onHit, st.hits, targetPos(st.opts.target) or pos, key) end
			local len = key.hit * (st.opts.hitStopScale or PetMoves.RarityHitStop[st.opts.rarity or "Rare"] or 1)
			st.pauseAccum += eff - key.t -- snap back to the hit frame
			st.freezeAt, st.freezeLen, st.freezeEnd = key.t, len, now + len
			return sample(st.keys, key.t)
		end
	end
	if eff >= st.keys[#st.keys].t then return nil end
	return sample(st.keys, eff)
end

local function finish(model, st)
	active[model] = nil
	if st.conn then st.conn:Disconnect() end
	if model.Parent and math.abs(model:GetScale() - st.baseScale) > 1e-4 then model:ScaleTo(st.baseScale) end
	if st.opts.onDone then task.spawn(st.opts.onDone) end
end

-- Pose the model: baseCF = where it would be without the attack (follow slot / home). Returns true while attacking.
function PetMoves.Step(model, baseCF)
	local st = active[model]
	if not st then model:PivotTo(baseCF); return false end
	if not model:IsDescendantOf(workspace) then finish(model, st); return false end
	local s = advance(model, st)
	if not s then model:PivotTo(baseCF); finish(model, st); return false end
	local power = st.opts.power or 1
	local basePos = baseCF.Position
	local tp = targetPos(st.opts.target) or st.lastTarget or (basePos + baseCF.LookVector * 6)
	st.lastTarget = tp
	local flat = Vector3.new(tp.X - basePos.X, 0, tp.Z - basePos.Z)
	local dist = flat.Magnitude
	local dir = dist > 1e-3 and flat / dist or Vector3.new(baseCF.LookVector.X, 0, baseCF.LookVector.Z).Unit
	local travel = math.max(dist - (st.opts.stop or 2.5), 0)
	local pos = basePos + dir * (value(s, "reach") * travel - value(s, "back") * power) + Vector3.yAxis * (value(s, "lift") * power)
	local baseRot = baseCF - baseCF.Position
	local lookRot = CFrame.lookAt(Vector3.zero, dir)
	local rot = baseRot:Lerp(lookRot, math.clamp(value(s, "face"), 0, 1))
	model:PivotTo(CFrame.new(pos) * rot * CFrame.Angles(-math.rad(value(s, "tilt")), 0, 0) * CFrame.Angles(0, math.rad(value(s, "spin")), 0))
	local scale = st.baseScale * value(s, "pop")
	if math.abs(model:GetScale() - scale) > 0.003 then model:ScaleTo(scale) end
	return true
end

-- Start a move. opts: target, rarity | hitStopScale, power, stop (studs), onHit(i, pos, key), onCue(name, pos, key),
-- onDone(), manual (true = you call Step from your own loop), base (CFrame or function -> CFrame; default = pivot now).
function PetMoves.Play(model, moveName, opts)
	opts = opts or {}
	local keys = PetMoves.Moves[moveName]
	assert(keys, "PetMoves: unknown move " .. tostring(moveName))
	local old = active[model]
	if old then finish(model, old) end
	local st = { keys = keys, opts = opts, start = os.clock(), pauseAccum = 0, nextKey = 1, hits = 0, baseScale = model:GetScale() }
	active[model] = st
	if not opts.manual then
		local home = model:GetPivot()
		st.conn = RunService.RenderStepped:Connect(function()
			local base = opts.base
			local cf = typeof(base) == "function" and base() or typeof(base) == "CFrame" and base or home
			PetMoves.Step(model, cf)
		end)
	end
	return { Stop = function() if active[model] == st then finish(model, st) end end }
end

-- Victim flinch: power ~1 normal, 2 = big knockback.
function PetMoves.Hurt(model, fromPos, power, opts)
	opts = opts or {}
	opts.target, opts.power = fromPos, power or 1
	return PetMoves.Play(model, "Hurt", opts)
end

function PetMoves.IsBusy(model) return active[model] ~= nil end

function PetMoves.Duration(moveName)
	local keys = PetMoves.Moves[moveName]
	local hs = 0
	for _, k in ipairs(keys) do hs += k.hit or 0 end
	return keys[#keys].t + hs
end

return PetMoves
