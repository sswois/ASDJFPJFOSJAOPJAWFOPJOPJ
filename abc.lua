local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Jello = {}
local AllTabs = {}
local TabCount = 0

if CoreGui:FindFirstChild("Jello") then return end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Jello"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local TabsFolder = Instance.new("Folder")
TabsFolder.Parent = ScreenGui

local NotificationsFolder = Instance.new("Folder")
NotificationsFolder.Parent = ScreenGui

local ActiveModulesFolder = Instance.new("Folder")
ActiveModulesFolder.Parent = ScreenGui

local ActiveModulesDisplay = Instance.new("Frame")
ActiveModulesDisplay.Parent = ActiveModulesFolder
ActiveModulesDisplay.AnchorPoint = Vector2.new(1, 0)
ActiveModulesDisplay.BackgroundTransparency = 1
ActiveModulesDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
ActiveModulesDisplay.BorderColor3 = Color3.new(0, 0, 0)
ActiveModulesDisplay.BorderSizePixel = 0
ActiveModulesDisplay.Position = UDim2.new(1, -5, 0, -57.5)
ActiveModulesDisplay.Size = UDim2.new(0, 250, 1, 1000)
ActiveModulesDisplay.ZIndex = 10

local ActiveModulesLayout = Instance.new("UIListLayout")
ActiveModulesLayout.Parent = ActiveModulesDisplay
ActiveModulesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ActiveModulesLayout.Padding = UDim.new(0, 0)
ActiveModulesLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ActiveModules = {}

local TextService = game:GetService("TextService")

local function GetTextWidth(text)
	return TextService:GetTextSize(text, 20, Enum.Font.Sarpanch, Vector2.new(1000, 20)).X
end

local function RefreshActiveModules()
	for _, v in pairs(ActiveModulesDisplay:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end

	table.sort(ActiveModules, function(a, b)
		return GetTextWidth(a) > GetTextWidth(b)
	end)

	for _, ModuleName in ipairs(ActiveModules) do
		local Label = Instance.new("TextLabel")
		Label.Parent = ActiveModulesDisplay
		Label.AnchorPoint = Vector2.new(0, 0)
		Label.BackgroundTransparency = 1
		Label.BackgroundColor3 = Color3.new(0, 0, 0)
		Label.BorderColor3 = Color3.new(0, 0, 0)
		Label.BorderSizePixel = 0
		Label.Position = UDim2.new(0, 0, 0, 0)
		Label.Size = UDim2.new(0, 0, 0, 20)
		Label.AutomaticSize = Enum.AutomaticSize.X
		Label.Font = Enum.Font.Sarpanch
		Label.Text = ModuleName
		Label.TextColor3 = Color3.new(1, 1, 1)
		Label.TextSize = 20
		Label.TextStrokeTransparency = 0.5
		Label.TextTransparency = 0
		Label.TextWrapped = false
		Label.TextXAlignment = Enum.TextXAlignment.Right
		Label.TextYAlignment = Enum.TextYAlignment.Center
	end
end

local ModalButton = Instance.new("TextButton")
ModalButton.Parent = ScreenGui
ModalButton.AnchorPoint = Vector2.new(0, 0)
ModalButton.BackgroundTransparency = 1
ModalButton.BackgroundColor3 = Color3.new(0, 0, 0)
ModalButton.BorderColor3 = Color3.new(0, 0, 0)
ModalButton.BorderSizePixel = 0
ModalButton.Position = UDim2.new(0, 0, 0, 0)
ModalButton.Size = UDim2.new(1, 0, 1, 0)
ModalButton.Modal = true
ModalButton.Text = ""
ModalButton.TextColor3 = Color3.new(1, 1, 1)
ModalButton.TextSize = 20
ModalButton.Visible = false

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Parent = game.Lighting
BlurEffect.Enabled = false
BlurEffect.Size = 25

local TabsVisible = false

UIS.InputBegan:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.RightShift then
		TabsVisible = not TabsVisible
		BlurEffect.Enabled = TabsVisible
		ModalButton.Visible = TabsVisible

		for _, Tab in ipairs(AllTabs) do
			Tab.Visible = TabsVisible
		end
	end
})

local ActiveNotifications = {}

local function RepositionNotifications()
	for i, Data in ipairs(ActiveNotifications) do
		local y = -80 - ((i - 1) * 70)
		Data.y = y
		Data.frame:TweenPosition(UDim2.new(1, -10, 1, y), "Out", "Quad", 0.2, true)
	end
end

