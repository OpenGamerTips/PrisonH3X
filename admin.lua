local PrisonH3X = loadstring(game:HttpGet("https://raw.githubusercontent.com/OpenGamerTips/PrisonH3X/master/module.lua"))()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local function SplitString(String, Seperator, IsSeperatorPattern)
    Seperator = Seperator or "%s"
    
    local Split = {}
    for Item in string.gmatch(String, ((IsSeperatorPattern == true or Seperator == "%s") and Seperator or "([^"..Seperator.."]+)")) do
        Split[#Split + 1] = Item
    end
    return Split
end

local function ParsePlayer(Name)
    Name = string.lower(Name)
    for _, Plr in pairs(Players:GetPlayers()) do
        if string.match(string.lower(Plr.Name), "^"..Name) then return Plr end
    end
    
    return "HALT_CMD"
end

local function ParseCommand(Cmd)
    if Cmd:sub(1, 1) == "." then
        Cmd = Cmd:sub(2)
        local Data = {
            Command = "";
            Arguments = {};
        }
        
        local UnparsedArgs = SplitString(Cmd, "[^%s]+", true)
        --print(UnparsedArgs[1], UnparsedArgs[2])
        Data.Command = string.lower(UnparsedArgs[1])
        UnparsedArgs[1] = nil
        for _, Value in pairs(UnparsedArgs) do
            if Value ~= nil then
                table.insert(Data.Arguments, string.lower(Value))
            end
        end
        
        return Data
    else
        return -1
    end
end

local isSuperPunch, isSprint = false, false
Player.Chatted:Connect(function(Message)
    local Data = ParseCommand(Message)
    if Data ~= -1 then -- If message is command...
        if Data.Command == "superpunch" or Data.Command == "sp" then
            if isSuperPunch == true then
                if __SuperPunchConnection then
                    __SuperPunchConnection:Disconnect()
                end
            else
                PrisonH3X.SuperPunch()
            end
            isSuperPunch = not isSuperPunch
        elseif Data.Command == "mod" then
            PrisonH3X.ModifyGuns()
        elseif Data.Command == "guns" then
            if #Data.Arguments == 1 then
                local Plr = ParsePlayer(Data.Arguments[1])
                if Plr == "HALT_CMD" then warn("Invalid Player!") return end
                PrisonH3X.GiveGunsToPlayer(Plr)
            else
                PrisonH3X.GiveGuns()
            end
        elseif Data.Command == "sprint" or Data.Command == "ss" then
            if isSprint == true then
                if __SuperSprintConnection1 and __SuperSprintConnection2 then
                    __SuperSprintConnection1:Disconnect()
                    __SuperSprintConnection2:Disconnect()
                end
            else
                PrisonH3X.SuperSprint()
            end
            isSprint = not isSprint
        elseif Data.Command == "setteam" then
            if Data.Arguments[1] == "cops" or Data.Arguments[1] == "guards" or Data.Arguments[1] == "brightblue" then
                PrisonH3X.SetTeam("Bright blue")
            elseif Data.Arguments[1] == "prisoners" or Data.Arguments[1] == "inmates" or Data.Arguments[1] == "brightorange" then 
                PrisonH3X.SetTeam("Bright orange")
            elseif Data.Arguments[1] == "criminals" or Data.Arguments[1] == "brightred" then
                PrisonH3X.SetTeam("Bright red")
            end
        elseif Data.Command == "kill" then
            if Data.Arguments[1] == "me" then
                Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            elseif Data.Arguments[1] == "all" or Data.Arguments[1] == "others" then
                PrisonH3X.KillAll()
            else
                local Plr = ParsePlayer(Data.Arguments[1])
                if Plr == "HALT_CMD" then warn("Invalid Player!") return end
                PrisonH3X.Kill(Plr)
            end
        elseif Data.Command == "criminal" then
            if (not Data.Arguments[1]) or (Data.Arguments[1] == "me") then
                PrisonH3X.SetTeam("Bright red")
            else
                local Plr = ParsePlayer(Data.Arguments[1])
                if Plr == "HALT_CMD" then warn("Invalid Player!") return end
                PrisonH3X.ForceCriminal(Plr, true)
            end
        elseif Data.Command == "raincars" then
            PrisonH3X.RainCars()
        elseif Data.Command == "tagcolor" or Data.Command == "nametagcolor" then
            if Data.Arguments[1] == "black" then
                PrisonH3X.SetNametagColor(BrickColor.new("Really black"))
            elseif Data.Arguments[1] == "green" then
                PrisonH3X.SetNametagColor(BrickColor.new("Lime green"))
            elseif Data.Arguments[1] == "yellow" then
                PrisonH3X.SetNametagColor(BrickColor.new("New Yeller"))
            elseif Data.Arguments[1] == "brown" then
                PrisonH3X.SetNametagColor(BrickColor.new("Reddish brown"))
            elseif Data.Arguments[1] == "white" then
                PrisonH3X.SetNametagColor(BrickColor.new("Pearl"))
            else
                warn("Invalid color")
            end
        elseif Data.Command == "card" or Data.Command == "keycard" then
            PrisonH3X.GetKeyCard()
        elseif Data.Command == "killteam" or Data.Command == "kteam" then
            if Data.Arguments[1] == "cops" or Data.Arguments[1] == "guards" or Data.Arguments[1] == "brightblue" then
                PrisonH3X.KillTeam("Bright blue")
            elseif Data.Arguments[1] == "prisoners" or Data.Arguments[1] == "inmates" or Data.Arguments[1] == "brightorange" then 
                PrisonH3X.KillTeam("Bright orange")
            elseif Data.Arguments[1] == "criminals" or Data.Arguments[1] == "brightred" then
                PrisonH3X.KillTeam("Bright red")
            end
        elseif Data.Command == "taze" or Data.Command == "t" then
            local Plr = ParsePlayer(Data.Arguments[1])
            if Plr == "HALT_CMD" then warn("Invalid Player!") return end
            PrisonH3X.Taze(Plr)
        elseif Data.Command == "arrest" or Data.Command == "arr" then
            local Plr = ParsePlayer(Data.Arguments[1])
            if Plr == "HALT_CMD" then warn("Invalid Player!") return end
            PrisonH3X.ArrestCriminal(Plr)
        elseif Data.Command == "r" or Data.Command == "reset" then
            PrisonH3X.QuickReset()
        elseif Data.Command == "rr" or Data.Command == "resetr" then
            local Saved = Player.Character.HumanoidRootPart.CFrame
            PrisonH3X.QuickReset()
            wait(0.1)
            Player.Character.HumanoidRootPart.CFrame = Saved
        elseif Data.Command == "tools" then
            PrisonH3X.GiveTools()
        elseif Data.Command == "gtool" or Data.Command == "givetool" then
            local Plr = ParsePlayer(Data.Arguments[1])
            if Plr == "HALT_CMD" then warn("Invalid Player!") return end
            PrisonH3X.GiveToolToPlayer(Plr)
        elseif Data.Command == "bring" then
            local Plr = ParsePlayer(Data.Arguments[1])
            if Plr == "HALT_CMD" then warn("Invalid Player!") return end
            PrisonH3X.BringPlayer(Plr)
        elseif Data.Command == "goto" then
            local Plr = ParsePlayer(Data.Arguments[1])
            if Plr == "HALT_CMD" then warn("Invalid Player!") return end
            Player.Character.HumanoidRootPart.CFrame = Plr.Character.HumanoidRootPart.CFrame
        elseif Data.Command == "jp" then
            Player.Character.Humanoid.JumpPower = Data.Arguments[1] or 50
        elseif Data.Command == "ws" then
            Player.Character.Humanoid.WalkSpeed = Data.Arguments[1] or 16
        elseif Data.Command == "serverhop" or Data.Command == "shop" then
            local BaseAPI = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="
            local ServerData = HttpService:JSONDecode(game:HttpGet(BaseAPI))
            local ServerJobIDs = {}
            while true do
                local NextPage = ServerData.nextPageCursor
                local Servers = ServerData.data
                for _, Server in pairs(Servers) do
                    if Server.playing < Server.maxPlayers then -- Able to be teleported to.
                        table.insert(ServerJobIDs, Server.id)
                    end
                end
                
                if NextPage then
                    ServerData = HttpService:JSONDecode(game:HttpGet(BaseAPI..NextPage))
                else
                    break
                end
            end
            
            TeleportService:TeleportToPlaceInstance(game.PlaceId, ServerJobIDs[#ServerJobIDs])
        end
    end
end)
