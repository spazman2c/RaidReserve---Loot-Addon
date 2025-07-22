local addonName, addon = ...

-- Create main frame
local mainFrame = CreateFrame("Frame", "RaidReserveFrame", UIParent)
mainFrame:SetSize(480, 400)
mainFrame:SetPoint("CENTER")
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:Hide()

-- Set frame background and border
mainFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
mainFrame:SetBackdropColor(0.137, 0.137, 0.157, 1.0) -- #232328
mainFrame:SetBackdropBorderColor(0.161, 0.161, 0.196, 1.0) -- #292932

-- Create header bar
local headerBar = CreateFrame("Frame", nil, mainFrame)
headerBar:SetPoint("TOPLEFT")
headerBar:SetPoint("TOPRIGHT")
headerBar:SetHeight(60)
headerBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
headerBar:SetBackdropColor(0.094, 0.094, 0.106, 1.0) -- #18181b
headerBar:SetBackdropBorderColor(0.149, 0.149, 0.176, 1.0) -- #26262d

-- Create title text
local titleText = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("LEFT", 30, 0)
titleText:SetText("RaidReserve |cFF9af9c0MoP Classic|r")

-- Create close button
local closeButton = CreateFrame("Button", nil, headerBar)
closeButton:SetSize(31, 31)
closeButton:SetPoint("TOPRIGHT", -9, -7)
closeButton:SetScript("OnClick", function() mainFrame:Hide() end)

-- Create notification area
local notifArea = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
notifArea:SetPoint("TOPLEFT", headerBar, "BOTTOMLEFT", 32, -7)
notifArea:SetPoint("TOPRIGHT", headerBar, "BOTTOMRIGHT", -32, -7)
notifArea:SetHeight(24)
notifArea:SetTextColor(0.18, 0.95, 0.55, 1.0) -- #2ef18c

-- Create scroll frame
local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", headerBar, "BOTTOMLEFT", 24, -60)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 80)

-- Create content frame
local contentFrame = CreateFrame("Frame")
contentFrame:SetSize(scrollFrame:GetSize())
scrollFrame:SetScrollChild(contentFrame)

-- Create table header
local tableHeader = CreateFrame("Frame", nil, mainFrame)
tableHeader:SetPoint("TOPLEFT", scrollFrame)
tableHeader:SetPoint("TOPRIGHT", scrollFrame)
tableHeader:SetHeight(30)
tableHeader:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
tableHeader:SetBackdropColor(0.129, 0.129, 0.141, 1.0) -- #212124
tableHeader:SetBackdropBorderColor(0.161, 0.161, 0.196, 1.0) -- #292932

-- Create column headers
local headerPlayer = tableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
headerPlayer:SetPoint("LEFT", 10, 0)
headerPlayer:SetText(addon.L["UI_PLAYER"])

local headerItem = tableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
headerItem:SetPoint("LEFT", 150, 0)
headerItem:SetText(addon.L["UI_ITEM"])

local headerTime = tableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
headerTime:SetPoint("LEFT", 290, 0)
headerTime:SetText(addon.L["UI_TIME"])

-- Create control buttons
local function CreateStyledButton(parent, width, height, text, color)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height)
    
    button:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    local colors = {
        jade = { bg = {0.18, 0.95, 0.55}, text = {0.094, 0.094, 0.106} },  -- #2ef18c
        gold = { bg = {0.97, 0.91, 0.59}, text = {0.137, 0.137, 0.157} },  -- #f7e997
        red = { bg = {0.97, 0.42, 0.42}, text = {1, 1, 1} },               -- #f76c6c
        gray = { bg = {0.137, 0.137, 0.157}, text = {0.741, 0.741, 0.741} } -- #232328
    }
    
    local bgColor = colors[color].bg
    local textColor = colors[color].text
    
    button:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], 1.0)
    button:SetBackdropBorderColor(0.196, 0.196, 0.235, 1.0) -- #32323c
    
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER")
    buttonText:SetText(text)
    buttonText:SetTextColor(textColor[1], textColor[2], textColor[3], 1.0)
    
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(bgColor[1]*1.2, bgColor[2]*1.2, bgColor[3]*1.2, 1.0)
    end)
    
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], 1.0)
    end)
    
    return button
