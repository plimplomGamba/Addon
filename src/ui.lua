---@diagnostic disable: undefined-global
---
--- Created by plimplom.
--- DateTime: 16/04/2025 11:13
---
PlimplomGamba = PlimplomGamba or {}
local plimplomGamba = PlimplomGamba
plimplomGamba.UI = {}

local buttons = {}

local channelIndex = 2
local channel = "RAID"
local channelId

local uiConfig = plimplomGamba.ConfigUI
local config = plimplomGamba.Config

if (config.MapIcon and not config.MapIcon:IsRegistered(config.AddonName)) then
    config.MapIcon:Register(config.AddonName, config.MapIconData)
end

local function ButtonOnEnter(self)
    local backgroundColor = uiConfig.Colors["gray"][600]
    if self.Tex then
        self.Tex:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b) -- Lighten on hover
    end
end

local function ButtonOnLeave(self)
    local backgroundColor = uiConfig.Colors["gray"][700]
    if self.Tex then
        self.Tex:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b) -- Return to normal
    end
end

local offsets = {
    ["ABOVE"] = {
        point = "BOTTOMLEFT",
        relativePoint = "TOPLEFT",
        xOffset = 0,
        yOffset = uiConfig.ButtonSpacing
    },
    ["BELOW"] = {
        point = "TOPLEFT",
        relativePoint = "BOTTOMLEFT",
        xOffset = 0,
        yOffset = -uiConfig.ButtonSpacing
    },
    ["RIGHT"] = {
        point = "TOPLEFT",
        relativePoint = "TOPRIGHT",
        xOffset = uiConfig.ButtonSpacing,
        yOffset = 0
    },
    ["LEFT"] = {
        point = "TOPRIGHT",
        relativePoint = "TOPLEFT",
        xOffset = -uiConfig.ButtonSpacing,
        yOffset = 0
    }
}

local function setPointForFrame(frame, parent, position, override)
    local offsetCopy = {
        point = offsets[position].point,
        relativePoint = offsets[position].relativePoint,
        xOffset = offsets[position].xOffset,
        yOffset = offsets[position].yOffset
    }

    if override then
        for key, value in pairs(override) do
            if offsetCopy[key] ~= nil then
                offsetCopy[key] = value
            end
        end
    end

    frame:SetPoint(offsetCopy.point, parent, offsetCopy.relativePoint, offsetCopy.xOffset, offsetCopy.yOffset)
end

local function CreateDefaultButton(parent, relativeFrame, text, onClick, position, overrides)
    local backgroundColor = uiConfig.Colors["gray"][700]
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(uiConfig.ButtonWidth, uiConfig.ButtonHeight)
    setPointForFrame(button, relativeFrame, position, overrides)
    button:SetBackdrop(uiConfig.Backdrop)
    button:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
    button:SetBackdropBorderColor(0, 0, 0)

    if onClick then
        button:SetScript("OnMouseUp", onClick)
    end

    button:SetScript("OnEnter", ButtonOnEnter)
    button:SetScript("OnLeave", ButtonOnLeave)

    -- Button texture
    button.Tex = button:CreateTexture(nil, "ARTWORK")
    button.Tex:SetPoint("TOPLEFT", button, 1, -1)
    button.Tex:SetPoint("BOTTOMRIGHT", button, -1, 1)
    button.Tex:SetTexture(uiConfig.Texture)
    button.Tex:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)

    -- Button label
    button.Label = button:CreateFontString(nil, "OVERLAY")
    button.Label:SetPoint("CENTER", button, 0.5, -0.5)
    button.Label:SetFont(uiConfig.Font, 14, "")
    button.Label:SetText(text)
    button.Label:SetShadowColor(0, 0, 0)
    button.Label:SetShadowOffset(1, -1)

    return button
end

