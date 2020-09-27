local Version = "v1.0"

loadstring(game:HttpGet("https://bit.ly/robloxownership"))()
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

function GiveTools()
    ItemHandler:InvokeServer(Singles["Hammer"].ITEMPICKUP)
    for _, Tool in pairs(ReplicatedStorage.Tools:GetChildren()) do
        Tool:Clone().Parent = Player.Backpack
    end
end

local function InternalFunction_ModifyGun(Gun)
    if Gun:IsA("Tool") and Gun:FindFirstChild("GunStates") then
        local States = require(Gun.GunStates)
        States.Damage = math.huge
        States.MaxAmmo = 1337
        States.CurrentAmmo = math.huge
        States.StoredAmmo = math.huge
        States.FireRate = 0
        States.AutoFire = true
        States.Range = math.huge
        States.Spread = 0
        States.Bullets = 10
        States.ReloadTime = 0
        
        return true
    else
        return false
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

function SuperPunch()
    if __SuperPunchConnection then
        getgenv().__SuperPunchConnection:Disconnect()
    end
    
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

function SuperSprint()
    getgenv().SavedWS = Character.Humanoid.WalkSpeed
    if __SuperSprintConnection1 and __SuperSprintConnection2 then
        getgenv().__SuperSprintConnection1:Disconnect()
        getgenv().__SuperSprintConnection2:Disconnect()
    end
    
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

function SetTeam(Name)
    if Name == "Bright red" then -- LOL you thought anti exploit.
        local CrimSpawn = workspace["Criminals Spawn"].SpawnLocation
        CrimSpawn.Size = Vector3.new(1, 1, 1)
        CrimSpawn.CanCollide = false
        CrimSpawn.Transparency = 1
        CrimSpawn.CFrame = Character.HumanoidRootPart.CFrame
        wait(0.1)
        CrimSpawn.CFrame = CFrame.new(0, 9e9, 0)
    elseif Name == "Bright orange" or Name == "Bright blue" then
        SwitchTeam:FireServer(Name)
    end
end

function Kill(Victim, SkipTeamSwitch)
    local Saved = Player.TeamColor.Name
    SwitchTeam:FireServer("Medium stone grey")
    ItemHandler:InvokeServer(Givers.M9.ITEMPICKUP)
    Victim = Victim.Character
    local Target = Victim.Head
    local Gun = Character:FindFirstChild("M9") or Player.Backpack:FindFirstChild("M9")
    for i = 1, 10 do
        ShootGun:FireServer({
            {
                RayObject = Ray.new(Vector3.new(), Vector3.new());
                Distance = 5;
                CFrame = Target.CFrame;
                Hit = Target;
            }
        }, 
        Gun)
    end
    if not SkipTeamSwitch then
        SetTeam(Saved)
    end
    
    return
end

function ForceCriminal(Victim, ReturnBack)
    SetPrisonStatus("PrisonH3X: Forcing", "Forcing criminal with network ownership.")
    Character.Humanoid.Sit = true
    local Saved = Instance.new("Part")
    Saved.CFrame = Character.HumanoidRootPart.CFrame
        
    local CrimSpawn = workspace["Criminals Spawn"].SpawnLocation
    CrimSpawn.Size = Vector3.new(1, 1, 1)
    CrimSpawn.CanCollide = false
    CrimSpawn.Transparency = 1
            
    local Team = Victim.TeamColor.Name
    if Team == "Really red" then
        CrimSpawn.CFrame = Character.HumanoidRootPart.CFrame
    else
        RemoteFolder.TeamEvent:FireServer(Team)
    end
    wait(0.1)
    
    local Did;
    repeat
        Did = pcall(function()
            if Victim.Character.Humanoid.Health > 0 and not Victim.Character:FindFirstChildOfClass("ForceField") then
                Character.HumanoidRootPart.CFrame = Victim.Character.Torso.CFrame * CFrame.new(0, 0, 1)
            else
                if Victim.Character:FindFirstChildOfClass("ForceField") then
                    SetPrisonStatus("PrisonH3X: Cooldown", "Waiting for the victim to respawn.")
                    Character.HumanoidRootPart.CFrame = CFrame.new(0, 9e9, 0)
                else 
                    SetPrisonStatus("PrisonH3X: Attempting", "Attempting to claim user on the network and set the team.")
                    for i = 1, 100 do
                        if Victim.TeamColor.Name == "Really red" then break end
                        Character.HumanoidRootPart.CFrame = Victim.Character.Torso.CFrame
                        wait(0.01)
                    end
                    
                    Character.HumanoidRootPart.CFrame = CFrame.new(0, 9e9, 0)
                end
            end
            
            CrimSpawn.CFrame = Victim.Character.HumanoidRootPart.CFrame
            ReplicatedStorage.meleeEvent:FireServer(Victim)
            RunService.RenderStepped:Wait()
        end)
    until Victim.TeamColor.Name == "Really red" or Did == false
    
    if ReturnBack ~= nil or ReturnBack ~= false then
        Character.HumanoidRootPart.CFrame = Saved.CFrame
    end
    
    Saved:Destroy()
    Character.Humanoid.Sit = false
    SetPrisonStatus("PrisonH3X "..Version, "A Prison Life script library made by H3x0R (OpenGamerTips).")
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
    Character.HumanoidRootPart.CFrame = Saved
    
    NametagConnection = Character.Humanoid.Died:Connect(function()
        if Player.Team ~= nil then NametagConnection:Disconnect() return end
        Saved = Character.HumanoidRootPart.CFrame
        Player.CharacterAdded:Wait()
        wait(0.1)
        Character.HumanoidRootPart.CFrame = Saved
    end)
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
        repeat
            DropFarm(1, true)
        until Singles:FindFirstChild("Key card")
        LoadCharacter:InvokeServer(Player.Name, STeam)
        Character.HumanoidRootPart.CFrame = Saved
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
        local Saved = Character.HumanoidRootPart.CFrame
        local STeam = Player.TeamColor.Name
        LoadCharacter:InvokeServer(Player.Name.." is a skid", "Bright blue")
        Character.HumanoidRootPart.CFrame = Saved
        SetTeam(STeam)
    end
    
    ShootGun:FireServer({
        {
            RayObject = Ray.new(Vector3.new(), Vector3.new());
            Distance = 5;
            CFrame = Victim.Character.HumanoidRootPart.CFrame;
            Hit = Victim.Character.HumanoidRootPart;
        }
    }, 
    Tazer)
end

function ArrestCriminal(Victim)
    repeat
        Character.HumanoidRootPart.CFrame = Victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
        RemoteFolder.arrest:InvokeServer(Victim.Character.HumanoidRootPart)
        RunService.RenderStepped:Wait()
    until Victim.TeamColor.Name == "Bright orange"
end

function DropFarm(TimesToReset, SkipTeamChange)
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
end

function QuickReset()
    LoadCharacter:InvokeServer(Player.Name)
end

function GiveToolToPlayer(Tool, Plr)
    Plr = Plr.Character
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
end

function BringPlayer(Plr)
    Plr = Plr.Character
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

function Annoy(Victim)
    while wait(1) do
        PlaySound:FireServer(Victim.Character.Head.punchSound)
    end
end

SetPrisonStatus("PrisonH3X "..Version, "A Prison Life script library made by H3x0R (OpenGamerTips).")

local Module = {}
for Key, Value in pairs(getfenv()) do 
    if type(Value) == "function" then
        if Key ~= "ClaimOwnership" and Key ~= "RevokeOwnership" then
            Module[Key] = Value
        end
    end
end

return Module
