local ContentProvider = game:GetService("ContentProvider")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Jello = {}
local AllTabs = {}
local TabCount = 0
local ActiveModules = {}
local ActiveNotifications = {}

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
ActiveModulesDisplay.AnchorPoint = Vector2.new(1, 0)
ActiveModulesDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
ActiveModulesDisplay.BackgroundTransparency = 1
ActiveModulesDisplay.BorderColor3 = Color3.new(0, 0, 0)
ActiveModulesDisplay.BorderSizePixel = 0
ActiveModulesDisplay.Position = UDim2.new(1, -5, 0, -57.5)
ActiveModulesDisplay.Size = UDim2.new(0, 250, 1, 1000)
ActiveModulesDisplay.ZIndex = 10
ActiveModulesDisplay.Parent = ActiveModulesFolder

local ActiveModulesLayout = Instance.new("UIListLayout")
ActiveModulesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ActiveModulesLayout.Padding = UDim.new(0, 0)
ActiveModulesLayout.SortOrder = Enum.SortOrder.LayoutOrder
ActiveModulesLayout.Parent = ActiveModulesDisplay

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
		Label.BackgroundColor3 = Color3.new(0, 0, 0)
		Label.BackgroundTransparency = 1
		Label.BorderColor3 = Color3.new(0, 0, 0)
		Label.BorderSizePixel = 0
		Label.Font = Enum.Font.Sarpanch
		Label.Size = UDim2.new(0, 0, 0, 20)
		Label.Text = ModuleName
		Label.TextColor3 = Color3.new(1, 1, 1)
		Label.TextSize = 20
		Label.TextStrokeTransparency = 0.5
		Label.TextTransparency = 0
		Label.TextWrapped = false
		Label.TextXAlignment = Enum.TextXAlignment.Right
		Label.AutomaticSize = Enum.AutomaticSize.X
		Label.Name = "Label"
		Label.Parent = ActiveModulesDisplay
	end
end

