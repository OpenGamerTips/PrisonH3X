local Version = "v1.1"

loadstring(game:HttpGet("https://bit.ly/gainownership"))()
local game_meta = getrawmetatable(game)
local game_index = game_meta.__index
setreadonly(game_meta, false)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = Player.Character
Player.CharacterAdded:Connect(function(Char)
    Character = Char
end)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaySound = ReplicatedStorage.SoundEvent
local PunchPlayer = ReplicatedStorage.meleeEvent
local ShootGun = ReplicatedStorage.ShootEvent

local RemoteFolder = workspace.Remote
local LoadCharacter = RemoteFolder.loadchar
local SwitchTeam = RemoteFolder.TeamEvent
local ItemHandler = RemoteFolder.ItemHandler

local Items = workspace["Prison_ITEMS"]
local Givers = Items.giver
local Singles = Items.single

local function InternalFunction_CopyCharacterDetails()
    local Humanoid = Character.Humanoid
    getgenv().__SavedData = {
        Humanoid = {
            WalkSpeed = Humanoid.WalkSpeed;
            JumpPower = Humanoid.JumpPower;
        };
        Items = {
            Backpack = {
                Player.Backpack:FindFirstChild("M9") and "M9";
                Player.Backpack:FindFirstChild("AK-47") and "AK-47";
                Player.Backpack:FindFirstChild("Remington 870") and "Remington 870";
            };
            Character = {
                Character:FindFirstChild("M9") and "M9";
                Character:FindFirstChild("AK-47") and "AK-47";
                Character:FindFirstChild("Remington 870") and "Remington 870";
            };
        };
    }

    local Gun = Player.Backpack:FindFirstChild("M9") or Player.Backpack:FindFirstChild("AK-47") or Player.Backpack:FindFirstChild("Remington 870") or Character:FindFirstChild("M9") or Character:FindFirstChild("AK-47") or Character:FindFirstChild("Remington 870") 
    if Gun then
        local Module = require(Gun.GunStates)
        if Module.__modded == true then
            __SavedData.Items.Mod = true
        end
    end
end

local function InternalFunction_ApplyCharacterDetails(SkipFF)
    if __SavedData then
        for Key, Value in pairs(__SavedData.Humanoid) do
            Character.Humanoid[Key] = Value
        end
       
        for Key, Value in pairs(__SavedData.Items.Backpack) do
            ItemHandler:InvokeServer(Givers[Value].ITEMPICKUP)
        end

        for Key, Value in pairs(__SavedData.Items.Character) do
            ItemHandler:InvokeServer(Givers[Value].ITEMPICKUP)
            Player.Backpack[Value].Parent = Character
        end

        if __SavedData.Items.Mod == true then
            ModifyGuns()
        end

        if not SkipFF then Character:WaitForChild("ForceField").Visible = false end
    end
end

local function InternalFunction_GetClosestPlayer(TargetDistance)
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not (Character or HumanoidRootPart) then return end

    local Target;
    for _, Victim in pairs(Players:GetPlayers()) do
        if Victim ~= Player and Victim.Character and Victim.Character:FindFirstChild("HumanoidRootPart") then
            local TargetHRP = Victim.Character.HumanoidRootPart
            local HRPMagnitude = (HumanoidRootPart.Position - TargetHRP.Position).Magnitude
            if HRPMagnitude < TargetDistance then
                TargetDistance = HRPMagnitude
                Target = Victim
            end
        end
    end

    return Target
end

local function InternalFunction_BecomeCriminal()
    local CrimSpawn = workspace["Criminals Spawn"].SpawnLocation
    local SavedLoc = CrimSpawn.CFrame
    CrimSpawn.CanCollide = false
    CrimSpawn.Transparency = 1
    CrimSpawn.CFrame = Character.HumanoidRootPart.CFrame
    wait(0.1)
    CrimSpawn.CanCollide = true
    CrimSpawn.Transparency = 0
    CrimSpawn.CFrame = SavedLoc
end

