local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local UILibrary = {}
local tabCount = 0

if CoreGui:FindFirstChild("UILibrary") then
	return
end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UILibrary"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui
ScreenGui.Enabled = false

local ModalButton = Instance.new("TextButton")
ModalButton.BackgroundTransparency = 1
ModalButton.Size = UDim2.new(0, 0, 0, 0)
ModalButton.Text = ""
ModalButton.Modal = false
ModalButton.Parent = ScreenGui

BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 10
BlurEffect.Enabled = false
BlurEffect.Parent = game.Lighting

UIS.InputBegan:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
		BlurEffect.Enabled = ScreenGui.Enabled
		ModalButton.Modal = ScreenGui.Enabled
	end
end)

function UILibrary:CreateTab(tabName)
	local Tab = Instance.new("Frame")
	Tab.Name = "Tab"
	Tab.Parent = screenGui
	Tab.BackgroundTransparency = 1
	Tab.Position = UDim2.new(0, 15 + tabCount * 260, 0, 15)
	Tab.Size = UDim2.new(0, 250, 0, 0)
	Tab.AutomaticSize = Enum.AutomaticSize.Y
	Tab.BorderSizePixel = 0
	Tab.BorderColor3 = Color3.new(0, 0, 0)
	tabCount += 1

	local TabHeader = Instance.new("TextButton")
	TabHeader.Name = "TabHeader"
	TabHeader.Parent = Tab
	TabHeader.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TabHeader.BackgroundTransparency = 0.25
	TabHeader.BorderSizePixel = 0
	TabHeader.BorderColor3 = Color3.new(0, 0, 0)
	TabHeader.Size = UDim2.new(0, 250, 0, 50)
	TabHeader.AutoButtonColor = false
	TabHeader.Font = Enum.Font.Sarpanch
	TabHeader.Text = tabName or "Tab"
	TabHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabHeader.TextSize = 25
	TabHeader.TextXAlignment = Enum.TextXAlignment.Left

	local headerPadding = Instance.new("UIPadding", TabHeader)
	headerPadding.PaddingLeft = UDim.new(0, 25)

	local Cheats = Instance.new("Frame")
	Cheats.Name = "Cheats"
	Cheats.Parent = Tab
	Cheats.BackgroundTransparency = 1
	Cheats.BorderSizePixel = 0
	Cheats.BorderColor3 = Color3.new(0, 0, 0)
	Cheats.Position = UDim2.new(0, 0, 0, 50)
	Cheats.Size = UDim2.new(0, 250, 0, 0)
	Cheats.Visible = false
	Cheats.AutomaticSize = Enum.AutomaticSize.Y

	local layout = Instance.new("UIListLayout", Cheats)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 0)

	TabHeader.MouseButton2Click:Connect(function()
		Cheats.Visible = not Cheats.Visible
	end)

	local tabObj = {}

	function tabObj:AddToggle(toggleName, callback)
		local ToggleContainer = Instance.new("Frame")
		ToggleContainer.Name = "ToggleContainer"
		ToggleContainer.Parent = Cheats
		ToggleContainer.BackgroundTransparency = 1
		ToggleContainer.BorderSizePixel = 0
		ToggleContainer.BorderColor3 = Color3.new(0, 0, 0)
		ToggleContainer.Size = UDim2.new(1, 0, 0, 0)
		ToggleContainer.AutomaticSize = Enum.AutomaticSize.Y

		local toggleLayout = Instance.new("UIListLayout", ToggleContainer)
		toggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
		toggleLayout.Padding = UDim.new(0, 0)

		local Cheat = Instance.new("TextButton")
		Cheat.Name = "Cheat"
		Cheat.Parent = ToggleContainer
		Cheat.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Cheat.BackgroundTransparency = 0.5
		Cheat.BorderSizePixel = 0
		Cheat.BorderColor3 = Color3.new(0, 0, 0)
		Cheat.Size = UDim2.new(1, 0, 0, 50)
		Cheat.AutoButtonColor = false
		Cheat.Font = Enum.Font.Sarpanch
		Cheat.Text = toggleName or "Toggle"
		Cheat.TextColor3 = Color3.fromRGB(255, 255, 255)
		Cheat.TextSize = 20
		Cheat.TextTransparency = 0.5
		Cheat.TextXAlignment = Enum.TextXAlignment.Left

		local cheatPadding = Instance.new("UIPadding", Cheat)
		cheatPadding.PaddingLeft = UDim.new(0, 25)

		local CheatFeatures = Instance.new("Frame")
		CheatFeatures.Name = "CheatFeatures"
		CheatFeatures.Parent = ToggleContainer
		CheatFeatures.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		CheatFeatures.BackgroundTransparency = 0.25
		CheatFeatures.BorderSizePixel = 0
		CheatFeatures.BorderColor3 = Color3.new(0, 0, 0)
		CheatFeatures.Size = UDim2.new(1, 0, 0, 0)
		CheatFeatures.Visible = false
		CheatFeatures.AutomaticSize = Enum.AutomaticSize.Y
		CheatFeatures.ClipsDescendants = true

		local featuresLayout = Instance.new("UIListLayout", CheatFeatures)
		featuresLayout.SortOrder = Enum.SortOrder.LayoutOrder
		featuresLayout.Padding = UDim.new(0, 5)

		local Bind = Instance.new("TextButton")
		Bind.Name = "Bind"
		Bind.Parent = CheatFeatures
		Bind.BackgroundTransparency = 1
		Bind.BorderSizePixel = 0
		Bind.BorderColor3 = Color3.new(0, 0, 0)
		Bind.Size = UDim2.new(1, 0, 0, 25)
		Bind.Font = Enum.Font.Sarpanch
		Bind.Text = "Bind: None"
		Bind.TextColor3 = Color3.fromRGB(255, 255, 255)
		Bind.TextSize = 15
		Bind.TextXAlignment = Enum.TextXAlignment.Left

		local bindPadding = Instance.new("UIPadding", Bind)
		bindPadding.PaddingLeft = UDim.new(0, 25)

		local enabled = false
		local currentBind = nil
		local binding = false
		local skipNext = false

		Cheat.MouseButton1Click:Connect(function()
			enabled = not enabled
			Cheat.TextTransparency = enabled and 0 or 0.5
			if callback then callback(enabled) end
		end)

		Cheat.MouseButton2Click:Connect(function()
			CheatFeatures.Visible = not CheatFeatures.Visible
		end)

		Bind.MouseButton1Click:Connect(function()
			if binding then return end
			binding = true
			Bind.Text = "Press Key"

			local conn
			conn = UIS.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.Keyboard then
					if currentBind == Input.KeyCode then
						currentBind = nil
						Bind.Text = "Bind Removed"
						task.delay(1, function()
							Bind.Text = "Bind: None"
						end)
						skipNext = true
					else
						currentBind = Input.KeyCode
						Bind.Text = "Bind: " .. Input.KeyCode.Name
						skipNext = true
					end
					conn:Disconnect()
					binding = false
				end
			end)
		end)

		UIS.InputBegan:Connect(function(Input)
			if currentBind == Input.KeyCode then
				if skipNext then
					skipNext = false
					return
				end
				enabled = not enabled
				Cheat.TextTransparency = enabled and 0 or 0.5
				if callback then callback(enabled) end
			end
		end)
	end

	return tabObj
end
