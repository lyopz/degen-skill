-- Degen Templates — Roblox Studio plugin (built by make_rbxmx.py; lives in %LOCALAPPDATA%\Roblox\Plugins).
-- Toolbar "Degen Templates" → opens a list of every template; click one to insert it.
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local templates = script:WaitForChild("Templates")

local toolbar = plugin:CreateToolbar("Degen Templates")
local button = toolbar:CreateButton("Templates", "Insert a Degen template", "rbxasset://textures/StudioToolbox/AssetPreview/MoreDetails.png")
button.ClickableWhenViewportHidden = true

local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 280, 420, 220, 260)
local widget = plugin:CreateDockWidgetPluginGui("DegenTemplates", info)
widget.Title = "Degen Templates"

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.fromScale(1, 1); frame.CanvasSize = UDim2.new(); frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
frame.BackgroundColor3 = Color3.fromRGB(11, 11, 13); frame.BorderSizePixel = 0; frame.ScrollBarThickness = 6
frame.Parent = widget
local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 6); list.Parent = frame
local pad = Instance.new("UIPadding"); for _, k in ipairs({"PaddingTop","PaddingBottom","PaddingLeft","PaddingRight"}) do pad[k] = UDim.new(0, 8) end; pad.Parent = frame

local function where(t)
	local sel = Selection:Get()[1]
	if sel then return sel end
	if t:IsA("LocalScript") then return game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterPlayerScripts") end
	if t:IsA("Script") then return game:GetService("ServerScriptService") end
	return game:GetService("ReplicatedStorage")
end

for _, t in ipairs(templates:GetChildren()) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(20, 20, 26); b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.TextXAlignment = Enum.TextXAlignment.Left
	b.Text = "  " .. t.Name .. "  ·  " .. t.ClassName; b.AutoButtonColor = true
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = b
	local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(225, 29, 46); s.Thickness = 1; s.Parent = b
	b.Parent = frame
	b.Activated:Connect(function()
		local rec = ChangeHistoryService:TryBeginRecording("Insert " .. t.Name)
		local copy = t:Clone(); copy.Parent = where(t)
		Selection:Set({ copy })
		if rec then ChangeHistoryService:FinishRecording(rec, Enum.FinishRecordingOperation.Commit) end
		print("[Degen Templates] inserted " .. t.Name .. " into " .. copy.Parent:GetFullName())
	end)
end

button.Click:Connect(function() widget.Enabled = not widget.Enabled end)
