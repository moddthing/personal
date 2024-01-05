--[[
Credits List
ethereum: creating the base sniper
chocolog: providing type.huge
Edmond: offered tips for optimization
]]--

local osclock = os.clock()
if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(10) -- i hate library loading

setfpscap(10)
game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
game:GetService("RunService"):Set3dRenderingEnabled(false)
local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")
local Players = game:GetService('Players')
local getPlayers = Players:GetPlayers()
local PlayerInServer = #getPlayers
local http = game:GetService("HttpService")
local ts = game:GetService("TeleportService")
local rs = game:GetService("ReplicatedStorage")
local snipeNormal
local Library = require(rs:WaitForChild("Library"))

if not snipeNormalPets then
    snipeNormalPets = false
end

local vu = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   task.wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local function processListingInfo(uid, gems, item, version, shiny, amount, boughtFrom, boughtStatus, class, failMessage, snipeNormal)
    local gemamount = Players.LocalPlayer.leaderstats["💎 Diamonds"].Value
    local snipeMessage ="||".. Players.LocalPlayer.Name .. "||"
    local weburl, webContent, webcolor
    local versionVal = { [1] = "Golden ", [2] = "Rainbow " }
    local versionStr = versionVal[version] or (version == nil and "")
    local mention = (string.find(item, "Huge") or string.find(item, "Titanic")) and "<@" .. userid .. ">" or ""
	
    if boughtStatus then
	webcolor = tonumber(0x00ff00)
	weburl = webhook
        snipeMessage = snipeMessage .. " just sniped ".. Library.Functions.Commas(amount) .."x "
        webContent = mention
	if snipeNormal == true then
	    weburl = normalwebhook
	    snipeNormal = false
	end
    else
	webContent = failMessage
	webcolor = tonumber(0xff0000)
	weburl = webhookFail
	snipeMessage = snipeMessage .. " failed to snipe ".. Library.Functions.Commas(amount) .."x "
	if snipeNormal == true then
	    weburl = normalwebhook
	    snipeNormal = false
	end
    end
    
    snipeMessage = snipeMessage .. "**" .. versionStr
    
    if shiny then
        snipeMessage = snipeMessage .. " Shiny "
    end
    
    snipeMessage = snipeMessage .. item .. "**"
    
    local message1 = {
        ['content'] = webContent,
        ['embeds'] = {
            {
		["author"] = {
			["name"] = "Luna 🌚",
			["icon_url"] = "https://cdn.discordapp.com/attachments/1149218291957637132/1190527382583525416/new-moon-face_1f31a.png?ex=65a22006&is=658fab06&hm=55f8900eef039709c8e57c96702f8fb7df520333ec6510a81c31fc746193fbf2&",
		},
                ['title'] = snipeMessage,
                ["color"] = webcolor,
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "__Price:__",
                        ['value'] = Library.Functions.ParseNumberSmart(gems) .. " 💎",
                    },
                    {
                        ['name'] = "__Bought from:__",
                        ['value'] = "||"..tostring(boughtFrom).."|| ",
                    },
                    {
                        ['name'] = "__Amount:__",
                        ['value'] = Library.Functions.Commas(amount) .. "x",
                    },
                    {
                        ['name'] = "__Remaining gems:__",
                        ['value'] = Library.Functions.ParseNumberSmart(gemamount) .. " 💎",
                    },      
                    {
                        ['name'] = "__PetID:__",
                        ['value'] = "||"..tostring(uid).."||",
                    },
                },
		["footer"] = {
                        ["icon_url"] = "https://cdn.discordapp.com/attachments/1149218291957637132/1190527382583525416/new-moon-face_1f31a.png?ex=65a22006&is=658fab06&hm=55f8900eef039709c8e57c96702f8fb7df520333ec6510a81c31fc746193fbf2&", -- optional
                        ["text"] = "Heavily Modified by Root"
		}
            },
        }
    }

    local jsonMessage = http:JSONEncode(message1)
    local success, webMessage = pcall(function()
	http:PostAsync(weburl, jsonMessage)
    end)
    if success == false then
        local response = request({
            Url = weburl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonMessage
        })
    end
end

