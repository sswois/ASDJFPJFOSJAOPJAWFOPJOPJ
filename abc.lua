local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local Jello = {}
local TabCount = 0

if CoreGui:FindFirstChild("Jello") then
	return
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Jello"
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
BlurEffect.Size = 25
BlurEffect.Enabled = false
BlurEffect.Parent = game.Lighting

-- Notification UI
local Notification = Instance.new("TextLabel")
Notification.Name = "Notification"
Notification.Parent = ScreenGui
Notification.AnchorPoint = Vector2.new(1, 1)
Notification.Position = UDim2.new(1, 300, 1, -20) -- offscreen
Notification.Size = UDim2.new(0, 250, 0, 50)
Notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Notification.BackgroundTransparency = 0.5
Notification.BorderSizePixel = 0
Notification.Text = ""
Notification.TextColor3 = Color3.new(1, 1, 1)
Notification.Font = Enum.Font.Sarpanch
Notification.TextSize = 20
Notification.TextXAlignment = Enum.TextXAlignment.Center
Notification.TextYAlignment = Enum.TextYAlignment.Center
Notification.Visible = false

local NotificationCorner = Instance.new("UICorner")
NotificationCorner.CornerRadius = UDim.new(0, 25)
NotificationCorner.Parent = Notification

-- SendNotification Function
local function SendNotification(message)
	Notification.Text = message
	Notification.Visible = true
	Notification.Position = UDim2.new(1, 300, 1, -20)
	Notification:TweenPosition(UDim2.new(1, -20, 1, -20), "Out", "Quad", 0.4, true)

	task.delay(2, function()
		Notification:TweenPosition(UDim2.new(1, 300, 1, -20), "In", "Quad", 0.4, true)
		task.wait(0.4)
		Notification.Visible = false
	end)
end

-- UI Toggle Key
UIS.InputBegan:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
		BlurEffect.Enabled = ScreenGui.Enabled
		ModalButton.Modal = ScreenGui.Enabled
	end
end)

function Jello:AddTab(TabName)
	local TabFrame = Instance.new("Frame")
	TabFrame.Parent = ScreenGui
	TabFrame.BackgroundTransparency = 1
	TabFrame.Position = UDim2.new(0, 15 + TabCount * 260, 0, 15)
	TabFrame.Size = UDim2.new(0, 250, 0, 0)
	TabFrame.AutomaticSize = Enum.AutomaticSize.Y
	TabFrame.BorderSizePixel = 0
	TabFrame.BorderColor3 = Color3.new(0, 0, 0)
	TabCount += 1

	local Header = Instance.new("TextButton")
	Header.Parent = TabFrame
	Header.BackgroundColor3 = Color3.new(0, 0, 0)
	Header.BackgroundTransparency = 0.25
	Header.BorderSizePixel = 0
	Header.BorderColor3 = Color3.new(0, 0, 0)
	Header.Size = UDim2.new(0, 250, 0, 50)
	Header.AutoButtonColor = false
	Header.Font = Enum.Font.Sarpanch
	Header.Text = TabName or "Tab"
	Header.TextColor3 = Color3.new(1, 1, 1)
	Header.TextSize = 25
	Header.TextXAlignment = Enum.TextXAlignment.Left

	local HeaderPadding = Instance.new("UIPadding", Header)
	HeaderPadding.PaddingLeft = UDim.new(0, 25)

	local Toggles = Instance.new("Frame")
	Toggles.Parent = TabFrame
	Toggles.BackgroundTransparency = 1
	Toggles.BorderSizePixel = 0
	Toggles.BorderColor3 = Color3.new(0, 0, 0)
	Toggles.Position = UDim2.new(0, 0, 0, 50)
	Toggles.Size = UDim2.new(0, 250, 0, 0)
	Toggles.Visible = false
	Toggles.AutomaticSize = Enum.AutomaticSize.Y

	local TogglesListLayout = Instance.new("UIListLayout", Toggles)
	TogglesListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TogglesListLayout.Padding = UDim.new(0, 0)

	Header.MouseButton2Click:Connect(function()
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

		local ToggleContainerListLayout = Instance.new("UIListLayout", ToggleContainer)
		ToggleContainerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ToggleContainerListLayout.Padding = UDim.new(0, 0)

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

		local TogglePadding = Instance.new("UIPadding", Toggle)
		TogglePadding.PaddingLeft = UDim.new(0, 25)

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

		local ToggleFeaturesListLayout = Instance.new("UIListLayout", ToggleFeatures)
		ToggleFeaturesListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ToggleFeaturesListLayout.Padding = UDim.new(0, 5)

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

		local BindPadding = Instance.new("UIPadding", Bind)
		BindPadding.PaddingLeft = UDim.new(0, 25)

		local Enabled = false
		local CurrentBind = nil
		local Binding = false
		local SkipNext = false

		Toggle.MouseButton1Click:Connect(function()
			Enabled = not Enabled
			Toggle.TextTransparency = Enabled and 0 or 0.5
			if callback then
				callback(Enabled)
			end
			SendNotification(toggleName .. (Enabled and " Enabled" or " Disabled"))
		end)

		Toggle.MouseButton2Click:Connect(function()
			ToggleFeatures.Visible = not ToggleFeatures.Visible
		end)

		Bind.MouseButton1Click:Connect(function()
			if Binding then return end
			Binding = true
			Bind.Text = "Press Key"
			local BindConnection
			BindConnection = UIS.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.Keyboard then
					if CurrentBind == Input.KeyCode then
						CurrentBind = nil
						Bind.Text = "Bind Removed"
						SendNotification("Bind removed")
						task.delay(1, function()
							Bind.Text = "Bind: None"
						end)
						SkipNext = true
					else
						CurrentBind = Input.KeyCode
						Bind.Text = "Bind: " .. Input.KeyCode.Name
						SendNotification("Bound to " .. Input.KeyCode.Name)
						SkipNext = true
					end
					BindConnection:Disconnect()
					Binding = false
				end
			end)
		end)

		UIS.InputBegan:Connect(function(Input)
			if CurrentBind == Input.KeyCode then
				if SkipNext then
					SkipNext = false
					return
				end
				Enabled = not Enabled
				Toggle.TextTransparency = Enabled and 0 or 0.5
				if callback then
					callback(Enabled)
				end
				SendNotification(toggleName .. (Enabled and " Enabled (Bind)" or " Disabled (Bind)"))
			end
		end)
	end

	return Tab
end

return Jello
