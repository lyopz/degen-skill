-- scan.luau — find malicious/suspicious scripts in an inserted model (run with execute_luau)
-- Set TARGET to the model (e.g. game.ServerStorage.StoreQuarantine.EggSystem).
-- Prints each script with flags, then CLEAN or the number of flagged scripts.
local TARGET = game:GetService("ServerStorage"):FindFirstChild("StoreQuarantine")

local PATTERNS = {
	{ "require%s*%(%s*%d", "require(number) - remote code" },
	{ "require%s*%(%s*tonumber", "require(tonumber) - remote code" },
	{ "loadstring", "loadstring" },
	{ "getfenv", "getfenv" },
	{ "setfenv", "setfenv" },
	{ "string%.reverse", "string.reverse (hiding code)" },
	{ "\\%d%d%d\\%d%d%d\\%d%d%d", "escaped bytes (obfuscated)" },
	{ "\\x%x%x\\x%x%x", "hex escapes (obfuscated)" },
	{ "HttpService", "HttpService" },
	{ "PostAsync", "PostAsync (sends data out)" },
	{ "GetAsync%s*%(%s*[\"']http", "GetAsync to a website" },
	{ "TeleportService", "TeleportService" },
	{ "MarketplaceService", "MarketplaceService (check IDs)" },
	{ "InsertService", "InsertService (loads more assets)" },
	{ ":Kick%s*%(", "Kick" },
	{ "BanAsync", "BanAsync" },
	{ "_G%.", "_G use" },
}
local SUSPECT_PARENTS = { Humanoid = true, HumanoidDescription = true, Configuration = true, Sound = true, Decal = true, Texture = true, MeshPart = false }
local SUSPECT_NAMES = { "fix", "anti", "vaccine", "lag", "thumbnail", "virus", "backdoor", "admin", "loader", "core", "ss" }

if not TARGET then
	print("TARGET not found")
	return
end

local flagged, total = 0, 0
for _, inst in ipairs(TARGET:GetDescendants()) do
	if inst:IsA("LuaSourceContainer") then
		total += 1
		local flags = {}
		local ok, src = pcall(function() return inst.Source end)
		src = ok and src or ""
		for _, p in ipairs(PATTERNS) do
			if string.find(src, p[1]) then table.insert(flags, p[2]) end
		end
		if inst.Parent and SUSPECT_PARENTS[inst.Parent.ClassName] then
			table.insert(flags, "hidden under " .. inst.Parent.ClassName)
		end
		local lower = string.lower(inst.Name)
		for _, n in ipairs(SUSPECT_NAMES) do
			if lower == n or string.find(lower, "^" .. n) then
				table.insert(flags, "suspicious name")
				break
			end
		end
		local lines = select(2, string.gsub(src, "\n", "\n")) + 1
		for word in string.gmatch(src, "%S+") do
			if #word > 200 then table.insert(flags, "very long blob (200+ chars)") break end
		end
		if lines <= 3 and #src > 300 then table.insert(flags, "huge one-liner") end
		print(string.format("%s %s (%s, %d lines)%s", #flags > 0 and "[!]" or "[ ]", inst:GetFullName(), inst.ClassName, lines,
			#flags > 0 and (" -> " .. table.concat(flags, ", ")) or ""))
		if #flags > 0 then flagged += 1 end
	end
end
if total == 0 then
	print("CLEAN (no scripts)")
elseif flagged == 0 then
	print(string.format("CLEAN (%d scripts, read them before using)", total))
else
	print(string.format("%d of %d scripts flagged - read and remove before use", flagged, total))
end
