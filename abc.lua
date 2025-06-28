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
TabsFolder.Name = "Tabs"
TabsFolder.Parent = ScreenGui

local NotificationsFolder = Instance.new("Folder")
NotificationsFolder.Name = "Notifications"
NotificationsFolder.Parent = ScreenGui

local ActiveModulesFolder = Instance.new("Folder")
ActiveModulesFolder.Name = "ActiveModules"
ActiveModulesFolder.Parent = ScreenGui

local ActiveModulesDisplay = Instance.new("Frame")
ActiveModulesDisplay.Name = "ActiveModulesDisplay"
ActiveModulesDisplay.Parent = ActiveModulesFolder
ActiveModulesDisplay.AnchorPoint = Vector2.new(1, 0)
ActiveModulesDisplay.Position = UDim2.new(1, -5, 0, -50)
ActiveModulesDisplay.Size = UDim2.new(0, 200, 1, -20)
ActiveModulesDisplay.BackgroundTransparency = 1
ActiveModulesDisplay.ZIndex = 10

local ActiveModulesLayout = Instance.new("UIListLayout")
ActiveModulesLayout.Parent = ActiveModulesDisplay
ActiveModulesLayout.SortOrder = Enum.SortOrder.LayoutOrder
ActiveModulesLayout.Padding = UDim.new(0, 0)
ActiveModulesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local ActiveModules = {}