local function InternalFunction_ModifyGun(Gun)
    if Gun:IsA("Tool") and Gun:FindFirstChild("GunStates") then
        local States = require(Gun.GunStates)
        States.Damage = math.huge
        States.MaxAmmo = math.huge
        States.CurrentAmmo = math.huge
        States.StoredAmmo = math.huge
        States.FireRate = 0
        States.AutoFire = true
        States.Range = math.huge
        States.Spread = 0
        States.Bullets = 1
        States.ReloadTime = 0
        States.__modded = true

        return true
    else
        return false
    end
end

function GiveTools()
    ItemHandler:InvokeServer(Singles["Hammer"].ITEMPICKUP)
    for _, Tool in pairs(ReplicatedStorage.Tools:GetChildren()) do
        Tool:Clone().Parent = Player.Backpack
    end
end

function ModifyGuns()
    for _, Gun in pairs(Player.Backpack:GetChildren()) do
        InternalFunction_ModifyGun(Gun)
    end
    
    for _, Gun in pairs(Character:GetChildren()) do
        InternalFunction_ModifyGun(Gun)
    end
end

function SuperPunch(Off)
    Off = Off or false
    if __SuperPunchConnection then
        getgenv().__SuperPunchConnection:Disconnect()
    end
    
    if Off == false then
        getgenv().__SuperPunchConnection = InputService.InputBegan:Connect(function(Input, Processed)
            if Input.UserInputType == Enum.UserInputType.Keyboard and not Processed then
            local Key = Input.KeyCode
                if Key == Enum.KeyCode.F then
                    local Closest = InternalFunction_GetClosestPlayer(3.5)
                    if Closest then
                        local Punch = Character.Head.punchSound
                        Punch:Play()
                        PlaySound:FireServer(Punch) -- Replicate Sound
                        for _ = 1, 100 do
                            PunchPlayer:FireServer(Closest)
                        end
                    end
                end
            end
        end)
    end
end

function SuperSprint(Off)
    Off = Off or false
    getgenv().SavedWS = Character.Humanoid.WalkSpeed
    if __SuperSprintConnection1 and __SuperSprintConnection2 then
        getgenv().__SuperSprintConnection1:Disconnect()
        getgenv().__SuperSprintConnection2:Disconnect()
    end
    
    if Off == false then
        getgenv().__SuperSprintConnection1 = InputService.InputBegan:Connect(function(Input, P)
            if Input.UserInputType == Enum.UserInputType.Keyboard and not P then
            local Key = Input.KeyCode
                if Key == Enum.KeyCode.LeftShift or Key == Enum.KeyCode.RightShift then
                    getgenv().SavedWS = Character.Humanoid.WalkSpeed
                    TweenService:Create(Camera, TweenInfo.new(0.1), {
                        FieldOfView = 75;
                    }):Play()
                    wait(0.05) -- We beat clientinputhandler in this so a little delay fixes this.
                    Character.Humanoid.WalkSpeed = Character.Humanoid.WalkSpeed + 49
                end
            end
        end)
        
        getgenv().__SuperSprintConnection2 = InputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Keyboard then
            local Key = Input.KeyCode
                if Key == Enum.KeyCode.LeftShift or Key == Enum.KeyCode.RightShift then
                    TweenService:Create(Camera, TweenInfo.new(0.1), {
                        FieldOfView = 70;
                    }):Play()
                    wait(0.05)
                    Character.Humanoid.WalkSpeed = SavedWS
                end
            end
        end)
    end
end

function SetTeam(Name)
    if Name == "Bright red" then -- LOL you thought anti exploit.
        InternalFunction_BecomeCriminal()
    elseif Name == "Bright orange" or Name == "Bright blue" or Name == "Medium stone grey" then
        SwitchTeam:FireServer(Name)
    end
end