local function createGameInfoFrame(parent, index, playerName, rollValue)
    local backgroundColor = uiConfig.Colors["gray"][700]
    local infoHeight = uiConfig.GameInfoHeight
    -- Create button frame if it doesn't exist
    if not buttons.gamePlayerListFrame.playerList[index] then
        local playerInfo = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        playerInfo:SetSize(uiConfig.GameInfoWidth, infoHeight)
        playerInfo:SetBackdrop(uiConfig.Backdrop)
        playerInfo:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
        playerInfo:SetBackdropBorderColor(0, 0, 0)

        -- Button texture
        playerInfo.Tex = playerInfo:CreateTexture(nil, "ARTWORK")
        playerInfo.Tex:SetPoint("TOPLEFT", playerInfo, 1, -1)
        playerInfo.Tex:SetPoint("BOTTOMRIGHT", playerInfo, -1, 1)
        playerInfo.Tex:SetTexture(uiConfig.Texture)
        playerInfo.Tex:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)

        -- Game info (starter, amount)
        playerInfo.GameInfo = playerInfo:CreateFontString(nil, "OVERLAY")
        playerInfo.GameInfo:SetPoint("LEFT", playerInfo, 8, 0)
        playerInfo.GameInfo:SetFont(uiConfig.Font, 10, "")
        playerInfo.GameInfo:SetJustifyH("LEFT")
        playerInfo.GameInfo:SetShadowColor(0, 0, 0)
        playerInfo.GameInfo:SetShadowOffset(1, -1)

        -- Status label (waiting/in progress)
        playerInfo.Label = playerInfo:CreateFontString(nil, "OVERLAY")
        playerInfo.Label:SetPoint("RIGHT", playerInfo, -8, 0)
        playerInfo.Label:SetFont(uiConfig.Font, 10, "")
        playerInfo.Label:SetJustifyH("RIGHT")
        playerInfo.Label:SetShadowColor(0, 0, 0)
        playerInfo.Label:SetShadowOffset(1, -1)
        playerInfo.Label:SetTextColor(1, 1, 0)

        buttons.gamePlayerListFrame.playerList[index] = playerInfo
    end

    local button = buttons.gamePlayerListFrame.playerList[index]

    -- Position the button
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * (infoHeight + 1)))

    button.GameInfo:SetText(playerName)
    if rollValue then
        button.Label:SetText(rollValue)
    else
        button.Label:SetText("")
        button.GameInfo:SetTextColor(1, 1, 1)
    end

    -- Show the button
    button:Show()

    return button
end

local function createDeathRollButton(parent, index, rollStarter, rollData)
    local backgroundColor = uiConfig.Colors["gray"][700]
    -- Create button frame if it doesn't exist
    if not buttons.deathrollFrame.games[index] then
        local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
        button:SetSize(uiConfig.DeathrollWidth, uiConfig.DeathrollHeight)
        button:SetBackdrop(uiConfig.Backdrop)
        button:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
        button:SetBackdropBorderColor(0, 0, 0)
        button:EnableMouse(true)
        button:SetScript("OnMouseUp", function(self)
            RandomRoll(1, rollData.currentRoll)
        end)
        button:SetScript("OnEnter", ButtonOnEnter)
        button:SetScript("OnLeave", ButtonOnLeave)

        -- Button texture
        button.Tex = button:CreateTexture(nil, "ARTWORK")
        button.Tex:SetPoint("TOPLEFT", button, 1, -1)
        button.Tex:SetPoint("BOTTOMRIGHT", button, -1, 1)
        button.Tex:SetTexture(uiConfig.Texture)
        button.Tex:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)

        -- Game info (starter, amount)
        button.GameInfo = button:CreateFontString(nil, "OVERLAY")
        button.GameInfo:SetPoint("LEFT", button, 8, 0)
        button.GameInfo:SetFont(uiConfig.Font, 8, "")
        button.GameInfo:SetJustifyH("LEFT")
        button.GameInfo:SetShadowColor(0, 0, 0)
        button.GameInfo:SetShadowOffset(1, -1)

        -- Status label (waiting/in progress)
        button.Label = button:CreateFontString(nil, "OVERLAY")
        button.Label:SetPoint("RIGHT", button, -8, 0)
        button.Label:SetFont(uiConfig.Font, 8, "")
        button.Label:SetJustifyH("RIGHT")
        button.Label:SetShadowColor(0, 0, 0)
        button.Label:SetShadowOffset(1, -1)

        buttons.deathrollFrame.games[index] = button
    end

    local button = buttons.deathrollFrame.games[index]
    button.rollStarter = rollStarter

    -- Position the button
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * (22 + 1)))

    -- Update button text
    local amount = rollData.deathRollAmount or 0
    local opponentText = ""
    if rollData.opponent then
        opponentText = " vs " .. rollData.opponent
    end

    local me = UnitName("player")

    if (rollData.lastRoller ~= me and (rollData.opponent == nil or rollStarter == me or rollData.opponent == me)) then
        button:EnableMouse(true)
        button.Label:SetText("ROLL")
        button.Label:SetTextColor(0, 1, 0) -- Green for waiting
    else
        button:EnableMouse(false)
        if ((rollStarter == me and not rollData.opponent) or (rollData.opponent and rollData.opponent == me)) then
            button.Label:SetText("WAIT")
            button.Label:SetTextColor(1, 0.5, 0) -- Orange for in progress
        else
            button.Label:SetText("CLOSED")
            button.Label:SetTextColor(1, 0, 0) -- Orange for in progress
        end
    end

    button.GameInfo:SetText(rollStarter ..
        opponentText .. " (" .. amount / 1000 .. "k g)" .. " /roll " .. rollData.currentRoll)

    -- Show the button
    button:Show()

    return button
