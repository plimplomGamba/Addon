---
--- Created by plimplom.
--- DateTime: 03/05/2025 10:30
---
PlimplomGamba = PlimplomGamba or {}
local plimplomGamba = PlimplomGamba
plimplomGamba.GameState = plimplomGamba.GameState or {}

--function plimplomGamba.GetGameState()
--    if not plimplomGamba.GameState then
--        plimplomGamba.GameState = {
--            status = 0,
--            rollValue = SavedSettings and SavedSettings.rollValue or 1000,
--            channel = "RAID",
--            trackDeathrolls = SavedSettings and SavedSettings.deathroll or false,
--            playerList = {},
--            deathrolls = {}
--        }
--    end
--    return plimplomGamba.GameState
--end