function Kill(Victim, SkipTeamSwitch)
    local Saved = Player.TeamColor.Name
    local Victeam = Victim.TeamColor.Name
    if Saved == Victeam then
        if Victeam == "Medium stone grey" then
            SwitchTeam:FireServer("Bright orange")
        else
            SwitchTeam:FireServer("Medium stone grey")
        end
    end

    ItemHandler:InvokeServer(Givers.M9.ITEMPICKUP)
    Victim = Victim.Character
    local Target = Victim.Head
    local Gun = Character:FindFirstChild("M9") or Player.Backpack:FindFirstChild("M9")
    for i = 1, 10 do
        ShootGun:FireServer(Gun, {
            {
				Cframe = Target.CFrame;
                Hit = Target;
                RayObject = Ray.new(Gun.Handle.Position, Target.Position);
                Distance = (Gun.Handle.Position - Target.Position).Magnitude;
            }
        })
    end
    if not SkipTeamSwitch then
        SetTeam(Saved)
    end
    
    return
end

function ForceCriminal(Victim, ReturnBack)
    InternalFunction_CopyCharacterDetails()
    local Saved = Character.HumanoidRootPart.CFrame
    Character.HumanoidRootPart.CFrame = CFrame.new(-923, 95, 2138) * CFrame.Angles(0, math.rad(-90), 0)
    BringPlayer(Victim, true)
    Character.HumanoidRootPart.CFrame = Saved
    InternalFunction_ApplyCharacterDetails()
    return
end

function RainCars()
    SetPrisonStatus("PrisonH3X: Spawning Cars", "Firing the remotes nessecary to spawn cars.")
    local Cars = workspace.CarContainer
    for _, CarBtn in pairs(Items.buttons:GetDescendants()) do
        if CarBtn.Name == "Car Spawner" and CarBtn:IsA("Part") then
            workspace.Remote.ItemHandler:InvokeServer(CarBtn)
        end
    end
    wait(1.5)
    for _, Car in pairs(Cars:GetChildren()) do
        Car:MoveTo(game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 20, 0))
        Car.Parent = workspace
    end
    SetPrisonStatus("PrisonH3X "..Version, "A Prison Life script library made by H3x0R (OpenGamerTips).")
end

function SetPrisonStatus(Status, Description)
    getgenv().__StatusCalled = true
    wait(0.05)
    getgenv().__StatusCalled = false
    coroutine.wrap(function()
        repeat
            Player.PlayerGui.Home.hud.Topbar.titleBar.Title.Text = Status
            Player.PlayerGui.Home.hud.Topbar.Pulldownmenu.Frame.Description.Text = Description
            RunService.RenderStepped:Wait()
        until __StatusCalled == true
    end)()
end

local NametagConnection;
function SetNametagColor(BrickColor) -- Only to a BrickColor.
    assert(typeof(BrickColor) == "BrickColor", "A BrickColor is required.")
    if NametagConnection then NametagConnection:Disconnect() end
    local Saved = Character.HumanoidRootPart.CFrame
    LoadCharacter:InvokeServer(Player.Name.." is weird", BrickColor.Name)
    
    local Hook = function()
        if Player.Team ~= nil then NametagConnection:Disconnect() end
        InternalFunction_CopyCharacterDetails()
        Saved = Character.HumanoidRootPart.CFrame
        Player.CharacterAdded:Wait()
        Character.HumanoidRootPart.CFrame = Saved
        NametagConnection = Character.Humanoid.Died:Connect(Hook)
        InternalFunction_ApplyCharacterDetails(true)
    end
    NametagConnection = Character.Humanoid.Died:Connect(Hook)

    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    Player.CharacterAdded:Wait(); wait(0.2)
    Character.HumanoidRootPart.CFrame = Saved
end

function GiveGuns()
    ItemHandler:InvokeServer(Givers.M9.ITEMPICKUP)
    ItemHandler:InvokeServer(Givers["AK-47"].ITEMPICKUP)
    ItemHandler:InvokeServer(Givers["Remington 870"].ITEMPICKUP)
    return
end

