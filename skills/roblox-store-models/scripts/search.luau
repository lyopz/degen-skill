-- search.luau — list free Creator Store models from Studio (run with execute_luau)
-- Set QUERY and PAGES. Prints: assetId | name | creator
local QUERY = "egg hatch system"
local PAGES = 2

local InsertService = game:GetService("InsertService")
local seen = 0
for page = 0, PAGES - 1 do
	local ok, result = pcall(function()
		return InsertService:GetFreeModels(QUERY, page)
	end)
	if not ok then
		print("search failed: " .. tostring(result))
		break
	end
	local results = result[1] and result[1].Results or {}
	for _, item in ipairs(results) do
		seen += 1
		print(string.format("%d | %s | %s", item.AssetId, item.Name, tostring(item.CreatorName)))
	end
	if #results == 0 then break end
end
print(string.format("%d results for %q", seen, QUERY))
