---
--- Created by plimplom.
--- DateTime: 16/04/2025 11:12
---
PlimplomGamba = PlimplomGamba or {}
local plimplomGamba = PlimplomGamba
plimplomGamba.Config = {}
plimplomGamba.ConfigUI = {}
plimplomGamba.Settings = SavedSettings or {}

local config = plimplomGamba.Config
local configUI = plimplomGamba.ConfigUI

local db = LibStub:GetLibrary("LibDataBroker-1.1")
local dbIcon = LibStub("LibDBIcon-1.0")
local dataObject = db:NewDataObject("plimplomGamba",
    { label = "plimplomGamba", type = "data source", icon = "Interface/AddOns/plimplomGamba/plimplomgamba32.png", text =
    "plimplomGamba" })


local font = "Interface/AddOns/plimplomGamba/jetbrains-mono.regular.ttf"
local texture = "Interface/AddOns/plimplomGamba/HydraUI4.tga"
local blank = "Interface/AddOns/plimplomGamba/HydraUIBlank.tga"

local defaultSettings = {
    rollValue = 1000,
    deathroll = false,
    minDeathroll = 5000,
    uiScale = 1.0,
    framePositions = {}
}

function plimplomGamba.InitializeSettings()
    -- Initialize SavedSettings with defaults for any missing values
    SavedSettings = SavedSettings or {}
    for key, value in pairs(defaultSettings) do
        if SavedSettings[key] == nil then
            SavedSettings[key] = value
        end
    end

    return SavedSettings
end

config.AddonName = "plimplomGamba"
config.MapIcon = dbIcon
config.MapIconData = dataObject

config.ChannelIndexList = {
    [1] = "PARTY",
    [2] = "RAID",
    [3] = "SAY",
}
config.RollMatch = "^(%S+)%s%S+%s(%d+)%s%((%d+)-(%d+)%)"

local buttonRows = 6
local buttonCols = 2

configUI.ButtonWidth = 110
configUI.ButtonHeight = 22
configUI.ButtonSpacing = 3
configUI.WindowWidth = (buttonCols * configUI.ButtonWidth + (configUI.ButtonSpacing * (buttonCols + 1)))
configUI.WindowHeight = (buttonRows * configUI.ButtonHeight + (configUI.ButtonSpacing * (buttonRows + 1)))
configUI.Backdrop = {
    bgFile = blank,
    edgeFile = blank,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
}
configUI.Font = font
configUI.Texture = texture
configUI.ButtonVertextColor = { r = 0.27, g = 0.27, b = 0.27 }
configUI.LabelColorNormal = { r = 1, g = 1, b = 1 }
configUI.LabelColorDisabled = { r = 0.3, g = 0.3, b = 0.3 }
configUI.ButtonVertextColorHover = { r = 0.4, g = 0.4, b = 0.4 }
configUI.ChannelColor = {
    ["PARTY"] = { r = 0.66, g = 0.66, b = 1.0 },
    ["RAID"] = { r = 1.0, g = 0.5, b = 0.0 },
    ["GUILD"] = { r = 0.25, g = 1.0, b = 0.25 },
    ["SAY"] = { r = 1, g = 1, b = 1 }
}


configUI.ScrollBarWidth=30
configUI.GameInfoWidth=200
configUI.GameInfoHeight=16
configUI.DeathrollWidth=250
configUI.DeathrollHeight=22

local function convertRGB(value)
          return value / 255
      end

configUI.Colors = {
    ["gray"] = {
        [50] = {
            r=convertRGB(245),
            g=convertRGB(246),
            b=convertRGB(250),
        },
        [100] = {
            r=convertRGB(235),
            g=convertRGB(238),
            b=convertRGB(244),
        },
        [200] = {
            r=convertRGB(218),
            g=convertRGB(222),
            b=convertRGB(231),
        },
        [300] = {
            r=convertRGB(194),
            g=convertRGB(201),
            b=convertRGB(214),
        },
        [400] = {
            r=convertRGB(148),
            g=convertRGB(160),
            b=convertRGB(184),
        },
        [500] = {
            r=convertRGB(86),
            g=convertRGB(100),
            b=convertRGB(129),
        },
        [600] = {
            r=convertRGB(71),
            g=convertRGB(83),
            b=convertRGB(107),
        },
        [700] = {
            r=convertRGB(51),
            g=convertRGB(60),
            b=convertRGB(77),
        },
        [800] = {
            r=convertRGB(11),
            g=convertRGB(14),
            b=convertRGB(20),
        },
        [900] = {
            r=convertRGB(5),
            g=convertRGB(7),
            b=convertRGB(10),
        },
    },
    ["red"] = {
        [50] = {
            r=convertRGB(255),
            g=convertRGB(240),
            b=convertRGB(240),
        },
        [100] = {
            r=convertRGB(253),
            g=convertRGB(206),
            b=convertRGB(206),
        },
        [200] = {
            r=convertRGB(252),
            g=convertRGB(156),
            b=convertRGB(156),
        },
        [300] = {
            r=convertRGB(246),
            g=convertRGB(85),
            b=convertRGB(85),
        },
        [400] = {
            r=convertRGB(194),
            g=convertRGB(10),
            b=convertRGB(10),
        },
        [500] = {
            r=convertRGB(145),
            g=convertRGB(8),
            b=convertRGB(8),
        },
        [600] = {
            r=convertRGB(122),
            g=convertRGB(6),
            b=convertRGB(6),
        },
        [700] = {
            r=convertRGB(89),
            g=convertRGB(3),
            b=convertRGB(3),
        },
        [800] = {
            r=convertRGB(60),
            g=convertRGB(2),
            b=convertRGB(2),
        },
        [900] = {
            r=convertRGB(30),
            g=convertRGB(1),
            b=convertRGB(1),
        },
    }
}
