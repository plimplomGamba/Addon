---@diagnostic disable: undefined-global
---
--- Created by plimplom.
--- DateTime: 16/04/2025 11:13
---
PlimplomGamba = PlimplomGamba or {} -- Create global addon table if it doesn't exist
local plimplomGamba = PlimplomGamba
plimplomGamba.GameState = plimplomGamba.GameState or { status = 0, rollValue = 0, channel = "RAID" }
local frame = CreateFrame("Frame")

local strmatch = string.match

local eventGroups = {
    ["PARTY"] = {
        ["CHAT_MSG_PARTY"] = true,
        ["CHAT_MSG_PARTY_LEADER"] = true,
    },
    ["RAID"] = {
        ["CHAT_MSG_RAID"] = true,
        ["CHAT_MSG_RAID_LEADER"] = true,
    },
    ["SAY"] = {
        ["CHAT_MSG_SAY"] = true,
    },
}
function plimplomGamba.UpdateGameState(param)
    if (param == "RESET") then
        if plimplomGamba.GameState.status ~= 3 then
            sendMessageOrDebug(format("%s: Game has been reset.", plimplomGamba.Config.AddonName))
        end
        plimplomGamba.GameState.status = 0
        plimplomGamba.GameState.playerList = nil
        plimplomGamba.UpdateUI()
        return
    end

    if plimplomGamba.GameState.status == 2 and #plimplomGamba.GameState.playerList < 2 then
        return
    end

    plimplomGamba.GameState.status = plimplomGamba.GameState.status + 1
    if plimplomGamba.GameState.status == 1 then
        plimplomGamba.GameState.playerList = {}
        for event in pairs(eventGroups[plimplomGamba.GameState.channel]) do
            plimplomGamba.Debug(event)
            frame:RegisterEvent(event)
        end
        sendMessageOrDebug(format("%s: New game started! Current roll is for %sg, type 1 to enter (-1 to leave).",
            plimplomGamba.Config.AddonName, plimplomGamba.Utils.Comma(plimplomGamba.GameState.rollValue)))
    elseif plimplomGamba.GameState.status == 2 then
        sendMessageOrDebug(format("%s: Last call to enter!",
            plimplomGamba.Config.AddonName))
    elseif plimplomGamba.GameState.status == 3 then
        sendMessageOrDebug(format("%s: Game is now closed! Roll!",
            plimplomGamba.Config.AddonName))
        frame:RegisterEvent("CHAT_MSG_SYSTEM")
    end

    plimplomGamba.UpdateUI()
end

function sendMessageOrDebug(message)
    if plimplomGamba.debugMode then
        plimplomGamba.Debug(message)
    else
        SendChatMessage(message, plimplomGamba.GameState.channel, nil, nil)
    end
end

function plimplomGamba.UpdateDeathrollTracking(checkbox, frameToUpdate)
    SavedSettings["deathroll"] = checkbox:GetChecked()
    plimplomGamba.GameState.trackDeathrolls = checkbox:GetChecked()
    if checkbox:GetChecked() then
        frameToUpdate:Show()
        frameToUpdate:RegisterEvent("CHAT_MSG_SYSTEM")
    else
        frameToUpdate:Hide()
    end
end

