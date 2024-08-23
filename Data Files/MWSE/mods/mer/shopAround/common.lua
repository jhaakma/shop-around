---@class ShopAround.Common
local common = {}
common.config = require("mer.shopAround.config")
local i18n = mwse.loadTranslations("mer.shopAround")

---@class ShopAround.i18n
---@field PurchaseMessage fun(data):string
---@field NotEnoughGold fun():string
---@field TooltipMessage fun(data):string
---@field ReleaseHistory fun():string
---@field BuyMeACoffee fun():string
---@field MadeBy fun():string
---@field Links fun():string
---@field Credits fun():string
---@field Settings fun():string
---@field EnableMod fun():string
---@field EnableModDescription fun():string
---@field LogLevel fun():string
---@field LogLevelDescription fun():string
common.messages = setmetatable({}, {
    __index = function(_, key)
        return function(data)
            return i18n(key, data)
        end
    end,
})
local MWSELogger = require("logging.logger")

---@type table<string, mwseLogger>
common.loggers = {}
function common.createLogger(serviceName)
    local logger = MWSELogger.new{
        name = string.format("%s - %s",
            common.config.metadata.package.name, serviceName),
        logLevel = common.config.mcm.logLevel,
        includeTimestamp = true,
    }
    common.loggers[serviceName] = logger
    return logger
end
local logger = common.createLogger("common")

---@return string #The version of the mod
function common.getVersion()
    return common.config.metadata.package.version
end

---Picks up any item reference, bypassing activate events
---@param reference tes3reference #The reference to pick up
---@param playSound boolean Default: false
function common.pickUp(reference, playSound)
    tes3.addItem{
        reference = tes3.player,
        item = reference.object,
        itemData = reference.itemData,
        count = reference.stackSize,
        playSound = false,
    }
    reference.itemData = nil
    reference:disable()
    reference:delete()
end

---Gets the NPC owner of mobile of a reference, if it has one
---Will return nil if the owner is not an NPC, such as a faction
---@param reference tes3reference
---@return tes3mobileNPC|nil
function common.getOwner(reference)
    local owner = tes3.getOwner{ reference = reference}
    if not owner then return end
    local ownerIsNPC = owner.objectType == tes3.objectType.npc
    if not ownerIsNPC then return end
    return tes3.getReference(owner.id).mobile
end

local function isLuaFile(file) return file:sub(-4, -1) == ".lua" end
local function isInitFile(file) return file == "init.lua" end
function common.initAll(path)
    path = "Data Files/MWSE/mods/" .. path .. "/"
    for file in lfs.dir(path) do
        if isLuaFile(file) and not isInitFile(file) then
            logger:debug("Executing file: %s", file)
            dofile(path .. file)
        end
    end
end

--[[
    Resets the indicators from mods like Essential Indicators and
    Ownership Indicator to the "default" view
]]
function common.resetModdedIndicators()
    local menu = tes3ui.findMenu("MenuMulti")
    if not menu then return end
    for _, id in ipairs(common.config.static.modIndicatorBlocks) do
        local block = menu:findChild(id)
        if block then
            --Hide all but the first in children
            for i=2, #block.children do
                block.children[i].visible = false
            end
            block.children[1].visible = true
            block.children[1].color = {1, 1, 1}
        end
    end
end


return common