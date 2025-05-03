---
--- Created by plimplom.
--- DateTime: 16/04/2025 11:12
---
PlimplomGamba = PlimplomGamba or {}
local plimplomGamba = PlimplomGamba
plimplomGamba.Utils = {}

local reverse = string.reverse
local split = strsplit
plimplomGamba.debugMode = true

function plimplomGamba.Debug(...)
    if plimplomGamba.debugMode then
        print("|cFFFF6600plimplomGamba Debug:|r", ...)
    end
end

-- Protected call wrapper
function plimplomGamba.Utils.SafeCall(func, ...)
    local success, errorMsg = pcall(func, ...)
    if not success then
        plimplomGamba.Debug("Error:", errorMsg)
    end
    return success
end

function plimplomGamba.Utils.Comma(number)
    if (not number) then
        return
    end

    if (type(number) ~= "number") then
        number = tonumber(number)
    end

    local number = format("%.0f", floor(number + 0.5))
    local left, number, _ = strmatch(number, "^([^%d]*%d)(%d+)(.-)$")

    return left and left .. reverse(gsub(reverse(number), "(%d%d%d)", "%1,")) or number
end

function plimplomGamba.Utils.IsPlayerInGame(playerName)
    if not plimplomGamba or not plimplomGamba.GameState or not plimplomGamba.GameState.playerList then
        return false
    end

    for i = 1, #plimplomGamba.GameState.playerList do
        if (plimplomGamba.GameState.playerList[i].name == playerName) then
            return true
        end
    end

    return false
end

function plimplomGamba.Utils.HasPlayerRolled(playerName)
    if not plimplomGamba or not plimplomGamba.GameState or not plimplomGamba.GameState.playerList then
        return false
    end

    for i = 1, #plimplomGamba.GameState.playerList do
        if plimplomGamba.GameState.playerList[i].name == playerName and plimplomGamba.GameState.playerList[i].roll then
            return true
        end
    end

    return false
end

function plimplomGamba.Utils.CmdSplit(cmd)
    if not cmd then
        return ""
    end
    if strfind(cmd, "%s") then
        return strsplit(" ", cmd)
    else
        return cmd
    end
end

function plimplomGamba.Utils.GetServerTimeRounded()
    local timestamp = GetServerTime()
    return math.floor(timestamp / 100) * 100
end