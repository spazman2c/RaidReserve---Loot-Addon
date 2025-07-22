-- Create addon namespace
local addonName, addon = ...

-- Initialize addon frame and register events
local RaidReserve = CreateFrame("Frame")
RaidReserve:RegisterEvent("ADDON_LOADED")
RaidReserve:RegisterEvent("CHAT_MSG_WHISPER")
RaidReserve:RegisterEvent("RAID_ROSTER_UPDATE")
RaidReserve:RegisterEvent("GROUP_ROSTER_UPDATE")

-- Initialize addon state
addon.state = {
    isSessionActive = false,
    reservations = {},
    lastAnnounce = 0,
    announceInterval = 300 -- 5 minutes in seconds
}

-- Utility functions
local function GetTimeStamp()
    return date("%H:%M:%S")
end

local function ExtractItemLink(text)
    if not text then return nil end
    
    local itemLink = text:match("(|c%x+|Hitem:%d+:.-|h.-|h|r)")
    if not itemLink then
        return nil
    end
    
    -- Validate item level for MoP content
    local itemID = itemLink:match("Hitem:(%d+)")
    if itemID then
        local _, _, itemRarity, itemLevel = GetItemInfo(itemID)
        -- MoP items are generally between levels 372-516
        if itemLevel and (itemLevel < 372 or itemLevel > 516) then
            return nil
        end
    end
    
    return itemLink
end

local function ValidateReservation(player, itemLink)
    if not player or not itemLink then
        return false, "Invalid player or item"
    end
    
    -- Check if player is in raid/party
    if not UnitInRaid(player) and not UnitInParty(player) then
        return false, "Player must be in your raid or party"
    end
    
    -- Check for duplicate reservations
    if addon.state.reservations[player] then
        for _, reservation in ipairs(addon.state.reservations[player]) do
            if reservation.item == itemLink then
                return false, "Item already reserved by this player"
            end
        end
    end
    
    return true
end

local function AnnounceToRaid()
    if IsInRaid() then
        SendChatMessage("Whisper me items you want to reserve!", "RAID_WARNING")
    elseif IsInGroup() then
        SendChatMessage("Whisper me items you want to reserve!", "PARTY")
    end
    addon.state.lastAnnounce = GetTime()
end

local function AddReservation(player, itemLink)
    -- Validate the reservation
    local isValid, errorMsg = ValidateReservation(player, itemLink)
    if not isValid then
        SendChatMessage(string.format("Cannot reserve item: %s", errorMsg), "WHISPER", nil, player)
        return false
    end
    
    -- Initialize player's reservation table if it doesn't exist
    if not addon.state.reservations[player] then
        addon.state.reservations[player] = {}
    end
    
    -- Add the reservation
    table.insert(addon.state.reservations[player], {
        item = itemLink,
        time = GetTimeStamp()
    })
    
    -- Notify player and raid
    SendChatMessage(string.format("Successfully reserved %s", itemLink), "WHISPER", nil, player)
    if IsInRaid() then
        SendChatMessage(string.format("%s reserved %s", player, itemLink), "RAID")
    elseif IsInGroup() then
        SendChatMessage(string.format("%s reserved %s", player, itemLink), "PARTY")
    end
    
    return true
end

-- Slash command handler
SLASH_CMD_LIST = {
    ["start"] = function()
        if not addon.state.isSessionActive then
            addon.state.isSessionActive = true
            addon.state.reservations = {}
            addon.state.sessionStartTime = time()
            AnnounceToRaid()
            SaveSession()
            print(addon.L["CMD_START"])
        else
            print(addon.L["CMD_ALREADY_ACTIVE"])
        end
    end,
    ["stop"] = function()
        if addon.state.isSessionActive then
            addon.state.isSessionActive = false
            ClearSavedSession()
            print(addon.L["CMD_STOP"])
            -- Display summary
            print("\nReservation Summary:")
            for player, items in pairs(addon.state.reservations) do
                print(string.format("%s:", player))
                for _, reservation in ipairs(items) do
                    print(string.format("  %s - %s", reservation.item, reservation.time))
                end
            end
        else
            print(addon.L["CMD_NO_ACTIVE_SESSION"])
        end
    end,
    ["clear"] = function()
        addon.state.reservations = {}
        ClearSavedSession()
        print(addon.L["CMD_CLEAR"])
    end,
    ["announce"] = function()
        if addon.state.isSessionActive then
            local currentTime = GetTime()
            if currentTime - addon.state.lastAnnounce >= addon.state.announceInterval then
                AnnounceToRaid()
            else
                print(string.format("Please wait %.0f seconds before announcing again.", 
                    addon.state.announceInterval - (currentTime - addon.state.lastAnnounce)))
            end
        else
            print(addon.L["CMD_NO_ACTIVE_SESSION"])
        end
    end,
    ["help"] = function()
        print(addon.L["HELP_HEADER"])
        print(addon.L["HELP_START"])
        print(addon.L["HELP_STOP"])
        print(addon.L["HELP_CLEAR"])
        print(addon.L["HELP_SHOW"])
    end
}

-- Register slash commands
SLASH_COMMANDS = {
    "res",
    "raidreserve"
}

local function HandleSlashCommand(msg)
    local command = string.lower(msg or "")
    if command == "" then command = "help" end
    
    if SLASH_CMD_LIST[command] then
        SLASH_CMD_LIST[command]()
    else
        SLASH_CMD_LIST["help"]()
    end
end

-- Event handler
-- Function to save current session
local function SaveSession()
    if not addon.state.isSessionActive then return end
    
    RaidReserveDB = RaidReserveDB or {}
    RaidReserveDB.currentSession = {
        reservations = addon.state.reservations,
        startTime = addon.state.sessionStartTime
    }
end

-- Function to load saved session
local function LoadSession()
    if not RaidReserveDB or not RaidReserveDB.currentSession then return end
    
    addon.state.reservations = RaidReserveDB.currentSession.reservations
    addon.state.sessionStartTime = RaidReserveDB.currentSession.startTime
    addon.state.isSessionActive = true
    
    print("RaidReserve: Previous session restored")
end

-- Function to clear saved session
local function ClearSavedSession()
    if RaidReserveDB then
        RaidReserveDB.currentSession = nil
    end
end

RaidReserve:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        -- Initialize saved variables
        RaidReserveDB = RaidReserveDB or {}
        
        -- Register slash commands
        for _, cmd in ipairs(SLASH_COMMANDS) do
            _G["SLASH_" .. string.upper(addonName) .. "1"] = "/" .. cmd
            SlashCmdList[string.upper(addonName)] = HandleSlashCommand
        end
        
        -- Load previous session if exists
        LoadSession()
        
    elseif event == "CHAT_MSG_WHISPER" then
        local msg, sender = ...
        
        if addon.state.isSessionActive then
            local itemLink = ExtractItemLink(msg)
            if itemLink then
                AddReservation(sender, itemLink)
            end
        end
    end
end)