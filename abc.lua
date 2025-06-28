local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local Jello = {}
local tabCount = 0

if CoreGui:FindFirstChild("Jello") then
	return
end

local ScreenGui = Instance.new("ScreenGui")
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

local BlurEffect = Instance.new("BlurEffect")
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

function Jello:AddTab(tabName)
	local TabFrame = Instance.new("Frame")
	TabFrame.Parent = ScreenGui
	TabFrame.BackgroundTransparency = 1
	TabFrame.Position = UDim2.new(0, 15 + tabCount * 260, 0, 15)
	TabFrame.Size = UDim2.new(0, 250, 0, 0)
	TabFrame.AutomaticSize = Enum.AutomaticSize.Y
	TabFrame.BorderSizePixel = 0
	TabFrame.BorderColor3 = Color3.new(0, 0, 0)
	tabCount += 1

	local TabHeader = Instance.new("TextButton")
	TabHeader.Parent = TabFrame
	TabHeader.BackgroundColor3 = Color3.new(0, 0, 0)
	TabHeader.BackgroundTransparency = 0.25
	TabHeader.BorderSizePixel = 0
	TabHeader.BorderColor3 = Color3.new(0, 0, 0)
	TabHeader.Size = UDim2.new(0, 250, 0, 50)
	TabHeader.AutoButtonColor = false
	TabHeader.Font = Enum.Font.Sarpanch
	TabHeader.Text = tabName or "Tab"
	TabHeader.TextColor3 = Color3.new(1, 1, 1)
	TabHeader.TextSize = 25
	TabHeader.TextXAlignment = Enum.TextXAlignment.Left

	local headerPadding = Instance.new("UIPadding", TabHeader)
	headerPadding.PaddingLeft = UDim.new(0, 25)

	local Toggles = Instance.new("Frame")
	Toggles.Parent = TabFrame
	Toggles.BackgroundTransparency = 1
	Toggles.BorderSizePixel = 0
	Toggles.BorderColor3 = Color3.new(0, 0, 0)
	Toggles.Position = UDim2.new(0, 0, 0, 50)
	Toggles.Size = UDim2.new(0, 250, 0, 0)
	Toggles.Visible = false
	Toggles.AutomaticSize = Enum.AutomaticSize.Y

	local layout = Instance.new("UIListLayout", Toggles)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 0)

	TabHeader.MouseButton2Click:Connect(function()
		Toggles.Visible = not Toggles.Visible
	end)

	local Tab = {}

	function Tab:AddToggle(toggleName, callback)
		local ToggleContainer = Instance.new("Frame")
		ToggleContainer.Parent = Toggles
		ToggleContainer.BackgroundTransparency = 1
		ToggleContainer.BorderSizePixel = 0
		ToggleContainer.BorderColor3 = Color3.new(0, 0, 0)
		ToggleContainer.Size = UDim2.new(1, 0, 0, 0)
		ToggleContainer.AutomaticSize = Enum.AutomaticSize.Y

		local toggleLayout = Instance.new("UIListLayout", ToggleContainer)
		toggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
		toggleLayout.Padding = UDim.new(0, 0)

		local Toggle = Instance.new("TextButton")
		Toggle.Parent = ToggleContainer
		Toggle.BackgroundColor3 = Color3.new(0, 0, 0)
		Toggle.BackgroundTransparency = 0.5
		Toggle.BorderSizePixel = 0
		Toggle.BorderColor3 = Color3.new(0, 0, 0)
		Toggle.Size = UDim2.new(1, 0, 0, 50)
		Toggle.AutoButtonColor = false
		Toggle.Font = Enum.Font.Sarpanch
		Toggle.Text = toggleName or "Toggle"
		Toggle.TextColor3 = Color3.new(1, 1, 1)
		Toggle.TextSize = 20
		Toggle.TextTransparency = 0.5
		Toggle.TextXAlignment = Enum.TextXAlignment.Left

		local cheatPadding = Instance.new("UIPadding", Toggle)
		cheatPadding.PaddingLeft = UDim.new(0, 25)

		local ToggleFeatures = Instance.new("Frame")
		ToggleFeatures.Parent = ToggleContainer
		ToggleFeatures.BackgroundColor3 = Color3.new(0, 0, 0)
		ToggleFeatures.BackgroundTransparency = 0.25
		ToggleFeatures.BorderSizePixel = 0
		ToggleFeatures.BorderColor3 = Color3.new(0, 0, 0)
		ToggleFeatures.Size = UDim2.new(1, 0, 0, 0)
		ToggleFeatures.Visible = false
		ToggleFeatures.AutomaticSize = Enum.AutomaticSize.Y
		ToggleFeatures.ClipsDescendants = true

		local featuresLayout = Instance.new("UIListLayout", ToggleFeatures)
		featuresLayout.SortOrder = Enum.SortOrder.LayoutOrder
		featuresLayout.Padding = UDim.new(0, 5)

		local Bind = Instance.new("TextButton")
		Bind.Parent = ToggleFeatures
		Bind.BackgroundTransparency = 1
		Bind.BorderSizePixel = 0
		Bind.BorderColor3 = Color3.new(0, 0, 0)
		Bind.Size = UDim2.new(1, 0, 0, 25)
		Bind.Font = Enum.Font.Sarpanch
		Bind.Text = "Bind: None"
		Bind.TextColor3 = Color3.new(1, 1, 1)
		Bind.TextSize = 15
		Bind.TextXAlignment = Enum.TextXAlignment.Left

		local bindPadding = Instance.new("UIPadding", Bind)
		bindPadding.PaddingLeft = UDim.new(0, 25)

		local enabled = false
		local currentBind = nil
		local binding = false
		local skipNext = false

		Toggle.MouseButton1Click:Connect(function()
			enabled = not enabled
			Toggle.TextTransparency = enabled and 0 or 0.5
			if callback then callback(enabled) end
		end)

		Toggle.MouseButton2Click:Connect(function()
			ToggleFeatures.Visible = not ToggleFeatures.Visible
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
				Toggle.TextTransparency = enabled and 0 or 0.5
				if callback then callback(enabled) end
			end
		end)
	end

	return Tab
end

return Jello
