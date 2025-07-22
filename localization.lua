local addonName, addon = ...

-- Initialize localization table
local L = setmetatable({}, {
    __index = function(table, key)
        -- If no translation exists, return the key
        if type(key) == "nil" then return "" end
        return tostring(key)
    end
})

-- English (default) localization
local LOCALE = GetLocale()

if LOCALE == "enUS" or LOCALE == "enGB" then
    -- Commands
    L["CMD_START"] = "Session started. Players can now whisper you items to reserve."
    L["CMD_STOP"] = "Session stopped. No more reservations will be accepted."
    L["CMD_CLEAR"] = "All reservations cleared."
    L["CMD_ALREADY_ACTIVE"] = "A session is already active."
    L["CMD_NO_ACTIVE_SESSION"] = "No active session to stop."
    
    -- Help Text
    L["HELP_HEADER"] = "RaidReserve commands:"
    L["HELP_START"] = "/res start - Start a new reservation session"
    L["HELP_STOP"] = "/res stop - End the current session"
    L["HELP_CLEAR"] = "/res clear - Clear all reservations"
    L["HELP_SHOW"] = "/res show - Toggle the reservation window"
    
    -- UI Elements
    L["UI_EXPORT"] = "Export"
    L["UI_PLAYER"] = "Player"
    L["UI_ITEM"] = "Item"
    L["UI_TIME"] = "Time"
end

-- Make localization available to addon
addon.L = L