end

local controlsFrame = CreateFrame("Frame", nil, mainFrame)
controlsFrame:SetPoint("BOTTOMLEFT", 32, 40)
controlsFrame:SetPoint("BOTTOMRIGHT", -32, 40)
controlsFrame:SetHeight(40)

local startButton = CreateStyledButton(controlsFrame, 80, 28, addon.L["CMD_START"], "jade")
startButton:SetPoint("RIGHT", -280, 0)

local stopButton = CreateStyledButton(controlsFrame, 80, 28, addon.L["CMD_STOP"], "red")
stopButton:SetPoint("RIGHT", -280, 0)
stopButton:Hide()

local clearButton = CreateStyledButton(controlsFrame, 80, 28, addon.L["CMD_CLEAR"], "gray")
clearButton:SetPoint("RIGHT", -190, 0)

local broadcastButton = CreateStyledButton(controlsFrame, 100, 28, addon.L["CMD_BROADCAST"], "gold")
broadcastButton:SetPoint("RIGHT", -100, 0)

local exportButton = CreateStyledButton(controlsFrame, 80, 28, addon.L["UI_EXPORT"], "gold")
exportButton:SetPoint("RIGHT", -10, 0)

-- Create status bar
local statusBar = CreateFrame("Frame", nil, mainFrame)
statusBar:SetPoint("BOTTOMLEFT")
statusBar:SetPoint("BOTTOMRIGHT")
statusBar:SetHeight(30)
statusBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
statusBar:SetBackdropColor(0.098, 0.098, 0.114, 1.0) -- #19191d
statusBar:SetBackdropBorderColor(0.137, 0.137, 0.165, 1.0) -- #23232a

local statusText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusText:SetPoint("LEFT", 30, 0)
statusText:SetText("Idle")
statusText:SetTextColor(0.596, 0.596, 0.604, 1.0) -- #98989a

-- Function to format reservations for export
local function FormatReservationsForExport()
    local output = "Player,Item,Time\n"
    for player, items in pairs(addon.state.reservations) do
        for _, reservation in ipairs(items) do
            output = output .. string.format("%s,%s,%s\n", 
                player, 
                reservation.item:gsub("|c%x+|Hitem:%d+:.-|h(.-)|h|r", "%1"),
                reservation.time)
        end
    end
    return output
end

-- Create lines pool for efficient line management
local linesPool = {}
local function AcquireLine(index)
    if not linesPool[index] then
        local line = CreateFrame("Frame", nil, contentFrame)
        line:SetSize(contentFrame:GetWidth(), 30)
        
        -- Add hover highlight
        line:SetScript("OnEnter", function(self)
            self:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                tile = true, tileSize = 16
            })
            self:SetBackdropColor(0.18, 0.95, 0.55, 0.07) -- #2ef18c with 7% opacity
        end)
        
        line:SetScript("OnLeave", function(self)
            self:SetBackdrop(nil)
        end)
        
        -- Add bottom border
        local border = line:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("BOTTOMLEFT", 0, 0)
        border:SetPoint("BOTTOMRIGHT", 0, 0)
        border:SetHeight(1)
        border:SetColorTexture(0.133, 0.133, 0.149, 1.0) -- #222226
        
        line.player = line:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line.player:SetPoint("LEFT", 10, 0)
        line.player:SetWidth(130)
        line.player:SetJustifyH("LEFT")
        line.player:SetTextColor(0.827, 0.827, 0.831, 1.0) -- #d3d3d4
        
        line.item = line:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line.item:SetPoint("LEFT", 150, 0)
        line.item:SetWidth(130)
        line.item:SetJustifyH("LEFT")
        line.item:SetTextColor(0.667, 1.0, 0.827, 1.0) -- #aaffd3
        
        line.time = line:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line.time:SetPoint("LEFT", 290, 0)
        line.time:SetWidth(80)
        line.time:SetJustifyH("LEFT")
        line.time:SetTextColor(0.906, 0.8, 0.502, 1.0) -- #e7cc80
        
        linesPool[index] = line
    end
    return linesPool[index]