end

local function updateGameInfoList()
    if not buttons.gamePlayerListFrame.playerList then
        buttons.gamePlayerListFrame.playerList = {}
    end

    -- Hide all buttons first
    for _, button in pairs(buttons.gamePlayerListFrame.playerList) do
        button:Hide()
        if not plimplomGamba.GameState.playerList then
            button:SetParent(nil)
        end
    end

    if not plimplomGamba.GameState.playerList then
        buttons.gamePlayerListFrame.playerList = {}
        return
    end

    local index = 1
    local totalHeight = 0

    for i = 1, #plimplomGamba.GameState.playerList do
        local currentPlayer = plimplomGamba.GameState.playerList[i]
        local button = createGameInfoFrame(buttons.gamePlayerListFrame.contentFrame, index, currentPlayer.name,
            currentPlayer.roll)
        index = index + 1
        totalHeight = totalHeight + uiConfig.ButtonHeight + uiConfig.ButtonSpacing
    end

    -- Update content frame height
    buttons.gamePlayerListFrame.contentFrame:SetHeight(math.max(totalHeight, 1))
end

local function updateDeathRollList()
    if not plimplomGamba.GameState.deathrolls then
        plimplomGamba.GameState.deathrolls = {}
    end
    if not buttons.deathrollFrame.games then
        buttons.deathrollFrame.games = {}
    end
    -- Hide all buttons first
    for _, button in pairs(buttons.deathrollFrame.games) do
        button:Hide()
    end

    -- Get all active death rolls
    local index = 1
    local totalHeight = 0

    for rollStarter, rollData in pairs(plimplomGamba.GameState.deathrolls) do
        local button = createDeathRollButton(buttons.deathrollFrame.contentFrame, index, rollStarter, rollData)
        index = index + 1
        totalHeight = totalHeight + uiConfig.ButtonHeight + uiConfig.ButtonSpacing
    end

    if index ~= 1 then
        if buttons.deathrollFrame.games["empty"] then
            buttons.deathrollFrame.games["empty"]:Hide()
        end
    end

    -- Update content frame height
    buttons.deathrollFrame.contentFrame:SetHeight(math.max(totalHeight, 1))
end

function plimplomGamba.InitializeUI()
    local backgroundColor = uiConfig.Colors["gray"][500]
    -- Create main frame
    local frame = CreateFrame("Frame", "plimplomGambaFrame", UIParent, "BackdropTemplate")
    frame:SetSize(uiConfig.WindowWidth, uiConfig.WindowHeight)
    -- Try to restore position, otherwise set default
    if not plimplomGamba.RestoreFramePosition(frame, "mainFrame") then
        frame:SetPoint("CENTER", UIParent, 0, 99)
    end
    frame:SetBackdrop(uiConfig.Backdrop)
    frame:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
    frame:SetBackdropBorderColor(0, 0, 0)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        plimplomGamba.SaveFramePosition(frame, "mainFrame")
    end)
    plimplomGamba.UI.mainFrame = frame

    createHeader()

    addMainFrameButtons()

    addGameInfoFrame()
    addDeathrollFrame()
end