function GetKeyCard()
    if Singles:FindFirstChild("Key card") then
        ItemHandler:InvokeServer(Singles["Key card"].ITEMPICKUP)
    else
        SetPrisonStatus("PrisonH3X: Farming for keycards.", "There are no keycards to pick up. We are going to dropfarm for you.")
        local STeam = Player.TeamColor.Name
        local Saved = Character.HumanoidRootPart.CFrame
        InternalFunction_CopyCharacterDetails()
        repeat
            DropFarm(1, true, true)
        until Singles:FindFirstChild("Key card")
        LoadCharacter:InvokeServer(Player.Name, STeam)
        Character.HumanoidRootPart.CFrame = Saved
        InternalFunction_ApplyCharacterDetails()
        ItemHandler:InvokeServer(Singles["Key card"].ITEMPICKUP)
        
        SetPrisonStatus("PrisonH3X "..Version, "A Prison Life script library made by H3x0R (OpenGamerTips).")
    end
end

function KillAll()
    local Saved = Player.TeamColor.Name
    for _, Victim in pairs(Players:GetChildren()) do
        if Victim ~= Player then
            Kill(Victim, true)
        end
    end
    
    SetTeam(Saved)
end

function KillTeam(TeamName)
    local Saved = Player.TeamColor.Name
    for _, Victim in pairs(Players:GetChildren()) do
        if Victim ~= Player and Victim.TeamColor.Name == TeamName then
            Kill(Victim, true)
        end
    end
    
    SetTeam(Saved)
end

function Taze(Victim)
    local Tazer = Player.Backpack:FindFirstChild("Taser") or Character:FindFirstChild("Taser")
    if not Tazer then
        InternalFunction_CopyCharacterDetails()
        local Saved = Character.HumanoidRootPart.CFrame
        local STeam = Player.TeamColor.Name
        LoadCharacter:InvokeServer(Player.Name.." is a skid", "Bright blue")
        Character.HumanoidRootPart.CFrame = Saved
        SetTeam(STeam)
        InternalFunction_ApplyCharacterDetails()
    end
    
    ShootGun:FireServer(Tazer, {
        {
			Cframe = Victim.Character.HumanoidRootPart.CFrame;
            Hit = Victim.Character.HumanoidRootPart;
            RayObject = Ray.new(Tazer.Handle.Position, Victim.Character.HumanoidRootPart.Position);
            Distance = (Tazer.Handle.Position - Victim.Character.HumanoidRootPart.Position).Magnitude;
        }
    })
end

function ArrestCriminal(Victim)
    repeat
        Character.HumanoidRootPart.CFrame = Victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
        RemoteFolder.arrest:InvokeServer(Victim.Character.HumanoidRootPart)
        RunService.RenderStepped:Wait()
    until Victim.TeamColor.Name == "Bright orange"
end

function DropFarm(TimesToReset, SkipTeamChange, DontSaveData)
    if not DontSaveData then InternalFunction_CopyCharacterDetails() end
    local STeam = Player.TeamColor.Name
    local Saved = Character.HumanoidRootPart.CFrame
    if STeam ~= "Bright blue" then
        LoadCharacter:InvokeServer(Player.Name.." do be the epic hackerman", "Bright blue")
        Character.HumanoidRootPart.CFrame = Saved
    end
    
    for i = 1, TimesToReset do
        wait(0.2)
        Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        LoadCharacter:InvokeServer(Player.Name)
        Character.HumanoidRootPart.CFrame = Saved
    end
    
    if not SkipTeamChange then
        LoadCharacter:InvokeServer(Player.Name, STeam)
        Character.HumanoidRootPart.CFrame = Saved
    end
    if not DontSaveData then InternalFunction_ApplyCharacterDetails() end
end

function QuickReset(LoadData)
    if LoadData then InternalFunction_CopyCharacterDetails() end
    LoadCharacter:InvokeServer(Player.Name)
    if LoadData then InternalFunction_ApplyCharacterDetails() end
end

