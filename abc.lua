local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService") -- TextService'i bir kez al ve tekrar kullan

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("Jello") then
	return
end

--[[
	GetTextWidth
	Belirtilen metnin piksel cinsinden genişliğini döndürür.
	Bu fonksiyon, UI düzenlemeleri ve dinamik metin boyutlandırması için kullanışlıdır.

	@param text string -- Genişliği hesaplanacak metin.
	@param fontSize number -- Metnin boyutu (varsayılan: 25).
	@param font Enum.Font | Font -- Kullanılacak font (varsayılan: Enum.Font.Sarpanch).
	@param preferredWidth number -- Metnin sarmalanabileceği maksimum genişlik (varsayılan: 1000).
	@param preferredHeight number -- Metnin sarmalanabileceği maksimum yükseklik (varsayılan: fontSize + küçük bir pay, örn. 5).

	@return number -- Metnin hesaplanan genişliği.
]]
local function GetTextWidth(text, fontSize, font, preferredWidth, preferredHeight)
	-- Parametrelerin geçerliliğini kontrol et ve varsayılan değerleri ata
	text = tostring(text) -- Metni her zaman string'e dönüştürerek hata olasılığını azalt
	fontSize = typeof(fontSize) == "number" and fontSize > 0 and fontSize or 25
	font = typeof(font) == "EnumItem" and font.EnumType == Enum.Font and font or Enum.Font.Sarpanch
	preferredWidth = typeof(preferredWidth) == "number" and preferredWidth > 0 and preferredWidth or 1000
	-- preferredHeight'i dinamik olarak belirle. TextService metnin sığabileceği alanı daha doğru hesaplayabilir.
	preferredHeight = typeof(preferredHeight) == "number" and preferredHeight > 0 and preferredHeight or (fontSize + 5) -- Font boyutu + küçük bir pay

	local textSizeVector = TextService:GetTextSize(
		text,
		fontSize,
		font,
		Vector2.new(preferredWidth, preferredHeight)
	)

	return textSizeVector.X
end

local Jello = {}
local AllTabs = {}
local TabCount = 0
local ActiveModules = {}
local ActiveNotifications = {}

local GUIVisible = false
local NotificationsEnabled = false

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
TabsContainer.BorderColor3 = Color3.new(0, 0, 0)
TabsContainer.Size = UDim2.new(1, 0, 1, 0)
TabsContainer.Visible = false
TabsContainer.Parent = TabsFolder

local ArrayListFolder = Instance.new("Folder")
ArrayListFolder.Parent = ScreenGui

local ArrayListContainer = Instance.new("Frame")
ArrayListContainer.BackgroundColor3 = Color3.new(0, 0, 0)
ArrayListContainer.BackgroundTransparency = 1
ArrayListContainer.BorderSizePixel = 0
ArrayListContainer.BorderColor3 = Color3.new(0, 0, 0)
ArrayListContainer.AnchorPoint = Vector2.new(1, 0)
ArrayListContainer.Position = UDim2.new(1, -5, 0, -55)
ArrayListContainer.Size = UDim2.new(0, 250, 0, 0)
ArrayListContainer.AutomaticSize = Enum.AutomaticSize.Y
ArrayListContainer.Visible = false
ArrayListContainer.Parent = ArrayListFolder

local ArrayListHeader = Instance.new("Frame")
ArrayListHeader.BackgroundColor3 = Color3.new(0, 0, 0)
ArrayListHeader.BackgroundTransparency = 0.25
ArrayListHeader.BorderSizePixel = 0
ArrayListHeader.BorderColor3 = Color3.new(0, 0, 0)
ArrayListHeader.Size = UDim2.new(1, 0, 0, 25)
ArrayListHeader.Position = UDim2.new(0, 0, 0, 0)
ArrayListHeader.Parent = ArrayListContainer