local function RefreshActiveModules()
	for _, v in pairs(ActiveModulesDisplay:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end
	
	table.sort(ActiveModules, function(a, b)
		if #a == #b then
			return a:lower() < b:lower()
		else
			return #a > #b
		end
	end)

	for _, ModuleName in ipairs(ActiveModules) do
		local Label = Instance.new("TextLabel")
		Label.Parent = ActiveModulesDisplay
		Label.BackgroundTransparency = 1
		Label.BackgroundColor3 = Color3.new(0, 0, 0)
		Label.BorderColor3 = Color3.new(0, 0, 0)
		Label.BorderSizePixel = 0
		Label.Size = UDim2.new(0, 0, 0, 20)
		Label.AutomaticSize = Enum.AutomaticSize.X
		Label.Font = Enum.Font.Sarpanch
		Label.Text = ModuleName
		Label.TextColor3 = Color3.new(1, 1, 1)
		Label.TextSize = 20
		Label.TextTransparency = 0
		Label.TextStrokeTransparency = 0.5
		Label.TextXAlignment = Enum.TextXAlignment.Right
		Label.TextWrapped = false
	end
end

local ModalButton = Instance.new("TextButton")
ModalButton.BackgroundTransparency = 1
ModalButton.Size = UDim2.new()
ModalButton.Text = ""
ModalButton.Modal = true
ModalButton.Visible = false
ModalButton.Parent = ScreenGui

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 25
BlurEffect.Enabled = false
BlurEffect.Parent = game.Lighting

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
end)

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
	Notification.AnchorPoint = Vector2.new(1, 1)
	Notification.BackgroundColor3 = Color3.new(0, 0, 0)
	Notification.BackgroundTransparency = 0.25
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(1, 500, 1, y)
	Notification.Size = UDim2.new(0, 300, 0, 60)
	Notification.Parent = NotificationsFolder

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.Sarpanch
	TitleLabel.Position = UDim2.new(0, 10, 0, 5)
	TitleLabel.Size = UDim2.new(1, -20, 0, 20)
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Color3.new(1, 1, 1)
	TitleLabel.TextSize = 20
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Notification

	local MessageLabel = Instance.new("TextLabel")
	MessageLabel.BackgroundTransparency = 1
	MessageLabel.Font = Enum.Font.Sarpanch
	MessageLabel.Position = UDim2.new(0, 10, 0, 25)
	MessageLabel.Size = UDim2.new(1, -20, 0, 30)
	MessageLabel.Text = Message
	MessageLabel.TextColor3 = Color3.new(1, 1, 1)
	MessageLabel.TextTransparency = 0.25
	MessageLabel.TextSize = 20
	MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
	MessageLabel.TextWrapped = true
	MessageLabel.Parent = Notification

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
	TabFrame.BackgroundTransparency = 1
	TabFrame.Position = UDim2.new(0, 15 + TabCount * 260, 0, 15)
	TabFrame.Size = UDim2.new(0, 250, 0, 0)
	TabFrame.Visible = false
	TabFrame.AutomaticSize = Enum.AutomaticSize.Y
	TabFrame.BorderSizePixel = 0
	TabFrame.BorderColor3 = Color3.new(0, 0, 0)
	TabCount += 1
	table.insert(AllTabs, TabFrame)

	local Header = Instance.new("TextButton")
	Header.Parent = TabFrame
	Header.BackgroundColor3 = Color3.new(0, 0, 0)
	Header.BackgroundTransparency = 0.25
	Header.BorderSizePixel = 0
	Header.Size = UDim2.new(0, 250, 0, 50)
	Header.AutoButtonColor = false
	Header.Font = Enum.Font.Sarpanch
	Header.Text = TabName or "Tab"
	Header.TextColor3 = Color3.new(1, 1, 1)
	Header.TextSize = 25
	Header.TextXAlignment = Enum.TextXAlignment.Left

	local HeaderPadding = Instance.new("UIPadding", Header)
	HeaderPadding.PaddingLeft = UDim.new(0, 25)

	local Modules = Instance.new("Frame")
	Modules.Parent = TabFrame
	Modules.BackgroundTransparency = 1
	Modules.Position = UDim2.new(0, 0, 0, 50)
	Modules.Size = UDim2.new(0, 250, 0, 0)
	Modules.Visible = false
	Modules.AutomaticSize = Enum.AutomaticSize.Y

	local ModulesListLayout = Instance.new("UIListLayout", Modules)
	ModulesListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	Header.MouseButton2Click:Connect(function()
		Modules.Visible = not Modules.Visible
	end)

	local Tab = {}

	function Tab:AddModule(ModuleName, callback)
		local ModuleContainer = Instance.new("Frame")
		ModuleContainer.Parent = Modules
		ModuleContainer.BackgroundTransparency = 1
		ModuleContainer.Size = UDim2.new(1, 0, 0, 0)
		ModuleContainer.AutomaticSize = Enum.AutomaticSize.Y

		local ModuleContainerListLayout = Instance.new("UIListLayout", ModuleContainer)
		ModuleContainerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local Module = Instance.new("TextButton")
		Module.Parent = ModuleContainer
		Module.BackgroundColor3 = Color3.new(0, 0, 0)
		Module.BackgroundTransparency = 0.5
		Module.BorderSizePixel = 0
		Module.Size = UDim2.new(1, 0, 0, 50)
		Module.AutoButtonColor = false
		Module.Font = Enum.Font.Sarpanch
		Module.Text = ModuleName or "Module"
		Module.TextColor3 = Color3.new(1, 1, 1)
		Module.TextSize = 20
		Module.TextTransparency = 0.5
		Module.TextXAlignment = Enum.TextXAlignment.Left

		local ModulePadding = Instance.new("UIPadding", Module)
		ModulePadding.PaddingLeft = UDim.new(0, 25)

		local ModuleOptions = Instance.new("Frame")
		ModuleOptions.Parent = ModuleContainer
		ModuleOptions.BackgroundColor3 = Color3.new(0, 0, 0)
		ModuleOptions.BackgroundTransparency = 0.25
		ModuleOptions.BorderSizePixel = 0
		ModuleOptions.Size = UDim2.new(1, 0, 0, 0)
		ModuleOptions.Visible = false
		ModuleOptions.AutomaticSize = Enum.AutomaticSize.Y
		ModuleOptions.ClipsDescendants = true

		local ModuleOptionsListLayout = Instance.new("UIListLayout", ModuleOptions)
		ModuleOptionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ModuleOptionsListLayout.Padding = UDim.new(0, 5)

		local Bind = Instance.new("TextButton")
		Bind.Parent = ModuleOptions
		Bind.BackgroundTransparency = 1
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