function plimplomGamba.AddPlayer(playerName)
    if not plimplomGamba.GameState or plimplomGamba.GameState.status == 0 or plimplomGamba.GameState.status == 3 then
        return
    end
    if not plimplomGamba.GameState.playerList then
        plimplomGamba.GameState.playerList = {}
    end

    local found = plimplomGamba.Utils.IsPlayerInGame(playerName)

    if (not found) then
        plimplomGamba.GameState.playerList[#plimplomGamba.GameState.playerList + 1] = { name = playerName }
    end

    plimplomGamba.UpdateUI()
end

function plimplomGamba.RemovePlayer(playerName)
    if not plimplomGamba.GameState.playerList or plimplomGamba.GameState.status == 0 or plimplomGamba.GameState.status == 3 then
        return
    end
    for i = 1, #plimplomGamba.GameState.playerList do
        if (plimplomGamba.GameState.playerList[i].name == playerName) then
            tremove(plimplomGamba.GameState.playerList, i)
            break
        end
    end

    plimplomGamba.UpdateUI()
end

function plimplomGamba.UpdateRollValue(number, input)
    if not input then
        return
    end
    if not SavedSettings then
        SavedSettings = {}
    end

    SavedSettings["rollValue"] = number
    plimplomGamba.GameState.rollValue = number


    plimplomGamba.UpdateUI()
end

function plimplomGamba.AllPlayersRolled()
    if not plimplomGamba.GameState.playerList or #plimplomGamba.GameState.playerList < 2 then
        return false
    end
    for i = 1, #plimplomGamba.GameState.playerList do
        if not plimplomGamba.GameState.playerList[i].roll then
            return false
        end
    end
    return true
end

local function handleGameOver()
    local winner = plimplomGamba.GameState.playerList[1]
    local loser = plimplomGamba.GameState.playerList[#plimplomGamba.GameState.playerList]
    local diff = winner.roll - loser.roll

    if plimplomGamba.debugMode then
        plimplomGamba.Debug(format("%s: %s owes %s %s gold!", plimplomGamba.Config.AddonName, loser.name, winner.name,
            plimplomGamba.Utils.Comma(diff)))
        return
    end

    if (not GambleStats) then
        GambleStats = {}
    end
    if not GambleStats["HighLow"] then
        GambleStats["HighLow"] = {}
        GambleStats["HighLow"]["All"] = {}
        GambleStats["HighLow"]["Specific"] = {}
    end
    if not GambleStats["HighLow"]["All"] then
        GambleStats["HighLow"]["All"] = {}
    end
    if not GambleStats["HighLow"]["Specific"] then
        GambleStats["HighLow"]["Specific"] = {}
    end

    -- General information (Who's up, who's down)
    if (not GambleStats["HighLow"]["All"][winner.name]) then
        GambleStats["HighLow"]["All"][winner.name] = 0
    end

    if (not GambleStats["HighLow"]["All"][loser.name]) then
        GambleStats["HighLow"]["All"][loser.name] = 0
    end

    GambleStats["HighLow"]["All"][winner.name] = GambleStats["HighLow"]["All"][winner.name] + diff
    GambleStats["HighLow"]["All"][loser.name] = GambleStats["HighLow"]["All"][loser.name] - diff

    -- Detailed information (Who lost/gained how much from who specifically)
    if (not GambleStats["HighLow"]["Specific"][winner.name]) then
        GambleStats["HighLow"]["Specific"][winner.name] = {}
    end

    if (not GambleStats["HighLow"]["Specific"][loser.name]) then
        GambleStats["HighLow"]["Specific"][loser.name] = {}
    end

    if (not GambleStats["HighLow"]["Specific"][winner.name][loser.name]) then
        GambleStats["HighLow"]["Specific"][winner.name][loser.name] = 0
    end

    if (not GambleStats["HighLow"]["Specific"][loser.name][winner.name]) then
        GambleStats["HighLow"]["Specific"][loser.name][winner.name] = 0
    end

    GambleStats["HighLow"]["Specific"][winner.name][loser.name] = GambleStats["HighLow"]["Specific"][winner.name]
        [loser.name] +
        diff
    GambleStats["HighLow"]["Specific"][loser.name][winner.name] = GambleStats["HighLow"]["Specific"][loser.name]
        [winner.name] -
        diff

    SendChatMessage(
        format("%s: %s owes %s %s gold!", plimplomGamba.Config.AddonName, loser.name, winner.name,
            plimplomGamba.Utils.Comma(diff)),
        plimplomGamba.GameState.channel, nil, nil)

    plimplomGamba.GameState.playerList = nil
end

function plimplomGamba.HandlePlayerRoll(name, roll, min, max)
    if plimplomGamba.GameState.status ~= 3 then
        return
    end

    if (tonumber(min) == 1 and tonumber(max) == plimplomGamba.GameState.rollValue) then
        for i = 1, #plimplomGamba.GameState.playerList do
            if (plimplomGamba.GameState.playerList[i].name == name and not plimplomGamba.GameState.playerList[i].roll) then
                plimplomGamba.GameState.playerList[i].roll = roll
                break
            end
        end
    end

    table.sort(plimplomGamba.GameState.playerList, function(a, b)
        -- If both players have nil roll values, sort by another property or arbitrarily
        if a.roll == nil and b.roll == nil then
            return false -- Keep original order
        end

        -- If only a has nil rollValue, b should come first
        if a.roll == nil then
            return false
        end

        -- If only b has nil rollValue, a should come first
        if b.roll == nil then
            return true
        end

        -- Both have values, compare normally
        return tonumber(a.roll) > tonumber(b.roll)
    end)

    plimplomGamba.UpdateUI()

    if plimplomGamba.AllPlayersRolled() then
        handleGameOver()
    end
end

function plimplomGamba.OnAddonLoaded()
    -- Initialize saved variables
    PlimplomGamba = PlimplomGamba or {}

    -- Initialize settings
    local settings = plimplomGamba.InitializeSettings()

    plimplomGamba.GameState = {
        status = 0,
        rollValue = settings.rollValue,
        channel = "RAID",
        trackDeathrolls = settings.deathroll or false
    }

    if plimplomGamba.GameState.trackDeathrolls then
        frame:RegisterEvent("CHAT_MSG_SYSTEM")
    end

    -- Load UI
    plimplomGamba.InitializeUI()

    plimplomGamba.Debug("Debug mode is enabled, rolls will NOT be stored. NO messages will be sent to chat.")
end

local isPlayerRollingForGame = function(playerName, max)
    if (plimplomGamba.GameState.deathrolls[playerName] and plimplomGamba.GameState.deathrolls[playerName].currentRoll == max and plimplomGamba.GameState.deathrolls[playerName].lastRoller ~= playerName) then
        return playerName, false
    end

    for starter, data in pairs(plimplomGamba.GameState.deathrolls) do
        if (not data.opponent and data.currentRoll == max) then
            return starter, true
        elseif data.opponent == playerName and data.currentRoll == max then
            return starter, false
        end
    end

    return nil
end

local updateDeathRollStats = function(winner, loser, amount)
    if plimplomGamba.debugMode then
        plimplomGamba.Debug(format("%s: %s owes %s %s gold!", plimplomGamba.Config.AddonName, loser, winner,
            plimplomGamba.Utils.Comma(amount)))
        return
    end
    if not GambleStats then
        GambleStats = {}
        if not GambleStats["Deathroll"] then
            GambleStats["Deathroll"] = {}
        end
    end

    local timestamp = tostring(plimplomGamba.Utils.GetServerTimeRounded())

    GambleStats["Deathroll"][(timestamp .. ";" .. winner .. "-" .. loser)] = {
        winner = winner,
        loser = loser,
        amount =
            amount,
        timestamp = timestamp
    }

    SendChatMessage(
        format("%s: %s owes %s %s gold!", plimplomGamba.Config.AddonName, loser, winner,
            plimplomGamba.Utils.Comma(amount)),
        plimplomGamba.GameState.channel, nil, nil)
end

function plimplomGamba.HandleDeathrolls(name, roll, max)
    local minDeathRollAmount = SavedSettings["minDeathroll"] or 5000
    if not plimplomGamba.GameState.deathrolls then
        plimplomGamba.GameState.deathrolls = {}
    end

    local activeGame, joiningGame = isPlayerRollingForGame(name, tonumber(max))

    if (plimplomGamba.GameState.deathrolls[activeGame]) then
        if (joiningGame) then
            plimplomGamba.Debug(format("%s joined a deathroll from %s, deathroll amount is %d", name, activeGame,
                plimplomGamba.GameState.deathrolls[activeGame].deathRollAmount))
            plimplomGamba.GameState.deathrolls[activeGame].opponent = name
        end
        if (tonumber(roll) == 1) then
            plimplomGamba.Debug(format("%s owes %s %d gold.", name,
                plimplomGamba.GameState.deathrolls[activeGame].lastRoller,
                plimplomGamba.GameState.deathrolls[activeGame].deathRollAmount))
            updateDeathRollStats(plimplomGamba.GameState.deathrolls[activeGame].lastRoller, name,
                plimplomGamba.GameState.deathrolls[activeGame].deathRollAmount)
            plimplomGamba.GameState.deathrolls[activeGame] = nil
            plimplomGamba.UpdateUI()
            return
        end
        plimplomGamba.GameState.deathrolls[activeGame].currentRoll = tonumber(roll)
        plimplomGamba.GameState.deathrolls[activeGame].lastRoller = name
    elseif tonumber(max) >= minDeathRollAmount and tonumber(roll) > 1 and (not joiningGame) and (not (plimplomGamba.GameState.status == 3 and tonumber(max) ~= plimplomGamba.GameState.rollValue)) then
        plimplomGamba.Debug(format("%s started a deathroll with value %s, current val: %s", name, max, roll))
        plimplomGamba.GameState.deathrolls[name] = {
            opponent = nil,
            lastRoller = name,
            deathRollAmount = tonumber(max),
            currentRoll =
                tonumber(roll)
        }
    end

    plimplomGamba.UpdateUI()
end

-- Main event handler
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:SetScript("OnEvent", function(self, event, text, playerName, ...)
    if event == "ADDON_LOADED" and text == plimplomGamba.Config.AddonName then
        plimplomGamba.OnAddonLoaded()
    elseif eventGroups[plimplomGamba.GameState.channel][event] then
        local sender = strsplit("-", playerName) -- Remove server name.

        if (text == "1") then
            plimplomGamba.AddPlayer(sender)
        elseif (text == "-1") then
            plimplomGamba.RemovePlayer(sender)
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        local name, roll, min, max = strmatch(text, plimplomGamba.Config.RollMatch)

        if (not name or not roll or not min or not max) then
            return
        end

        if not ((tonumber(max) == plimplomGamba.GameState.rollValue) and plimplomGamba.GameState.status == 3) and plimplomGamba.GameState.trackDeathrolls then
            plimplomGamba.HandleDeathrolls(name, roll, max)
        end

        if plimplomGamba.GameState.status == 3 and plimplomGamba.GameState.playerList then
            plimplomGamba.HandlePlayerRoll(name, roll, min, max)
        end
    end
end)

local cmdList = {
    ["test"] = function(args)
        if plimplomGamba.Test then
            plimplomGamba.Test.Test(args)
        end
    end,
    ["testdr"] = function(args)
        if plimplomGamba.Test then
            plimplomGamba.Test.TestDeathrolls(args)
        end
    end,
    ["debug"] = function(_)
        print("|cFFFF6600plimplomGamba Debug:|r", plimplomGamba.debugMode and "disabled" or "enabled")
        plimplomGamba.debugMode = not plimplomGamba.debugMode
        if plimplomGamba.debugMode then

    plimplomGamba.Debug("Debug mode is enabled, rolls will NOT be stored. NO messages will be sent to chat.")
            end
    end,
}

SLASH_PLIMPLOMGAMBA1 = "/gamba"
SlashCmdList["PLIMPLOMGAMBA"] = function(cmd)
    local arg1 = plimplomGamba.Utils.CmdSplit(cmd)

    if cmdList[arg1] then
        cmdList[arg1](cmd)
    end
end