local ArrayListHeaderText = Instance.new("TextLabel")
ArrayListHeaderText.BackgroundTransparency = 1
ArrayListHeaderText.BorderSizePixel = 0
ArrayListHeaderText.BorderColor3 = Color3.new(0, 0, 0)
ArrayListHeaderText.Size = UDim2.new(1, 0, 1, 0)
ArrayListHeaderText.Font = Enum.Font.Sarpanch
ArrayListHeaderText.Text = "ArrayList"
ArrayListHeaderText.TextColor3 = Color3.new(1, 1, 1)
ArrayListHeaderText.TextSize = 20
ArrayListHeaderText.TextXAlignment = Enum.TextXAlignment.Center
ArrayListHeaderText.Parent = ArrayListHeader

local ArrayListDisplay = Instance.new("Frame")
ArrayListDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
ArrayListDisplay.BackgroundTransparency = 1
ArrayListDisplay.BorderSizePixel = 0
ArrayListDisplay.BorderColor3 = Color3.new(0, 0, 0)
ArrayListDisplay.Position = UDim2.new(0, 0, 0, 25)
ArrayListDisplay.Size = UDim2.new(0, 250, 0, 0)
ArrayListDisplay.AutomaticSize = Enum.AutomaticSize.Y
ArrayListDisplay.ZIndex = 10
ArrayListDisplay.Parent = ArrayListContainer

local ArrayListLayout = Instance.new("UIListLayout")
ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayListLayout.Padding = UDim.new(0, 0)
ArrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ArrayListLayout.Parent = ArrayListDisplay