function SendNotification(Title, Message, Duration)
	Duration = Duration or 3
	local y = -80 - (#ActiveNotifications * 70)

	local Notification = Instance.new("Frame")
	Notification.Parent = NotificationsFolder
	Notification.AnchorPoint = Vector2.new(1, 1)
	Notification.BackgroundTransparency = 0.5
	Notification.BackgroundColor3 = Color3.new(0, 0, 0)
	Notification.BorderColor3 = Color3.new(0, 0, 0)
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(1, 500, 1, y)
	Notification.Size = UDim2.new(0, 300, 0, 60)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = Notification
	TitleLabel.AnchorPoint = Vector2.new(0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	TitleLabel.BorderColor3 = Color3.new(0, 0, 0)
	TitleLabel.BorderSizePixel = 0
	TitleLabel.Position = UDim2.new(0, 10, 0, 5)
	TitleLabel.Size = UDim2.new(1, -20, 0, 20)
	TitleLabel.Font = Enum.Font.Sarpanch
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Color3.new(1, 1, 1)
	TitleLabel.TextSize = 20
	TitleLabel.TextStrokeTransparency = 1
	TitleLabel.TextTransparency = 0
	TitleLabel.TextWrapped = false
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

	local MessageLabel = Instance.new("TextLabel")
	MessageLabel.Parent = Notification
	MessageLabel.AnchorPoint = Vector2.new(0, 0)
	MessageLabel.BackgroundTransparency = 1
	MessageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	MessageLabel.BorderColor3 = Color3.new(0, 0, 0)
	MessageLabel.BorderSizePixel = 0
	MessageLabel.Position = UDim2.new(0, 10, 0, 25)
	MessageLabel.Size = UDim2.new(1, -20, 0, 30)
	MessageLabel.Font = Enum.Font.Sarpanch
	MessageLabel.Text = Message
	MessageLabel.TextColor3 = Color3.new(1, 1, 1)
	MessageLabel.TextSize = 20
	MessageLabel.TextStrokeTransparency = 1
	MessageLabel.TextTransparency = 0.25
	MessageLabel.TextWrapped = true
	MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
	MessageLabel.TextYAlignment = Enum.TextYAlignment.Center

	local Data = { frame = Notification, y = y }
	table.insert(ActiveNotifications, Data)

	Notification:TweenPosition(UDim2.new(1, -10, 1, y), "Out", "Quad", 0.3, true)

	task.delay(Duration, function()
		if Notification and Notification.Parent then
			local TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			local Tween = TweenService:Create(Notification, TweenInfo, {
				Position = UDim2.new(1, 500, 1, Data.y)
			})
			Tween:Play()
			Tween.Completed:Wait()

			if Notification then
				Notification:Destroy()

				for i, v in ipairs(ActiveNotifications) do
					if v == Data then
						table.remove(ActiveNotifications, i)
						break
					end
				end

				RepositionNotifications()
			end
		end
	end)
end

function Jello:AddTab(TabName)
	local TabFrame = Instance.new("Frame")
	TabFrame.Parent = TabsFolder
	TabFrame.AnchorPoint = Vector2.new(0, 0)
	TabFrame.BackgroundTransparency = 1
	TabFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	TabFrame.BorderColor3 = Color3.new(0, 0, 0)
	TabFrame.BorderSizePixel = 0
	TabFrame.Position = UDim2.new(0, 15 + TabCount * 260, 0, 15)
	TabFrame.Size = UDim2.new(0, 250, 0, 0)
	TabFrame.AutomaticSize = Enum.AutomaticSize.Y
	TabFrame.Visible = false
	TabCount += 1
	table.insert(AllTabs, TabFrame)

	local Header = Instance.new("TextButton")
	Header.Parent = TabFrame
	Header.AnchorPoint = Vector2.new(0, 0)
	Header.AutoButtonColor = false
	Header.BackgroundTransparency = 0.25
	Header.BackgroundColor3 = Color3.new(0, 0, 0)
	Header.BorderColor3 = Color3.new(0, 0, 0)
	Header.BorderSizePixel = 0
	Header.Position = UDim2.new(0, 0, 0, 0)
	Header.Size = UDim2.new(0, 250, 0, 50)
	Header.Font = Enum.Font.Sarpanch
	Header.Text = TabName or "Tab"
	Header.TextColor3 = Color3.new(1, 1, 1)
	Header.TextSize = 25
	Header.TextStrokeTransparency = 1
	Header.TextTransparency = 0
	Header.TextWrapped = false
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextYAlignment = Enum.TextYAlignment.Center

	local HeaderPadding = Instance.new("UIPadding")
	HeaderPadding.Parent = Header
	HeaderPadding.PaddingLeft = UDim.new(0, 25)

	local Modules = Instance.new("Frame")
	Modules.Parent = TabFrame
	Modules.AnchorPoint = Vector2.new(0, 0)
	Modules.BackgroundTransparency = 1
	Modules.BackgroundColor3 = Color3.new(0, 0, 0)
	Modules.BorderColor3 = Color3.new(0, 0, 0)
	Modules.BorderSizePixel = 0
	Modules.Position = UDim2.new(0, 0, 0, 50)
	Modules.Size = UDim2.new(0, 250, 0, 0)
	Modules.AutomaticSize = Enum.AutomaticSize.Y
	Modules.Visible = false

	local ModulesListLayout = Instance.new("UIListLayout")
	ModulesListLayout.Parent = Modules
	ModulesListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	Header.MouseButton2Click:Connect(function()
		Modules.Visible = not Modules.Visible
	end)

	local Tab = {}

	function Tab:AddModule(ModuleName, callback)
		local ModuleContainer = Instance.new("Frame")
		ModuleContainer.Parent = Modules
		ModuleContainer.AnchorPoint = Vector2.new(0, 0)
		ModuleContainer.BackgroundTransparency = 1
		ModuleContainer.BackgroundColor3 = Color3.new(0, 0, 0)
		ModuleContainer.BorderColor3 = Color3.new(0, 0, 0)
		ModuleContainer.BorderSizePixel = 0
		ModuleContainer.Position = UDim2.new(0, 0, 0, 0)
		ModuleContainer.Size = UDim2.new(1, 0, 0, 0)
		ModuleContainer.AutomaticSize = Enum.AutomaticSize.Y

		local ModuleContainerListLayout = Instance.new("UIListLayout")
		ModuleContainerListLayout.Parent = ModuleContainer
		ModuleContainerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local Module = Instance.new("TextButton")
		Module.Parent = ModuleContainer
		Module.AnchorPoint = Vector2.new(0, 0)
		Module.AutoButtonColor = false
		Module.BackgroundTransparency = 0.5
		Module.BackgroundColor3 = Color3.new(0, 0, 0)
		Module.BorderColor3 = Color3.new(0, 0, 0)
		Module.BorderSizePixel = 0
		Module.Position = UDim2.new(0, 0, 0, 0)
		Module.Size = UDim2.new(1, 0, 0, 50)
		Module.Font = Enum.Font.Sarpanch
		Module.Text = ModuleName or "Module"
		Module.TextColor3 = Color3.new(1, 1, 1)
		Module.TextSize = 20
		Module.TextStrokeTransparency = 1
		Module.TextTransparency = 0.5
		Module.TextWrapped = false
		Module.TextXAlignment = Enum.TextXAlignment.Left
		Module.TextYAlignment = Enum.TextYAlignment.Center

		local ModulePadding = Instance.new("UIPadding")
		ModulePadding.Parent = Module
		ModulePadding.PaddingLeft = UDim.new(0, 25)

		local ModuleOptions = Instance.new("Frame")
		ModuleOptions.Parent = ModuleContainer
		ModuleOptions.AnchorPoint = Vector2.new(0, 0)
		ModuleOptions.BackgroundTransparency = 0.25
		ModuleOptions.BackgroundColor3 = Color3.new(0, 0, 0)
		ModuleOptions.BorderColor3 = Color3.new(0, 0, 0)
		ModuleOptions.BorderSizePixel = 0
		ModuleOptions.Position = UDim2.new(0, 0, 0, 0)
		ModuleOptions.Size = UDim2.new(1, 0, 0, 0)
		ModuleOptions.AutomaticSize = Enum.AutomaticSize.Y
		ModuleOptions.ClipsDescendants = true
		ModuleOptions.Visible = false

		local ModuleOptionsListLayout = Instance.new("UIListLayout")
		ModuleOptionsListLayout.Parent = ModuleOptions
		ModuleOptionsListLayout.Padding = UDim.new(0, 5)
		ModuleOptionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local Bind = Instance.new("TextButton")
		Bind.Parent = ModuleOptions
		Bind.AnchorPoint = Vector2.new(0, 0)
		Bind.BackgroundTransparency = 1
		Bind.BackgroundColor3 = Color3.new(0, 0, 0)
		Bind.BorderColor3 = Color3.new(0, 0, 0)
		Bind.BorderSizePixel = 0
		Bind.Position = UDim2.new(0, 0, 0, 0)
		Bind.Size = UDim2.new(1, 0, 0, 25)
		Bind.Font = Enum.Font.Sarpanch
		Bind.Text = "Bind: None"
		Bind.TextColor3 = Color3.new(1, 1, 1)
		Bind.TextSize = 15
		Bind.TextStrokeTransparency = 1
		Bind.TextTransparency = 0
		Bind.TextWrapped = false
		Bind.TextXAlignment = Enum.TextXAlignment.Left
		Bind.TextYAlignment = Enum.TextYAlignment.Center

		local BindPadding = Instance.new("UIPadding")
		BindPadding.Parent = Bind
		BindPadding.PaddingLeft = UDim.new(0, 25)

		local Enabled = false
		local CurrentBind = nil
		local Binding = false
		local SkipNext = false

		local function ToggleModule()
			Enabled = not Enabled
			Module.TextTransparency = Enabled and 0 or 0.5
			if callback then callback(Enabled) end
			SendNotification("Jello", (Enabled and "Enabled " or "Disabled ") .. ModuleName, 1)

			if Enabled then
				table.insert(ActiveModules, ModuleName)
			else
				for i, v in ipairs(ActiveModules) do
					if v == ModuleName then
						table.remove(ActiveModules, i)
						break
					end
				end
			end

			RefreshActiveModules()
		end

		Module.MouseButton1Click:Connect(ToggleModule)

		Module.MouseButton2Click:Connect(function()
			ModuleOptions.Visible = not ModuleOptions.Visible
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
						task.delay(1, function() Bind.Text = "Bind: None" end)
						SkipNext = true
					else
						CurrentBind = Input.KeyCode
						Bind.Text = "Bind: " .. Input.KeyCode.Name
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
				ToggleModule()
			end
		end)
	end

	return Tab
end

return Jello