local ModalButton = Instance.new("TextButton")
ModalButton.BackgroundColor3 = Color3.new(0, 0, 0)
ModalButton.BackgroundTransparency = 1
ModalButton.BorderColor3 = Color3.new(0, 0, 0)
ModalButton.BorderSizePixel = 0
ModalButton.Size = UDim2.new()
ModalButton.Text = ""
ModalButton.Visible = false
ModalButton.Modal = true
ModalButton.Parent = ScreenGui

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Enabled = false
BlurEffect.Size = 25
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
	Notification.BackgroundTransparency = 0.5
	Notification.BorderColor3 = Color3.new(0, 0, 0)
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(1, 500, 1, y)
	Notification.Size = UDim2.new(0, 300, 0, 60)
	Notification.Parent = NotificationsFolder

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.BorderColor3 = Color3.new(0, 0, 0)
	TitleLabel.BorderSizePixel = 0
	TitleLabel.Font = Enum.Font.Sarpanch
	TitleLabel.Position = UDim2.new(0, 10, 0, 5)
	TitleLabel.Size = UDim2.new(1, -20, 0, 20)
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Color3.new(1, 1, 1)
	TitleLabel.TextSize = 20
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Notification

	local MessageLabel = Instance.new("TextLabel")
	MessageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	MessageLabel.BackgroundTransparency = 1
	MessageLabel.BorderColor3 = Color3.new(0, 0, 0)
	MessageLabel.BorderSizePixel = 0
	MessageLabel.Font = Enum.Font.Sarpanch
	MessageLabel.Position = UDim2.new(0, 10, 0, 25)
	MessageLabel.Size = UDim2.new(1, -20, 0, 30)
	MessageLabel.Text = Message
	MessageLabel.TextColor3 = Color3.new(1, 1, 1)
	MessageLabel.TextTransparency = 0.25
	MessageLabel.TextSize = 20
	MessageLabel.TextWrapped = true
	MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
	MessageLabel.Parent = Notification

	local Data = { frame = Notification, y = y }
	table.insert(ActiveNotifications, Data)

	Notification:TweenPosition(UDim2.new(1, -10, 1, y), "Out", "Quad", 0.3, true)

	task.delay(Duration, function()
		if Notification and Notification.Parent then
			local TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			local Tween = TweenService:Create(Notification, TweenInfo, { Position = UDim2.new(1, 500, 1, Data.y) })
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
	TabFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	TabFrame.BackgroundTransparency = 1
	TabFrame.BorderColor3 = Color3.new(0, 0, 0)
	TabFrame.BorderSizePixel = 0
	TabFrame.Position = UDim2.new(0, 15 + TabCount * 260, 0, 15)
	TabFrame.Size = UDim2.new(0, 250, 0, 0)
	TabFrame.Visible = false
	TabFrame.AutomaticSize = Enum.AutomaticSize.Y
	TabFrame.Parent = TabsFolder
	TabCount += 1
	table.insert(AllTabs, TabFrame)

	local Header = Instance.new("TextButton")
	Header.BackgroundColor3 = Color3.new(0, 0, 0)
	Header.BackgroundTransparency = 0.25
	Header.BorderColor3 = Color3.new(0, 0, 0)
	Header.BorderSizePixel = 0
	Header.Font = Enum.Font.Sarpanch
	Header.Size = UDim2.new(0, 250, 0, 50)
	Header.Text = TabName or "Tab"
	Header.TextColor3 = Color3.new(1, 1, 1)
	Header.TextSize = 25
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.AutoButtonColor = false
	Header.Parent = TabFrame

	local HeaderPadding = Instance.new("UIPadding")
	HeaderPadding.PaddingLeft = UDim.new(0, 25)
	HeaderPadding.Parent = Header

	local Modules = Instance.new("Frame")
	Modules.BackgroundColor3 = Color3.new(0, 0, 0)
	Modules.BackgroundTransparency = 1
	Modules.BorderColor3 = Color3.new(0, 0, 0)
	Modules.BorderSizePixel = 0
	Modules.Position = UDim2.new(0, 0, 0, 50)
	Modules.Size = UDim2.new(0, 250, 0, 0)
	Modules.Visible = false
	Modules.AutomaticSize = Enum.AutomaticSize.Y
	Modules.Parent = TabFrame

	local ModulesListLayout = Instance.new("UIListLayout")
	ModulesListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ModulesListLayout.Parent = Modules

	Header.MouseButton2Click:Connect(function()
		Modules.Visible = not Modules.Visible
	end)

	local Tab = {}

	function Tab:AddModule(ModuleName, callback)
		local ModuleContainer = Instance.new("Frame")
		ModuleContainer.BackgroundColor3 = Color3.new(0, 0, 0)
		ModuleContainer.BackgroundTransparency = 1
		ModuleContainer.BorderColor3 = Color3.new(0, 0, 0)
		ModuleContainer.BorderSizePixel = 0
		ModuleContainer.Size = UDim2.new(1, 0, 0, 0)
		ModuleContainer.AutomaticSize = Enum.AutomaticSize.Y
		ModuleContainer.Parent = Modules

		local ModuleContainerListLayout = Instance.new("UIListLayout")
		ModuleContainerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ModuleContainerListLayout.Parent = ModuleContainer

		local Module = Instance.new("TextButton")
		Module.BackgroundColor3 = Color3.new(0, 0, 0)
		Module.BackgroundTransparency = 0.5
		Module.BorderColor3 = Color3.new(0, 0, 0)
		Module.BorderSizePixel = 0
		Module.Font = Enum.Font.Sarpanch
		Module.Size = UDim2.new(1, 0, 0, 50)
		Module.Text = ModuleName or "Module"
		Module.TextColor3 = Color3.new(1, 1, 1)
		Module.TextSize = 20
		Module.TextTransparency = 0.5
		Module.TextXAlignment = Enum.TextXAlignment.Left
		Module.AutoButtonColor = false
		Module.Parent = ModuleContainer

		local ModulePadding = Instance.new("UIPadding")
		ModulePadding.PaddingLeft = UDim.new(0, 25)
		ModulePadding.Parent = Module

		local ModuleOptions = Instance.new("Frame")
		ModuleOptions.BackgroundColor3 = Color3.new(0, 0, 0)
		ModuleOptions.BackgroundTransparency = 0.25
		ModuleOptions.BorderColor3 = Color3.new(0, 0, 0)
		ModuleOptions.BorderSizePixel = 0
		ModuleOptions.Size = UDim2.new(1, 0, 0, 0)
		ModuleOptions.Visible = false
		ModuleOptions.AutomaticSize = Enum.AutomaticSize.Y
		ModuleOptions.ClipsDescendants = true
		ModuleOptions.Parent = ModuleContainer

		local ModuleOptionsListLayout = Instance.new("UIListLayout")
		ModuleOptionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ModuleOptionsListLayout.Padding = UDim.new(0, 5)
		ModuleOptionsListLayout.Parent = ModuleOptions

		local Bind = Instance.new("TextButton")
		Bind.BackgroundColor3 = Color3.new(0, 0, 0)
		Bind.BackgroundTransparency = 1
		Bind.BorderColor3 = Color3.new(0, 0, 0)
		Bind.BorderSizePixel = 0
		Bind.Font = Enum.Font.Sarpanch
		Bind.Size = UDim2.new(1, 0, 0, 25)
		Bind.Text = "Bind: None"
		Bind.TextColor3 = Color3.new(1, 1, 1)
		Bind.TextSize = 15
		Bind.TextXAlignment = Enum.TextXAlignment.Left
		Bind.Parent = ModuleOptions

		local BindPadding = Instance.new("UIPadding")
		BindPadding.PaddingLeft = UDim.new(0, 25)
		BindPadding.Parent = Bind

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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local MaxDistance = 15
local TargetHUDEnabled = false
local TargetHUDThread = nil

local TargetHUDFolder = Instance.new("Folder")
TargetHUDFolder.Name = "TargetHUDFolder"
TargetHUDFolder.Parent = ScreenGui

local TargetHUD = Instance.new("Frame")
TargetHUD.Name = "TargetHUD"
TargetHUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetHUD.BackgroundTransparency = 0.25
TargetHUD.BorderSizePixel = 0
TargetHUD.Position = UDim2.new(0.435, 0, 0.75, 0)
TargetHUD.Size = UDim2.new(0, 250, 0, 75)
TargetHUD.Visible = false
TargetHUD.Parent = TargetHUDFolder

local TargetPhoto = Instance.new("ImageLabel")
TargetPhoto.BackgroundTransparency = 1
TargetPhoto.BorderSizePixel = 0
TargetPhoto.Position = UDim2.new(0, 10, 0, 12)
TargetPhoto.Size = UDim2.new(0, 50, 0, 50)
TargetPhoto.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
TargetPhoto.Parent = TargetHUD

local TargetName = Instance.new("TextLabel")
TargetName.BackgroundTransparency = 1
TargetName.Position = UDim2.new(0.275, 0, 0.15, 0)
TargetName.Size = UDim2.new(0, 150, 0, 25)
TargetName.Font = Enum.Font.Sarpanch
TargetName.Text = "No Target"
TargetName.TextColor3 = Color3.new(1, 1, 1)
TargetName.TextSize = 20
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetHUD

local HPBG = Instance.new("Frame")
HPBG.BackgroundColor3 = Color3.new(1, 1, 1)
HPBG.BackgroundTransparency = 0.85
HPBG.BorderSizePixel = 0
HPBG.Position = UDim2.new(0.275, 0, 0.5, 0)
HPBG.Size = UDim2.new(0, 150, 0, 10)
HPBG.Parent = TargetHUD

local HPBar = Instance.new("Frame")
HPBar.BackgroundColor3 = Color3.new(0, 0, 0)
HPBar.BorderSizePixel = 0
HPBar.Position = UDim2.new(0, 0, 0, 0)
HPBar.Size = UDim2.new(0, 0, 1, 0)
HPBar.Parent = HPBG

local function GetHealthColor(HealthPercent)
	local R = math.clamp(1 - HealthPercent, 0, 1)
	local G = math.clamp(HealthPercent, 0, 1)
	return Color3.new(R, G, 0)
end

local function IsAlive(Player)
	return Player and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.Humanoid.Health > 0
end

local function IsEnemy(Player)
	return Player and Player ~= LocalPlayer and (Player.Neutral or Player.Team ~= LocalPlayer.Team)
end

local function GetClosestPlayer()
	local ClosestPlayer, ClosestDistance = nil, MaxDistance
	for _, Player in ipairs(Players:GetPlayers()) do
		if IsAlive(LocalPlayer) and IsAlive(Player) and IsEnemy(Player) then
			local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if Distance < ClosestDistance then
				ClosestPlayer = Player
				ClosestDistance = Distance
			end
		end
	end
	return ClosestPlayer
end

function Jello:ToggleTargetHUD(State)
	if State == nil then
		TargetHUDEnabled = not TargetHUDEnabled
	else
		TargetHUDEnabled = State
	end

	if TargetHUDEnabled then
		if not TargetHUDThread then
			TargetHUDThread = task.spawn(function()
				while TargetHUDEnabled do
					task.wait(0.2)

					local Target = GetClosestPlayer()
					local shouldShow = false

					if IsAlive(Target) then
						local Humanoid = Target.Character.Humanoid
						local HP = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
						TargetName.Text = Target.Name
						HPBar.Size = UDim2.new(HP, 0, 1, 0)
						HPBar.BackgroundColor3 = GetHealthColor(HP)
						TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Target.UserId .. "&width=420&height=420&format=png"
						shouldShow = true
					end

					if TabsVisible then
						TargetHUD.Visible = true
					elseif shouldShow then
						TargetHUD.Visible = true
					else
						TargetHUD.Visible = false
					end
				end

				TargetHUD.Visible = false
				TargetHUDThread = nil
			end)
		end
	else
		TargetHUDEnabled = false
	end
end

local MaxDistance = 15
local TargetHUDEnabled = false
local TargetHUDThread = nil

local TargetHUDFolder = Instance.new("Folder")
TargetHUDFolder.Name = "TargetHUD"
TargetHUDFolder.Parent = ScreenGui

local TargetHUD = Instance.new("Frame")
TargetHUD.Name = "TargetHUD"
TargetHUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetHUD.BackgroundTransparency = 0.25
TargetHUD.BorderSizePixel = 0
TargetHUD.Position = UDim2.new(0.435, 0, 0.75, 0)
TargetHUD.Size = UDim2.new(0, 250, 0, 75)
TargetHUD.Visible = false
TargetHUD.ZIndex = 10
TargetHUD.Parent = TargetHUDFolder

local TargetPhoto = Instance.new("ImageLabel")
TargetPhoto.BackgroundTransparency = 1
TargetPhoto.BorderSizePixel = 0
TargetPhoto.Position = UDim2.new(0, 10, 0, 12)
TargetPhoto.Size = UDim2.new(0, 50, 0, 50)
TargetPhoto.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
TargetPhoto.Parent = TargetHUD

local TargetName = Instance.new("TextLabel")
TargetName.BackgroundTransparency = 1
TargetName.Position = UDim2.new(0.275, 0, 0.15, 0)
TargetName.Size = UDim2.new(0, 150, 0, 25)
TargetName.Font = Enum.Font.Sarpanch
TargetName.Text = "No Target"
TargetName.TextColor3 = Color3.new(1, 1, 1)
TargetName.TextSize = 20
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetHUD

local HPBG = Instance.new("Frame")
HPBG.BackgroundColor3 = Color3.new(1, 1, 1)
HPBG.BackgroundTransparency = 0.85
HPBG.BorderSizePixel = 0
HPBG.Position = UDim2.new(0.275, 0, 0.5, 0)
HPBG.Size = UDim2.new(0, 150, 0, 10)
HPBG.Parent = TargetHUD

local HPBar = Instance.new("Frame")
HPBar.BackgroundColor3 = Color3.new(0, 0, 0)
HPBar.BorderSizePixel = 0
HPBar.Position = UDim2.new(0, 0, 0, 0)
HPBar.Size = UDim2.new(0, 0, 1, 0)
HPBar.Parent = HPBG

local function PreloadProfileImages()
	local assets = {}
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(assets, "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png")
	end
	table.insert(assets, "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png")
	ContentProvider:PreloadAsync(assets)
end

Players.PlayerAdded:Connect(function(player)
	local url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
	ContentProvider:PreloadAsync({url})
end)

PreloadProfileImages()

local function GetHealthColor(HealthPercent)
	local R = math.clamp(1 - HealthPercent, 0, 1)
	local G = math.clamp(HealthPercent, 0, 1)
	return Color3.new(R, G, 0)
end

local function IsAlive(Player)
	return Player and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.Humanoid.Health > 0
end

local function IsEnemy(Player)
	return Player and Player ~= LocalPlayer and (Player.Neutral or Player.Team ~= LocalPlayer.Team)
end

local function GetClosestPlayer()
	local ClosestPlayer, ClosestDistance = nil, MaxDistance
	for _, Player in ipairs(Players:GetPlayers()) do
		if IsAlive(LocalPlayer) and IsAlive(Player) and IsEnemy(Player) then
			local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if Distance < ClosestDistance then
				ClosestPlayer = Player
				ClosestDistance = Distance
			end
		end
	end
	return ClosestPlayer
end

function Jello:ToggleTargetHUD(state)
	if state == nil then
		TargetHUDEnabled = not TargetHUDEnabled
	else
		TargetHUDEnabled = state
	end

	if TargetHUDEnabled then
		if not TargetHUDThread then
			TargetHUDThread = task.spawn(function()
				while TargetHUDEnabled do
					task.wait()
					local Target = GetClosestPlayer()
					local shouldShow = false

					if IsAlive(Target) then
						local Humanoid = Target.Character.Humanoid
						local HP = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
						TargetName.Text = Target.Name
						HPBar.Size = UDim2.new(HP, 0, 1, 0)
						HPBar.BackgroundColor3 = GetHealthColor(HP)
						TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Target.UserId .. "&width=420&height=420&format=png"
						shouldShow = true
					elseif TabsVisible then
						TargetName.Text = "Roblox"
						HPBar.Size = UDim2.new(0, 0, 1, 0)
						HPBar.BackgroundColor3 = Color3.new(0, 0, 0)
						TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
						shouldShow = true
					end

					TargetHUD.Visible = shouldShow
				end
				TargetHUD.Visible = false
				TargetHUDThread = nil
			end)
		end
	else
		TargetHUDEnabled = false
	end
end

return Jello