function plimplomGamba.UpdateUI()
    local gamestate = plimplomGamba.GameState
    local me = UnitName("player")

    if not gamestate then
        return
    end

    local meInGame = plimplomGamba.Utils.IsPlayerInGame(me)
    local meRolled = plimplomGamba.Utils.HasPlayerRolled(me)
    local disabledColor = { r = 0.3, g = 0.3, b = 0.3 }
    local enabledColor = { r = 1, g = 1, b = 1 }

    -- Handle player entry/exit buttons
    if gamestate and gamestate.playerList and meInGame then
        buttons.enterSelfButton:Hide()
        buttons.leaveSelfButton:Show()
    else
        buttons.enterSelfButton:Show()
        buttons.leaveSelfButton:Hide()
        buttons.rollSelfButton.Label:SetTextColor(disabledColor.r, disabledColor.g, disabledColor.b)
    end

    -- Update lists
    updateGameInfoList()
    updateDeathRollList()

    -- Highlight winner/loser if all players have rolled
    if plimplomGamba.AllPlayersRolled() then
        buttons.gamePlayerListFrame.playerList[1].GameInfo:SetTextColor(0, 1, 0)                                       -- Winner color
        buttons.gamePlayerListFrame.playerList[#buttons.gamePlayerListFrame.playerList].GameInfo:SetTextColor(1, 0, 0) -- Loser color
    end

    -- Set default state for all buttons
    local buttonConfig = {
        [0] = { -- Not started
            newGame = { visible = true, enabled = true },
            lastCall = { visible = false, enabled = false },
            resetGame = { visible = false, enabled = false },
            startRolls = { visible = false, enabled = true },
            gamePlayerList = { visible = false },
            rollSelf = { visible = false, enabled = false },
            rollValue = { enabled = true, color = enabledColor },
            setChannel = { enabled = true, color = uiConfig.ChannelColor[channel] },
            enterSelf = { enabled = false, color = disabledColor },
            leaveSelf = { enabled = false, color = disabledColor }
        },
        [1] = { -- New game started
            newGame = { visible = false, enabled = false },
            lastCall = { visible = true, enabled = true },
            resetGame = { visible = true, enabled = true },
            startRolls = { visible = false, enabled = true },
            gamePlayerList = { visible = true },
            rollSelf = { visible = true, enabled = false },
            rollValue = { enabled = false, color = disabledColor },
            setChannel = { enabled = false, color = disabledColor },
            enterSelf = { enabled = true, color = enabledColor },
            leaveSelf = { enabled = true, color = enabledColor }
        },
        [2] = { -- Last call
            newGame = { visible = false, enabled = false },
            lastCall = { visible = false, enabled = false },
            resetGame = { visible = true, enabled = true },
            startRolls = { visible = true, enabled = true },
            gamePlayerList = { visible = true },
            rollSelf = { visible = true, enabled = false },
            rollValue = { enabled = false, color = disabledColor },
            setChannel = { enabled = false, color = disabledColor },
            enterSelf = { enabled = true, color = enabledColor },
            leaveSelf = { enabled = true, color = enabledColor }
        },
        [3] = { -- Rolling
            newGame = { visible = false, enabled = false },
            lastCall = { visible = false, enabled = false },
            resetGame = { visible = true, enabled = true },
            startRolls = { visible = true, enabled = false },
            gamePlayerList = { visible = true },
            rollSelf = { visible = true, enabled = meInGame and not meRolled },
            rollValue = { enabled = false, color = disabledColor },
            setChannel = { enabled = false, color = disabledColor },
            enterSelf = { enabled = false, color = disabledColor },
            leaveSelf = { enabled = false, color = disabledColor }
        }
    }

    -- Apply configuration based on game state
    local config = buttonConfig[gamestate.status]
    if not config then return end

    -- Set button visibility and state
    buttons.newGameButton:SetShown(config.newGame.visible)
    buttons.lastCallButton:SetShown(config.lastCall.visible)
    buttons.resetGameButton:SetShown(config.resetGame.visible)
    buttons.startRollsButton:SetShown(config.startRolls.visible)
    buttons.gamePlayerListFrame:SetShown(config.gamePlayerList.visible)
    buttons.rollSelfButton:SetShown(config.rollSelf.visible)

    -- Set button enabled states
    if config.newGame.enabled then buttons.newGameButton:Enable() else buttons.newGameButton:Disable() end
    if config.lastCall.enabled then buttons.lastCallButton:Enable() else buttons.lastCallButton:Disable() end
    if config.resetGame.enabled then buttons.resetGameButton:Enable() else buttons.resetGameButton:Disable() end
    if config.startRolls.enabled then buttons.startRollsButton:Enable() else buttons.startRollsButton:Disable() end
    if config.rollSelf.enabled then buttons.rollSelfButton:Enable() else buttons.rollSelfButton:Disable() end
    if config.rollValue.enabled then buttons.rollValue:Enable() else buttons.rollValue:Disable() end
    if config.setChannel.enabled then buttons.setChannelButton:Enable() else buttons.setChannelButton:Disable() end
    if config.enterSelf.enabled then buttons.enterSelfButton:Enable() else buttons.enterSelfButton:Disable() end
    if config.leaveSelf.enabled then buttons.leaveSelfButton:Enable() else buttons.leaveSelfButton:Disable() end

    -- Set text colors
    if config.rollValue.color then
        buttons.rollValue:SetTextColor(config.rollValue.color.r, config.rollValue.color.g, config.rollValue.color.b)
    end

    if config.setChannel.color then
        buttons.setChannelButton.Label:SetTextColor(config.setChannel.color.r, config.setChannel.color.g,
            config.setChannel.color.b)
    end

    buttons.startRollsButton.Label:SetTextColor(
        config.startRolls.enabled and enabledColor.r or disabledColor.r,
        config.startRolls.enabled and enabledColor.g or disabledColor.g,
        config.startRolls.enabled and enabledColor.b or disabledColor.b
    )

    buttons.enterSelfButton.Label:SetTextColor(
        config.enterSelf.enabled and enabledColor.r or disabledColor.r,
        config.enterSelf.enabled and enabledColor.g or disabledColor.g,
        config.enterSelf.enabled and enabledColor.b or disabledColor.b
    )

    buttons.leaveSelfButton.Label:SetTextColor(
        config.leaveSelf.enabled and enabledColor.r or disabledColor.r,
        config.leaveSelf.enabled and enabledColor.g or disabledColor.g,
        config.leaveSelf.enabled and enabledColor.b or disabledColor.b
    )

    buttons.rollSelfButton.Label:SetTextColor(
        config.rollSelf.enabled and enabledColor.r or disabledColor.r,
        config.rollSelf.enabled and enabledColor.g or disabledColor.g,
        config.rollSelf.enabled and enabledColor.b or disabledColor.b
    )
end

function createHeader()
    local backgroundColor = uiConfig.Colors["gray"][800]
    local closeColorHover = uiConfig.Colors["red"][400]
    local mainFrame = plimplomGamba.UI.mainFrame

    mainFrame.Header = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    mainFrame.Header:SetPoint("BOTTOM", mainFrame, "TOP", 0, -1)
    mainFrame.Header:SetSize(uiConfig.WindowWidth, uiConfig.ButtonHeight)
    mainFrame.Header:SetBackdrop(uiConfig.Backdrop)
    mainFrame.Header:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
    mainFrame.Header:SetBackdropBorderColor(0, 0, 0)
    mainFrame.Header:EnableMouse(true)
    mainFrame.Header:SetMovable(true)
    mainFrame.Header:RegisterForDrag("LeftButton")
    mainFrame.Header:SetScript("OnDragStart", function() mainFrame:StartMoving() end)
    mainFrame.Header:SetScript("OnDragStop", function() mainFrame:StopMovingOrSizing() end)

    mainFrame.Header.Tex = mainFrame.Header:CreateTexture(nil, "ARTWORK")
    mainFrame.Header.Tex:SetPoint("TOPLEFT", mainFrame.Header, 1, -1)
    mainFrame.Header.Tex:SetPoint("BOTTOMRIGHT", mainFrame.Header, -1, 1)
    mainFrame.Header.Tex:SetTexture(uiConfig.Texture)
    mainFrame.Header.Tex:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)

    mainFrame.Header.Label = mainFrame.Header:CreateFontString(nil, "OVERLAY")
    mainFrame.Header.Label:SetPoint("LEFT", mainFrame.Header, 6, -0.5)
    mainFrame.Header.Label:SetFont(uiConfig.Font, 14, "")
    mainFrame.Header.Label:SetText("|cffFFE6C0" .. config.AddonName .. "|r")
    mainFrame.Header.Label:SetShadowColor(0, 0, 0)
    mainFrame.Header.Label:SetShadowOffset(1, -1)

    local closeButton = CreateFrame("Frame", nil, mainFrame.Header)
    closeButton:SetPoint("TOPRIGHT", mainFrame.Header, 0, 0)
    closeButton:SetSize(uiConfig.ButtonHeight, uiConfig.ButtonHeight)
    closeButton:SetScript("OnEnter",
        function(self) self.Texture:SetVertexColor(closeColorHover.r, closeColorHover.g, closeColorHover.b) end)
    closeButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
    closeButton:SetScript("OnMouseUp", function() mainFrame:Hide() end)

    closeButton.Texture = closeButton:CreateTexture(nil, "OVERLAY")
    closeButton.Texture:SetPoint("CENTER", closeButton, 0, 0)
    closeButton.Texture:SetSize(uiConfig.ButtonHeight - 6, uiConfig.ButtonHeight - 6)
    closeButton.Texture:SetTexture("Interface/AddOns/plimplomGamba/HydraUIClose.tga")