local function RefreshArrayList()
	for _, v in pairs(ArrayListDisplay:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end

	table.sort(ActiveModules, function(a, b)
		return GetTextWidth(a) > GetTextWidth(b)
	end)

	local IsArrayListOnRight = (ArrayListContainer.AbsolutePosition.X + ArrayListContainer.AbsoluteSize.X / 2) > (ScreenGui.AbsoluteSize.X / 2)

	if IsArrayListOnRight then
		ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	else
		ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	end

	for _, ModuleName in ipairs(ActiveModules) do
		local ActiveModule = Instance.new("TextLabel")
		ActiveModule.BackgroundColor3 = Color3.new(0, 0, 0)
		ActiveModule.BackgroundTransparency = 1
		ActiveModule.BorderColor3 = Color3.new(0, 0, 0)
		ActiveModule.BorderSizePixel = 0
		ActiveModule.Font = Enum.Font.Sarpanch
		ActiveModule.Size = UDim2.new(0, 0, 0, 20)
		ActiveModule.Text = ModuleName
		ActiveModule.TextColor3 = Color3.new(1, 1, 1)
		ActiveModule.TextSize = 20
		ActiveModule.TextStrokeTransparency = 0.5
		ActiveModule.TextTransparency = 0
		ActiveModule.TextWrapped = false
		if IsArrayListOnRight then
			ActiveModule.TextXAlignment = Enum.TextXAlignment.Right
		else
			ActiveModule.TextXAlignment = Enum.TextXAlignment.Left
		end
		ActiveModule.AutomaticSize = Enum.AutomaticSize.X
		ActiveModule.Parent = ArrayListDisplay
	end
end

local NotificationsFolder = Instance.new("Folder")
NotificationsFolder.Parent = ScreenGui

local NotificationsContainer = Instance.new("Frame")
NotificationsContainer.BackgroundColor3 = Color3.new(0, 0, 0)
NotificationsContainer.BackgroundTransparency = 1
NotificationsContainer.BorderSizePixel = 0
NotificationsContainer.BorderColor3 = Color3.new(0, 0, 0)
NotificationsContainer.Size = UDim2.new(1, 0, 1, 0)
NotificationsContainer.Visible = false
NotificationsContainer.Parent = NotificationsFolder

local function RepositionNotifications()
	for i, Data in ipairs(ActiveNotifications) do
		local y = -80 - ((i - 1) * 70)
		Data.y = y
		Data.frame:TweenPosition(UDim2.new(1, -10, 1, y), "Out", "Quad", 0.2, true)
	end
RepositionNotifications() -- Initial call to position notifications if any exist
end

function SendNotification(Title, Message, Duration)
	if not NotificationsEnabled then
        return
    end

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

local TargetHUDContainer = Instance.new("Frame")
TargetHUDContainer.BackgroundColor3 = Color3.new(0, 0, 0)
TargetHUDContainer.BackgroundTransparency = 1
TargetHUDContainer.BorderSizePixel = 0
TargetHUDContainer.BorderColor3 = Color3.new(0, 0, 0)
TargetHUDContainer.Position = UDim2.new(0.5, -125, 0, 775)
TargetHUDContainer.Size = UDim2.new(0, 250, 0, 75 + 25)
TargetHUDContainer.Visible = false
TargetHUDContainer.Parent = TargetHUDFolder

local TargetHUDHeader = Instance.new("Frame")
TargetHUDHeader.BackgroundColor3 = Color3.new(0, 0, 0)
TargetHUDHeader.BackgroundTransparency = 0.25
TargetHUDHeader.BorderSizePixel = 0
TargetHUDHeader.BorderColor3 = Color3.new(0, 0, 0)
TargetHUDHeader.Size = UDim2.new(1, 0, 0, 25)
TargetHUDHeader.Position = UDim2.new(0, 0, 0, 0)
TargetHUDHeader.Parent = TargetHUDContainer

local TargetHUDHeaderText = Instance.new("TextLabel")
TargetHUDHeaderText.BackgroundTransparency = 1
TargetHUDHeaderText.BorderSizePixel = 0
TargetHUDHeaderText.BorderColor3 = Color3.new(0, 0, 0)
TargetHUDHeaderText.Size = UDim2.new(1, 0, 1, 0)
TargetHUDHeaderText.Font = Enum.Font.Sarpanch
TargetHUDHeaderText.Text = "Target"
TargetHUDHeaderText.TextColor3 = Color3.new(1, 1, 1)
TargetHUDHeaderText.TextSize = 20
TargetHUDHeaderText.TextXAlignment = Enum.TextXAlignment.Center
TargetHUDHeaderText.Parent = TargetHUDHeader

local TargetHUD = Instance.new("Frame")
TargetHUD.BackgroundColor3 = Color3.new(0, 0, 0)
TargetHUD.BackgroundTransparency = 0.5
TargetHUD.BorderSizePixel = 0
TargetHUD.BorderColor3 = Color3.new(0, 0, 0)
TargetHUD.Position = UDim2.new(0, 0, 0, 25)
TargetHUD.Size = UDim2.new(0, 250, 0, 75)
TargetHUD.Parent = TargetHUDContainer

local TargetPhoto = Instance.new("ImageLabel")
TargetPhoto.BackgroundTransparency = 1
TargetPhoto.BorderSizePixel = 0
TargetPhoto.BorderColor3 = Color3.new(0, 0, 0)
TargetPhoto.Position = UDim2.new(0, 10, 0, 12)
TargetPhoto.Size = UDim2.new(0, 50, 0, 50)
TargetPhoto.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
TargetPhoto.Parent = TargetHUD

local TargetName = Instance.new("TextLabel")
TargetName.BackgroundTransparency = 1
TargetName.BorderSizePixel = 0
TargetName.BorderColor3 = Color3.new(0, 0, 0)
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
HPBG.BorderColor3 = Color3.new(0, 0, 0)
HPBG.Position = UDim2.new(0.275, 0, 0.5, 0)
HPBG.Size = UDim2.new(0, 150, 0, 10)
HPBG.Parent = TargetHUD

local HPBar = Instance.new("Frame")
HPBar.BackgroundColor3 = Color3.new(0, 0, 0)
HPBar.BorderSizePixel = 0
HPBar.BorderColor3 = Color3.new(0, 0, 0)
HPBar.Position = UDim2.new(0, 0, 0, 0)
HPBar.Size = UDim2.new(0, 0, 1, 0)
HPBar.Parent = HPBG

local function MakeDraggable(UIElement, DragHandle)
    local Dragging = false
    local DragStart, StartPosition

    DragHandle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if (DragHandle == TargetHUDHeader or DragHandle == ArrayListHeader) and not GUIVisible then
                return
            end

            Dragging = true
            DragStart = Input.Position
            StartPosition = UIElement.Position
            
            InputChangedConnection = UIS.InputChanged:Connect(function(InputChanged)
                if Dragging and InputChanged.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = InputChanged.Position - DragStart
                    UIElement.Position = UDim2.new(
                        StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                        StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
                    )
                    if UIElement == ArrayListContainer then
                        RefreshArrayList()
                    end
                end
            end)

            InputEndedConnection = UIS.InputEnded:Connect(function(InputEnded)
                if InputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    InputChangedConnection:Disconnect()
                    InputEndedConnection:Disconnect()
                end
            end)
        end
    end)
