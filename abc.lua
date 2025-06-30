local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

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
TabsFolder.Parent = ScreenGui

local TabsContainer = Instance.new("Frame")
TabsContainer.BackgroundColor3 = Color3.new(0, 0, 0)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.Size = UDim2.new(1, 0, 1, 0)
TabsContainer.Visible = false
TabsContainer.Parent = TabsFolder

local ArrayListFolder = Instance.new("Folder")
ArrayListFolder.Parent = ScreenGui

local ArrayListDisplay = Instance.new("Frame")
ArrayListDisplay.AnchorPoint = Vector2.new(1, 0)
ArrayListDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
ArrayListDisplay.BackgroundTransparency = 1
ArrayListDisplay.BorderColor3 = Color3.new(0, 0, 0)
ArrayListDisplay.BorderSizePixel = 0
ArrayListDisplay.Position = UDim2.new(1, -5, 0, -57.5)
ArrayListDisplay.Size = UDim2.new(0, 250, 1, 1000)
ArrayListDisplay.ZIndex = 10
ArrayListDisplay.Parent = ArrayListFolder
ArrayListDisplay.Visible = false

local ArrayListLayout = Instance.new("UIListLayout")
ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayListLayout.Padding = UDim.new(0, 0)
ArrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ArrayListLayout.Parent = ArrayListDisplay

local function GetTextWidth(text)
	return TextService:GetTextSize(text, 20, Enum.Font.Sarpanch, Vector2.new(1000, 20)).X
end

local function RefreshActiveModules()
	for _, v in pairs(ArrayListDisplay:GetChildren()) do
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
		Label.Parent = ArrayListDisplay
	end
end

local NotificationsFolder = Instance.new("Folder")
NotificationsFolder.Parent = ScreenGui

local NotificationsContainer = Instance.new("Frame")
NotificationsContainer.BackgroundColor3 = Color3.new(0, 0, 0)
NotificationsContainer.BackgroundTransparency = 1
NotificationsContainer.BorderSizePixel = 0
NotificationsContainer.Size = UDim2.new(1, 0, 1, 0)
NotificationsContainer.Visible = false
NotificationsContainer.Parent = NotificationsFolder

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
	Notification.Parent = NotificationsContainer

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

local TargetHUDFolder = Instance.new("Folder")
TargetHUDFolder.Parent = ScreenGui

local TargetHUD = Instance.new("Frame")
TargetHUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetHUD.BackgroundTransparency = 0.25
TargetHUD.BorderSizePixel = 0
TargetHUD.Position = UDim2.new(0.435, 0, 0.8, 0)
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
TargetName.Text = "Roblox"
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

local MaxDistance = 15
local TargetHUDEnabled = false
local TargetHUDThread = nil

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

function Jello:ToggleArrayList(State)
	if State == nil then
		ArrayListDisplay.Visible = not ArrayListDisplay.Visible
	else
		ArrayListDisplay.Visible = State
	end
end

function Jello:ToggleNotifications(State)
    if State == nil then
        NotificationsContainer.Visible = not NotificationsContainer.Visible
    else
        NotificationsContainer.Visible = State
    end
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
					task.wait()
					local Target = GetClosestPlayer()
					local ShouldShow = false

					if IsAlive(Target) then
						local Humanoid = Target.Character.Humanoid
						local HP = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
						TargetName.Text = Target.Name
						HPBar.Size = UDim2.new(HP, 0, 1, 0)
						HPBar.BackgroundColor3 = GetHealthColor(HP)
						TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Target.UserId .. "&width=420&height=420&format=png"
						ShouldShow = true
					elseif TabsVisible then
						TargetName.Text = "Roblox"
						HPBar.Size = UDim2.new(0, 0, 1, 0)
						HPBar.BackgroundColor3 = Color3.new(0, 0, 0)
						TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
						ShouldShow = true
					end

					TargetHUD.Visible = ShouldShow
				end
				TargetHUD.Visible = false
				TargetHUDThread = nil
			end)
		end
	else
		TargetHUDEnabled = false
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
		TabsContainer.Visible = TabsVisible
	end
end)

function Jello:AddTab(TabName)
	local TabFrame = Instance.new("Frame")
	TabFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	TabFrame.BackgroundTransparency = 1
	TabFrame.BorderColor3 = Color3.new(0, 0, 0)
	TabFrame.BorderSizePixel = 0
	TabFrame.Position = UDim2.new(0, 15 + TabCount * 260, 0, 15)
	TabFrame.Size = UDim2.new(0, 250, 0, 0)
	TabFrame.Visible = true
	TabFrame.AutomaticSize = Enum.AutomaticSize.Y
	TabFrame.Parent = TabsContainer
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

return Jello
