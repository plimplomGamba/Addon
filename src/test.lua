---
--- Created by simon.
--- DateTime: 19/04/2025 14:46
---

PlimplomGamba = PlimplomGamba or {}
local plimplomGamba = PlimplomGamba
plimplomGamba.Test = {}

local function testJoinPlayer(playerName)
    plimplomGamba.AddPlayer(playerName)
end

local function testLeavePlayer(playerName)
    plimplomGamba.RemovePlayer(playerName)
end

local function testRollForPlayer(playerName)
    plimplomGamba.HandlePlayerRoll(playerName, math.random(1, plimplomGamba.GameState.rollValue), 1,
        plimplomGamba.GameState.rollValue)
end

function plimplomGamba.Test.Test(args)
    local _, arg1, arg2, _ = plimplomGamba.Utils.CmdSplit(args)

    if arg1 == "join" and arg2 then
        if plimplomGamba.GameState.status == 1 or plimplomGamba.GameState.status == 2 then
            testJoinPlayer(arg2)
        end
    elseif arg1 == "leave" and arg2 then
        if plimplomGamba.GameState.status == 1 or plimplomGamba.GameState.status == 2 then
            testLeavePlayer(arg2)
        end
    elseif arg1 == "roll" and arg2 then
        if plimplomGamba.GameState.status == 3 then
            testRollForPlayer(arg2)
        end
    end
end

function plimplomGamba.Test.TestDeathrolls(args)
    local _, arg1, arg2, arg3 = plimplomGamba.Utils.CmdSplit(args)

    if arg3 then
        plimplomGamba.HandleDeathrolls(arg1, arg3, arg2)
    else
        plimplomGamba.HandleDeathrolls(arg1, math.random(1, arg2), arg2)
    end
end