function GiveToolToPlayer(Tool, Plr, DontSaveData)
    Plr = Plr.Character
    if not DontSaveData then InternalFunction_CopyCharacterDetails() end
    local Saved = Character.HumanoidRootPart.CFrame
    
    local FakeHumanoid = Character.Humanoid:Clone()
    Character.Humanoid.Name = "_Humanoid"
    FakeHumanoid.Parent = Character
    wait(0.1)
    Character._Humanoid:Destroy()
    Character.Animate.Disabled = true
    
    workspace.CurrentCamera.CameraSubject = Character
    FakeHumanoid.DisplayDistanceType = "None"
    
    Tool.Parent = Character
    Character.HumanoidRootPart.CFrame = Plr.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-50, 50) / 200, math.random(-50, 50) / 200, math.random(-50, 50) / 200)
    repeat
        Character.HumanoidRootPart.CFrame = Plr.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.5)
        RunService.RenderStepped:Wait()
    until Tool.Parent == Plr or Plr.Humanoid.Seated == true or Plr.Humanoid.Health < 0.1
    LoadCharacter:InvokeServer()
    Character.HumanoidRootPart.CFrame = Saved
    if not DontSaveData then InternalFunction_ApplyCharacterDetails() end
end

function BringPlayer(Plr, DontSaveData)
    Plr = Plr.Character
    if not DontSaveData then InternalFunction_CopyCharacterDetails() end
    ItemHandler:InvokeServer(Givers["Remington 870"].ITEMPICKUP)
    local Tool = Player.Backpack["Remington 870"] or Character["Remington 870"]
    local Saved = Character.HumanoidRootPart.CFrame
    
    local FakeHumanoid = Character.Humanoid:Clone()
    Character.Humanoid.Name = "_Humanoid"
    FakeHumanoid.Parent = Character
    wait(0.1)
    Character._Humanoid:Destroy()
    Character.Animate.Disabled = true
    
    workspace.CurrentCamera.CameraSubject = Character
    FakeHumanoid.DisplayDistanceType = "None"
    
    Tool.Parent = Character
    Character.HumanoidRootPart.CFrame = Plr.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-50, 50) / 200, math.random(-50, 50) / 200, math.random(-50, 50) / 200)
    repeat
        Character.HumanoidRootPart.CFrame = Plr.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.5)
        RunService.RenderStepped:Wait()
    until Tool.Parent == Plr or Plr.Humanoid.Seated == true or Plr.Humanoid.Health < 0.1
    wait(0.1)
    for i = 1, 10 do
        Character.HumanoidRootPart.CFrame = Saved
        wait(0.1)
    end
    LoadCharacter:InvokeServer()
    Character.HumanoidRootPart.CFrame = Saved
    if not DontSaveData then InternalFunction_ApplyCharacterDetails() end
end

function GiveGunsToPlayer(Plr)
    SetPrisonStatus("PrisonH3X: Giving Guns", "Using claim to give guns to a player.")
    ItemHandler:InvokeServer(Givers.M9.ITEMPICKUP)
    GiveToolToPlayer(Player.Backpack["M9"], Plr)
    ItemHandler:InvokeServer(Givers["AK-47"].ITEMPICKUP)
    GiveToolToPlayer(Player.Backpack["AK-47"], Plr)
    ItemHandler:InvokeServer(Givers["Remington 870"].ITEMPICKUP)
    GiveToolToPlayer(Player.Backpack["Remington 870"], Plr)
    Camera.CameraSubject = Character.Humanoid
    SetPrisonStatus("PrisonH3X "..Version, "A Prison Life script library made by H3x0R (OpenGamerTips).")
end

function GodMode(Off)
    if __GodModeConnection then
        __GodModeConnection:Disconnect()
    end

    if not Off then
        local Hook = function()
            InternalFunction_CopyCharacterDetails()
            Saved = Character.HumanoidRootPart.CFrame
            Player.CharacterAdded:Wait()
            Character.HumanoidRootPart.CFrame = Saved
            getgenv().__GodModeConnection = Character.Humanoid.Died:Connect(Hook)
            wait(0.5)
            InternalFunction_ApplyCharacterDetails()
        end
        getgenv().__GodModeConnection = Character.Humanoid.Died:Connect(Hook)
    end
end

SetPrisonStatus("PrisonH3X "..Version, "A Prison Life script library made by H3x0R (OpenGamerTips).")
local Module = {}
-- load global functions into module
for Key, Value in pairs(getfenv()) do 
    if type(Value) == "function" then
        Module[Key] = Value
    end
end

return Module