end

-- Function to show notification
local notifTimer = nil
local function ShowNotification(message)
    notifArea:SetText(message)
    notifArea:SetAlpha(1)
    
    if notifTimer then
        notifTimer:Cancel()
    end
    
    notifTimer = C_Timer.NewTimer(3.5, function()
        local startTime = GetTime()
        local fadeTime = 0.3
        
        local fadeFrame = CreateFrame("Frame")
        fadeFrame:SetScript("OnUpdate", function(self)
            local elapsed = GetTime() - startTime
            if elapsed > fadeTime then
                notifArea:SetAlpha(0)
                self:SetScript("OnUpdate", nil)
            else
                notifArea:SetAlpha(1 - (elapsed / fadeTime))
            end
        end)
    end)
end

-- Button handlers
startButton:SetScript("OnClick", function()
    addon.state.isSessionActive = true
    addon.state.sessionStartTime = time()
    startButton:Hide()
    stopButton:Show()
    statusText:SetText("Session Active")
    statusText:SetTextColor(0.18, 0.95, 0.55, 1.0) -- #2ef18c
    ShowNotification("Session started! Waiting for whispers...")
    AnnounceToRaid()
end)

stopButton:SetScript("OnClick", function()
    addon.state.isSessionActive = false
    stopButton:Hide()
    startButton:Show()
    statusText:SetText("Idle")
    statusText:SetTextColor(0.596, 0.596, 0.604, 1.0) -- #98989a
    ShowNotification("Session stopped.")
    
    -- Display summary
    print("\nReservation Summary:")
    for player, items in pairs(addon.state.reservations) do
        print(string.format("%s:", player))
        for _, reservation in ipairs(items) do
            print(string.format("  %s - %s", reservation.item, reservation.time))
        end
    end
end)

clearButton:SetScript("OnClick", function()
    addon.state.reservations = {}
    UpdateDisplay()
    ShowNotification("All reservations cleared.")
end)

local broadcastCooldown = false
broadcastButton:SetScript("OnClick", function()
    if broadcastCooldown then return end
    
    AnnounceToRaid()
    ShowNotification("Broadcast sent to raid!")
    
    broadcastButton:Disable()
    broadcastButton:SetText("Cooldown...")
    broadcastCooldown = true
    
    C_Timer.After(10, function()
        broadcastButton:Enable()
        broadcastButton:SetText(addon.L["CMD_BROADCAST"])
        broadcastCooldown = false
    end)
end)

-- Export functionality
exportButton:SetScript("OnClick", function()
    local exportText = FormatReservationsForExport()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        C_Timer.After(0.1, function()
            CopyToClipboard(exportText)
            ShowNotification("Reservations exported to clipboard!")
        end)
    else
        -- For Classic/MoP where CopyToClipboard might not exist
        local dialog = StaticPopupDialogs["RAIDRESERVE_EXPORT"] or {
            text = "Press Ctrl+C to copy the reservations:",
            button2 = CLOSE,
            hasEditBox = true,
            editBoxWidth = 350,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            OnShow = function(self)
                self.editBox:SetText(exportText)
                self.editBox:HighlightText()
                self.editBox:SetFocus()
            end,
            OnHide = function(self)
                self.editBox:SetText("")
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
        }
        StaticPopupDialogs["RAIDRESERVE_EXPORT"] = dialog
        StaticPopup_Show("RAIDRESERVE_EXPORT")
    end
end)

-- Function to update the display
local function UpdateDisplay()
    -- Hide all existing lines
    for _, line in pairs(linesPool) do
        line:Hide()
    end
    
    -- Calculate total entries and update content frame size
    local totalEntries = 0
    for _, items in pairs(addon.state.reservations) do
        totalEntries = totalEntries + #items
    end
    
    local lineHeight = 30
    local headerHeight = 30
    local totalHeight = math.max(scrollFrame:GetHeight(), headerHeight + (totalEntries * lineHeight))
    contentFrame:SetHeight(totalHeight)
    
    -- Update display lines
    local currentLine = 1
    for player, items in pairs(addon.state.reservations) do
        for _, reservation in ipairs(items) do
            local line = AcquireLine(currentLine)
            line:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -(headerHeight + ((currentLine-1) * lineHeight)))
            line:Show()
            
            line.player:SetText(player)
            line.item:SetText(reservation.item)
            line.time:SetText(reservation.time)
            
            currentLine = currentLine + 1
        end
    end