end

MakeDraggable(TargetHUDContainer, TargetHUDHeader)
MakeDraggable(ArrayListContainer, ArrayListHeader)

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
		ArrayListContainer.Visible = not ArrayListContainer.Visible
	else
		ArrayListContainer.Visible = State
	end
	ArrayListHeader.Visible = ArrayListContainer.Visible and GUIVisible
end

function Jello:ToggleNotifications(State)
    local NewState = State
    if NewState == nil then
        NewState = not NotificationsEnabled
    end
    
    if NotificationsEnabled == NewState or IsTogglingNotifications then
        return
    end

    local IsTogglingNotifications = true

    NotificationsEnabled = NewState

    if NotificationsEnabled then
        NotificationsContainer.Visible = true
        IsTogglingNotifications = false
    else
        task.spawn(function()
            while #ActiveNotifications > 0 do
                for i = #ActiveNotifications, 1, -1 do
                    local Data = ActiveNotifications[i]
                    if not Data.frame or not Data.frame.Parent then
                        table.remove(ActiveNotifications, i)
                    end
                end
                task.wait()
            end
            NotificationsContainer.Visible = false
            IsTogglingNotifications = false
        end)
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
					elseif GUIVisible then
						TargetName.Text = "Roblox"
						HPBar.Size = UDim2.new(1, 0, 1, 0)
						HPBar.BackgroundColor3 = Color3.new(0, 1, 0)
						TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
						ShouldShow = true
					end

					TargetHUDContainer.Visible = ShouldShow
					TargetHUDHeader.Visible = true 
				end
				TargetHUDContainer.Visible = false
				TargetHUDHeader.Visible = true 
				TargetHUDThread = nil
			end)
		end
	else
		TargetHUDEnabled = false
		TargetHUDContainer.Visible = false
		TargetHUDHeader.Visible = true
	end
end

local ModalButton = Instance.new("TextButton")
ModalButton.BackgroundColor3 = Color3.new(0, 0, 0)
ModalButton.BackgroundTransparency = 1
ModalButton.BorderSizePixel = 0
ModalButton.BorderColor3 = Color3.new(0, 0, 0)
ModalButton.Size = UDim2.new()
ModalButton.Text = ""
ModalButton.Visible = false
ModalButton.Modal = true
ModalButton.Parent = ScreenGui

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Enabled = false
BlurEffect.Size = 25
BlurEffect.Parent = game.Lighting

UIS.InputBegan:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.RightShift then
		GUIVisible = not GUIVisible
		BlurEffect.Enabled = GUIVisible
		ModalButton.Visible = GUIVisible
		TabsContainer.Visible = GUIVisible
		ArrayListHeader.Visible = ArrayListContainer.Visible and GUIVisible
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

	MakeDraggable(TabFrame, Header)

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
			if callback then
				callback(Enabled)
			end
			
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

			RefreshArrayList()
		ToggleModule()
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
						task.delay(1, function()
							Bind.Text = "Bind: None"
						end)
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