end

function addMainFrameButtons()
    local backgroundColor = uiConfig.Colors["gray"][900]
    local mainFrame = plimplomGamba.UI.mainFrame

    local gambaValueText = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    gambaValueText:SetPoint("TOPLEFT", mainFrame, 3, -3)
    gambaValueText:SetSize(uiConfig.ButtonWidth, uiConfig.ButtonHeight)

    gambaValueText.Label = gambaValueText:CreateFontString(nil, "OVERLAY")
    gambaValueText.Label:SetPoint("LEFT", gambaValueText, 0.5, -0.5)
    gambaValueText.Label:SetFont(uiConfig.Font, 12, "")
    gambaValueText.Label:SetText("Gamba Value:")
    gambaValueText.Label:SetShadowColor(0, 0, 0)
    gambaValueText.Label:SetShadowOffset(1, -1)

    buttons.rollValue = CreateFrame("EditBox", nil, mainFrame, "BackdropTemplate")
    local rollValue = buttons.rollValue
    rollValue:SetPoint("TOPLEFT", gambaValueText, "TOPRIGHT", 3, 0)
    rollValue:SetSize(uiConfig.ButtonWidth, uiConfig.ButtonHeight)
    rollValue:SetBackdrop(uiConfig.Backdrop)
    rollValue:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
    rollValue:SetBackdropBorderColor(0, 0, 0)

    rollValue:SetFont(uiConfig.Font, 12, "")
    rollValue:SetMaxLetters(12)
    rollValue:SetText(plimplomGamba.Utils.Comma(plimplomGamba.GameState.rollValue))
    rollValue:SetAutoFocus(false)
    rollValue:ClearFocus()
    rollValue:SetHyperlinksEnabled(false)
    rollValue:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    rollValue:SetScript("OnEditFocusLost", function(self)
        plimplomGamba.UpdateRollValue(self:GetNumber())
        self:SetMaxLetters(12)
        self:SetNumeric(false)
        self:SetText(plimplomGamba.Utils.Comma(self:GetNumber()))
    end)
    rollValue:SetScript("OnEditFocusGained", function(self)
        self:SetText(self:GetText():gsub(",", ""))
        self:SetMaxLetters(9)
        self:SetNumeric(true)
        self:HighlightText()
    end)
    rollValue:SetScript("OnTextChanged", function(self, input)
        plimplomGamba.UpdateRollValue(self:GetNumber(), input)
    end)


    local channelText = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    channelText:SetPoint("TOPLEFT", gambaValueText, "BOTTOMLEFT", 0, -3)
    channelText:SetSize(uiConfig.ButtonWidth, uiConfig.ButtonHeight)

    channelText.Label = channelText:CreateFontString(nil, "OVERLAY")
    channelText.Label:SetPoint("LEFT", channelText, 0.5, -0.5)
    channelText.Label:SetFont(uiConfig.Font, 12, "")
    channelText.Label:SetText("Channel:")
    channelText.Label:SetShadowColor(0, 0, 0)
    channelText.Label:SetShadowOffset(1, -1)

    -- Set Channel
    buttons.setChannelButton = CreateDefaultButton(
        mainFrame, channelText, channel,
        function(self)
            if not self:IsEnabled() then
                return
            end
            channelIndex = channelIndex + 1

            if (channelIndex > 3) then
                channelIndex = 1
            end

            plimplomGamba.GameState.channel = config.ChannelIndexList[channelIndex]
            local channelColor = uiConfig.ChannelColor[plimplomGamba.GameState.channel]
            channelId = nil

            self.Label:SetText(plimplomGamba.GameState.channel)
            self.Label:SetTextColor(channelColor.r, channelColor.g, channelColor.b)
        end, "RIGHT"
    )
    local setChannelButton = buttons.setChannelButton
    local channelColor = uiConfig.ChannelColor[channel]
    setChannelButton.Label:SetTextColor(channelColor.r, channelColor.g, channelColor.b)

    -- New Game
    buttons.newGameButton = CreateDefaultButton(
        mainFrame, channelText, "New Game",
        function(self)
            if not self:IsEnabled() then
                return
            end
            plimplomGamba.UpdateGameState()
        end, "BELOW"
    )
    local newGameButton = buttons.newGameButton

    -- Reset
    buttons.resetGameButton = CreateDefaultButton(
        mainFrame, newGameButton, "Reset Game",
        function(self)
            if not self:IsEnabled() then
                return
            end
            plimplomGamba.UpdateGameState("RESET")
        end, "RIGHT"
    )
    local resetGameButton = buttons.resetGameButton
    resetGameButton:Hide()

    -- Last Call
    buttons.lastCallButton = CreateDefaultButton(
        mainFrame, channelText, "Last Call",
        function(self)
            if not self:IsEnabled() then
                return
            end
            plimplomGamba.UpdateGameState()
        end, "BELOW"
    )
    local lastCallButton = buttons.lastCallButton
    lastCallButton:Hide()

    -- Start Rolls
    buttons.startRollsButton = CreateDefaultButton(
        mainFrame, channelText, "Start Rolls",
        function(self)
            if not self:IsEnabled() then
                return
            end
            plimplomGamba.UpdateGameState()
        end, "BELOW"
    )
    local startRollsButton = buttons.startRollsButton
    startRollsButton:Hide()

    -- Enter Self
    buttons.enterSelfButton = CreateDefaultButton(
        mainFrame, startRollsButton, "Enter",
        function(self)
            if not self:IsEnabled() then
                return
            end
            SendChatMessage("1", plimplomGamba.GameState.channel, nil, nil)
            plimplomGamba.AddPlayer(UnitName("player"))
        end, "BELOW"
    )
    local enterSelfButton = buttons.enterSelfButton
    enterSelfButton:Disable()
    enterSelfButton.Label:SetTextColor(0.3, 0.3, 0.3)

    -- Leave Self
    buttons.leaveSelfButton = CreateDefaultButton(
        mainFrame, startRollsButton, "Leave",
        function(self)
            if not self:IsEnabled() then
                return
            end
            SendChatMessage("-1", plimplomGamba.GameState.channel, nil, nil)
            plimplomGamba.RemovePlayer(UnitName("player"))
        end, "BELOW"
    )
    local leaveSelfButton = buttons.leaveSelfButton
    leaveSelfButton:Hide()

    -- Roll Self
    buttons.rollSelfButton = CreateDefaultButton(
        mainFrame, enterSelfButton, "Roll",
        function(self)
            if not self:IsEnabled() then
                return
            end
            RandomRoll(1, plimplomGamba.GameState.rollValue)
        end, "RIGHT"
    )
    local rollSelfButton = buttons.rollSelfButton
    rollSelfButton:Hide()

    local emptyRow = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    emptyRow:SetPoint("TOPLEFT", enterSelfButton, "BOTTOMLEFT", 0, -3)
    emptyRow:SetSize(uiConfig.ButtonWidth, uiConfig.ButtonHeight)
    emptyRow:Hide()

    local deathRollText = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    deathRollText:SetPoint("TOPLEFT", emptyRow, "BOTTOMLEFT", 0, -3)
    deathRollText:SetSize(uiConfig.ButtonWidth, uiConfig.ButtonHeight)

    deathRollText.Label = deathRollText:CreateFontString(nil, "OVERLAY")
    deathRollText.Label:SetPoint("LEFT", deathRollText, 0.5, -0.5)
    deathRollText.Label:SetFont(uiConfig.Font, 12, "")
    deathRollText.Label:SetText("Deathrolls:")
    deathRollText.Label:SetShadowColor(0, 0, 0)
    deathRollText.Label:SetShadowOffset(1, -1)

    buttons.deathrollsCheckbox = CreateFrame("CheckButton", nil, mainFrame, "BankPanelTabDepositSettingsCheckboxTemplate")
    local deathrollsCheckbox = buttons.deathrollsCheckbox
    deathrollsCheckbox:SetPoint("TOPLEFT", deathRollText, "TOPRIGHT", 3, 0)
    deathrollsCheckbox:SetSize(uiConfig.ButtonHeight, uiConfig.ButtonHeight)
    deathrollsCheckbox:SetChecked(SavedSettings["deathroll"] or false)
    deathrollsCheckbox:SetScript("OnClick", function(self)
        plimplomGamba.UpdateDeathrollTracking(self, buttons.deathrollFrame)
    end)