local function tryPurchase(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
    if buytimestamp > listTimestamp then
      task.wait(3.4 - Players.LocalPlayer:GetNetworkPing())
    end
    local boughtPet, boughtMessage = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    processListingInfo(uid, gems, item, version, shiny, amount, username, boughtPet, class, boughtMessage, snipeNormal)
end

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
        if type(message) == "table" then
            local highestTimestamp = -math.huge -- Initialize with the smallest possible number
            local key = nil
            local listing = nil
            for v, value in pairs(message["Listings"] or {}) do
                if type(value) == "table" and value["ItemData"] and value["ItemData"]["data"] then
                    local timestamp = value["Timestamp"]
                    if timestamp > highestTimestamp then
                        highestTimestamp = timestamp
                        key = v
                        listing = value
                    end
                end
            end
            if listing then
                local buytimestamp = listing["ReadyTimestamp"]
                local listTimestamp = listing["Timestamp"]
                local data = listing["ItemData"]["data"]
                local gems = tonumber(listing["DiamondCost"])
                local uid = key
                local item = data["id"]
                local version = data["pt"]
                local shiny = data["sh"]
                local amount = tonumber(data["_am"]) or 1
                local playerid = message['PlayerID']
                local class = tostring(listing["ItemData"]["class"])
                local unitGems = gems/amount
		snipeNormal = false
                                 
                if string.find(item, "Huge") and unitGems <= 100000 then
                    coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                    return
		elseif string.find(item, "Charm") and unitGems <= 30000 then
                    coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                    return
                elseif snipeNormalPets == true and gems == 1 then
                        snipeNormal = true
		        coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp,   snipeNormal)
                        return
                elseif class == "Pet" then
                    local type = Library.Directory.Pets[item]
                    if type.exclusiveLevel and unitGems <= 15000 and item ~= "Banana" and item ~= "Coin" then
                        coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                        return
                    elseif type.titanic and unitGems <= 10000000 then
			coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                        return
                    elseif type.huge and unitGems <= 1000000 then
			coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                        return
		    end
                elseif (item == "Titanic Christmas Present" or string.find(item, "2024 New Year")) and unitGems <= 30000 then
                    coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                    return
		elseif class == "Charm" and unitGems <= 30000 then
		    if not string.find(item, "Coins") and not string.find(item, "Agility") and not string.find(item, "Bonus") then
                    	coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                    	return
	            end
                elseif class == "Egg" and unitGems <= 30000 then
                    coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                    return
                elseif ((string.find(item, "Key") and not string.find(item, "Lower")) or string.find(item, "Ticket")) and unitGems <= 2500 then 
                    coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                    return
                elseif class == "Enchant" and unitGems <= 30000 then
                    if item == "Fortune" then 
                        coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                        return
                    elseif string.find(item, "Chest Mimic") then
                        coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                        return
                    elseif item == "Lucky Block" then
                        coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                        return
                    elseif item == "Massive Comet" then
                        coroutine.wrap(tryPurchase)(uid, gems, item, version, shiny, amount, username, class, playerid, buytimestamp, listTimestamp, snipeNormal)
                        return
                    end
                end
            end
        end
    end)

local function jumpToServer() 
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true" 
    local req = request({ Url = string.format(sfUrl, 15502339080, "Desc", 100) }) 
    local body = http:JSONDecode(req.Body) 
    local deep = math.random(1, 3)
    if deep > 1 then 
        for i = 1, deep, 1 do 
             req = request({ Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, 15502339080, "Desc", 100) }) 
             body = http:JSONDecode(req.Body) 
             task.wait(0.1)
        end 
    end 
    local servers = {} 
    if body and body.data then 
        for i, v in next, body.data do 
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
    end
    local randomCount = #servers
    if not randomCount then
       randomCount = 2
    end
    ts:TeleportToPlaceInstance(15502339080, servers[math.random(1, randomCount)], game:GetService("Players").LocalPlayer) 
end

if PlayerInServer < 25 then
    while task.wait(1) do
	jumpToServer()
    end
end

for i = 1, PlayerInServer do
   for ii = 1,#alts do
        if getPlayers[i].Name == alts[ii] and alts[ii] ~= Players.LocalPlayer.Name then
            while task.wait(1) do
		jumpToServer()
	    end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    getPlayers = Players:GetPlayers()
    PlayerInServer = #getPlayers
    if PlayerInServer < 25 then
        while task.wait(1) do
	    jumpToServer()
	end
    end
end) 

Players.PlayerAdded:Connect(function(player)
    for i = 1,#alts do
        if player.Name == alts[i] and alts[i] ~= Players.LocalPlayer.Name then
	    task.wait(math.random(0, 60))
            while task.wait(1) do
	        jumpToServer()
	    end
        end
    end
end) 

local hopDelay = math.random(840, 1140)

while task.wait(1) do
    if math.floor(os.clock() - osclock) >= hopDelay then
        while task.wait(1) do
	    jumpToServer()		
	end	
    end
end
