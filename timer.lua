local startTime = 0
local isPlaying = false
local serverHopTime = os.time() + math.random(720, 920)
local hopWarningTime = 60
local isHopScheduled = false

local hopTimer = 0
local hopMessage = ""

RegisterCommand("playtime", function()
    isPlaying = not isPlaying
end, false)

RegisterNetEvent('playerConnecting')
AddEventHandler('playerConnecting', function()
    startTime = os.time()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        TriggerEvent('displayPlaytime')
        updateHopTimer()
        TriggerEvent('displayHopTimer')
    end
end)

RegisterNetEvent('displayPlaytime')
AddEventHandler('displayPlaytime', function()
    if isPlaying then
        local currentTime = os.time()
        local playtime = currentTime - startTime
        local hours = math.floor(playtime / 3600)
        local minutes = math.floor((playtime % 3600) / 60)
        local seconds = playtime % 60

        SetTextFont(4)
        SetTextProportional(0)
        SetTextScale(2.0, 2.0)
        SetTextColour(0, 0, 0, 255)  -- Dark color (black)

        -- New: Make the text bold and bring it to the front
        SetTextOutline()
        SetTextDropshadow(2, 2, 0, 0, 0)  -- Offset and color for drop shadow

        SetTextEntry('STRING')
        AddTextComponentString('^2Your playtime:^7 ' .. hours .. ' hours, ' .. minutes .. ' minutes, and ' .. seconds .. ' seconds.')
        
        -- New: Set the render ID to ensure text is brought to the front
        SetTextRenderId(1)
        DrawText(0.95, 0.05)
        SetTextRenderId(0)  -- Reset the render ID
    end
end)

RegisterNetEvent('displayHopTimer')
AddEventHandler('displayHopTimer', function()
    if isHopScheduled then
        SetTextFont(4)
        SetTextProportional(0)
        SetTextScale(2.0, 2.0)
        SetTextColour(255, 0, 0, 255)  -- Dark color (red)

        -- New: Make the text bold and bring it to the front
        SetTextOutline()
        SetTextDropshadow(2, 2, 0, 0, 0)  -- Offset and color for drop shadow

        SetTextEntry('STRING')
        AddTextComponentString('^1Server hop in ' .. hopTimer .. 's^7')
        
        -- New: Set the render ID to ensure text is brought to the front
        SetTextRenderId(1)
        DrawText(0.95, 0.1)
        SetTextRenderId(0)  -- Reset the render ID
    end
end)

function updateHopTimer()
    local currentTime = os.clock()

    if currentTime >= serverHopTime - hopWarningTime and not isHopScheduled then
        displayHopNotification()
        isHopScheduled = true
    end

    if currentTime >= serverHopTime then
        jumpToServer()
        serverHopTime = currentTime + math.random(720, 920)
        isHopScheduled = false
    else
        hopTimer = math.ceil(serverHopTime - currentTime)
    end
end