end

-- Register events for UI updates
local function OnEvent(self, event, ...)
    if event == "CHAT_MSG_WHISPER" then
        UpdateDisplay()
        if addon.state.isSessionActive then
            ShowNotification(string.format("Received reservation from %s", select(2, ...)))
        end
    end
end

mainFrame:SetScript("OnEvent", OnEvent)
mainFrame:RegisterEvent("CHAT_MSG_WHISPER")

-- Function to toggle frame visibility
function addon:ToggleUI()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        UpdateDisplay()
    end
end

-- Create minimap button
local minimapButton = CreateFrame("Button", "RaidReserveMinimapButton", Minimap)
minimapButton:SetSize(34, 34)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetMovable(true)

-- Set button appearance
minimapButton:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
minimapButton:SetBackdropColor(0.125, 0.125, 0.133, 1.0) -- #202022
minimapButton:SetBackdropBorderColor(0.149, 0.149, 0.176, 1.0) -- #26262d

-- Create text
local buttonText = minimapButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
buttonText:SetPoint("CENTER")
buttonText:SetText("RR")
buttonText:SetTextColor(0.18, 0.95, 0.55, 1.0) -- #2ef18c

-- Button interaction
minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("RaidReserve")
    GameTooltip:AddLine("Click to toggle window", 1, 1, 1)
    GameTooltip:Show()
    self:SetBackdropBorderColor(0.18, 0.95, 0.55, 1.0) -- #2ef18c
    self:SetBackdropColor(0.208, 0.208, 0.255, 1.0) -- #353541
end)

minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    self:SetBackdropBorderColor(0.149, 0.149, 0.176, 1.0) -- #26262d
    self:SetBackdropColor(0.125, 0.125, 0.133, 1.0) -- #202022
end)

minimapButton:SetScript("OnClick", function()
    addon:ToggleUI()
end)

-- Minimap button positioning
local minimapShapes = {
    ["ROUND"] = { true, true, true, true },
    ["SQUARE"] = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { false, false, false, true },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"] = { true, false, false, false },
    ["SIDE-LEFT"] = { false, true, false, true },
    ["SIDE-RIGHT"] = { true, false, true, false },
    ["SIDE-TOP"] = { false, false, true, true },
    ["SIDE-BOTTOM"] = { true, true, false, false },
    ["TRICORNER-TOPLEFT"] = { false, true, true, true },
    ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local function UpdateMinimapButton()
    local angle = math.rad(addon.db.minimapPos or 225)
    local x, y = cos(angle), sin(angle)
    local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadTable = minimapShapes[minimapShape]
    local w = (Minimap:GetWidth() / 2) + 5
    local h = (Minimap:GetHeight() / 2) + 5
    local q = 1
    if x < 0 then q = q + 1 end
    if y < 0 then q = q + 2 end
    if quadTable[q] then
        x = x*w
        y = y*h
    else
        local diagRadiusW = sqrt(2*(w)^2)-10
        local diagRadiusH = sqrt(2*(h)^2)-10
        x = math.max(-w, math.min(x*diagRadiusW, w))
        y = math.max(-h, math.min(y*diagRadiusH, h))
    end
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetScript("OnDragStart", function()
    minimapButton:StartMoving()
end)

minimapButton:SetScript("OnDragStop", function()
    minimapButton:StopMovingOrSizing()
    local cx, cy = Minimap:GetCenter()
    local px, py = minimapButton:GetCenter()
    local angle = math.deg(math.atan2(py - cy, px - cx))
    addon.db.minimapPos = angle
    UpdateMinimapButton()
end)

UpdateMinimapButton()

-- Add slash command for toggling UI
SLASH_CMD_LIST["show"] = function()
    addon:ToggleUI()
end