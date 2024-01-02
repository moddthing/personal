repeat wait() until game:IsLoaded()

local function jumpToServer() 
local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true" 
local req = request({ Url = string.format(sfUrl, 15502339080, "Desc", 100) }) 
local body = game:GetService("HttpService"):JSONDecode(req.Body) 
local deep = math.random(1, 3)
if deep > 1 then 
    for i = 1, deep, 1 do 
        req = request({ Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, 15502339080, "Desc", 100) }) 
        body = game:GetService("HttpService"):JSONDecode(req.Body) 
        task.wait(0.1)
    end 
end 
local servers = {} 
if body and body.data then 
    for i, v in next, body.data do 
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end
    local randomCount = #servers
    if not randomCount then
        randomCount = 2
    end
    game:GetService("TeleportService"):TeleportToPlaceInstance(15502339080, servers[math.random(1, randomCount)], game:GetService("Players").LocalPlayer) 
end

while wait(1) do
    jumpToServer()
end
