-- DevContentGuard (Script, put in ServerScriptService) — version: 1
-- Keeps dev-only stages (test labs, preview stands, debug tools) out of live games.
-- On LIVE servers (not RunService:IsStudio()) it destroys everything tagged "DevOnly" at startup, and anything
-- tagged later. In Studio (Edit, Play-in-Studio, local servers) nothing is touched, so the stages keep working.
-- Usage: tag each dev root with CollectionService tag "DevOnly" (Tag Editor, or CollectionService:AddTag(root, "DevOnly")).
-- Tags are lost when a stage is deleted and rebuilt: re-tag in your build code. Dev-only LocalScripts should
-- check RunService:IsStudio() first and return before any WaitForChild on dev content.
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local TAG = "DevOnly"

if RunService:IsStudio() then return end

local removed = {}
for _, inst in ipairs(CollectionService:GetTagged(TAG)) do
	if inst.Parent ~= nil then
		table.insert(removed, inst:GetFullName())
		pcall(function() inst:Destroy() end)
	end
end

CollectionService:GetInstanceAddedSignal(TAG):Connect(function(inst)
	task.defer(function()
		if inst.Parent ~= nil then pcall(function() inst:Destroy() end) end
	end)
end)

print(("[DevContentGuard] stripped %d dev-only root(s): %s"):format(#removed, table.concat(removed, ", ")))