end

function addDeathrollFrame()
    local backgroundColor = uiConfig.Colors["gray"][800]
    local mainFrame = plimplomGamba.UI.mainFrame

    buttons.deathrollFrame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    local deathrollFrame = buttons.deathrollFrame
    deathrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPRIGHT", 0, 0)
    deathrollFrame:SetSize(uiConfig.DeathrollWidth + uiConfig.ScrollBarWidth, uiConfig.WindowHeight)
    deathrollFrame:SetBackdrop(uiConfig.Backdrop)
    deathrollFrame:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.8)
    deathrollFrame:SetBackdropBorderColor(0, 0, 0)
    --deathrollFrame:Hide()
    deathrollFrame:SetShown(SavedSettings["deathroll"] or false)

    -- Add a scroll frame for the list
    deathrollFrame.scrollFrame = CreateFrame("ScrollFrame", nil, deathrollFrame,
        "UIPanelScrollFrameTemplate")
    local deathrollScrollFrame = deathrollFrame.scrollFrame
    deathrollScrollFrame:SetPoint("TOPLEFT", deathrollFrame, "TOPLEFT", 4, -4)
    deathrollScrollFrame:SetPoint("BOTTOMRIGHT", deathrollFrame, "BOTTOMRIGHT", -26, 4) -- Leave room for scroll bar

    -- Content frame to hold the buttons
    deathrollFrame.contentFrame = CreateFrame("Frame", nil, scrollFrame)
    local deathrollContentFrame = deathrollFrame.contentFrame
    deathrollContentFrame:SetSize(20, 1) -- Height will be set dynamically
    deathrollScrollFrame:SetScrollChild(deathrollContentFrame)
end

function addGameInfoFrame()
    local backgroundColor = uiConfig.Colors["gray"][800]
    local mainFrame = plimplomGamba.UI.mainFrame

    buttons.gamePlayerListFrame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    local gamePlayerListFrame = buttons.gamePlayerListFrame
    gamePlayerListFrame:SetPoint("TOPRIGHT", mainFrame, "TOPLEFT", 0, 0)
    gamePlayerListFrame:SetSize(uiConfig.GameInfoWidth + uiConfig.ScrollBarWidth, uiConfig.WindowHeight)
    gamePlayerListFrame:SetBackdrop(uiConfig.Backdrop)
    gamePlayerListFrame:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.8)
    gamePlayerListFrame:SetBackdropBorderColor(0, 0, 0)
    gamePlayerListFrame:Hide()

    -- Add a scroll frame for the list
    gamePlayerListFrame.scrollFrame = CreateFrame("ScrollFrame", nil, gamePlayerListFrame,
        "UIPanelScrollFrameTemplate")
    local scrollFrame = gamePlayerListFrame.scrollFrame
    scrollFrame:SetPoint("TOPLEFT", gamePlayerListFrame, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", gamePlayerListFrame, "BOTTOMRIGHT", -26, 4) -- Leave room for scroll bar

    -- Content frame to hold the buttons
    gamePlayerListFrame.contentFrame = CreateFrame("Frame", nil, scrollFrame)
    local contentFrame = gamePlayerListFrame.contentFrame
    contentFrame:SetSize(20, 1) -- Height will be set dynamically
    scrollFrame:SetScrollChild(contentFrame)
end

function config.MapIconData:OnClick(_)
    if (not plimplomGamba.UI.mainFrame) then
        plimplomGamba.InitializeUI()
        return
    end
    if (not plimplomGamba.UI.mainFrame:IsShown()) then
        plimplomGamba.UI.mainFrame:Show()
    else
        plimplomGamba.UI.mainFrame:Hide()
    end
end

function config.MapIconData:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()

    GameTooltip:AddLine(config.AddonName, 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Click to toggle")

    GameTooltip:Show()
end

function config.MapIconData:OnLeave()
    GameTooltip:Hide()
end

-- Save frame position
function plimplomGamba.SaveFramePosition(frame, frameName)
    if not SavedSettings.framePositions then
        SavedSettings.framePositions = {}
    end

    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    if not relativeTo then relativeTo = UIParent end

    SavedSettings.framePositions[frameName] = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
end

-- Restore frame position
function plimplomGamba.RestoreFramePosition(frame, frameName)
    if not SavedSettings.framePositions or not SavedSettings.framePositions[frameName] then
        return false
    end

    local pos = SavedSettings.framePositions[frameName]
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    return true
end
