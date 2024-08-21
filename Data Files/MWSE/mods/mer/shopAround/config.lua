---@class ShopAround.Config
local config = {}

config.metadata = toml.loadFile("Data Files\\Shop Around-metadata.toml") --[[@as MWSE.Metadata]]

config.static = {
    vanillaIndicatorPath = "textures\\target.dds",
    defaultIndicatorPath = "textures\\mer_shopAround\\mer_ind_default.dds",
    stealIndicatorPath = "textures\\mer_shopAround\\mer_ind_hand.dds",
    modIndicatorBlocks = {
        "EssentialIndicators_block",
        "OwnershipIndicator_block",
    }
}

---@class ShopAround.Config.MCM
local mcmDefault = {
    ---If true, the player can purchase an item by activating it directly
    enableDirectPurchase = true,
    ---If true, the crosshair will be replaced with a different icon when sneaking and looking at an owned item
    enableStealCrosshair = true,
    ---The log level for the mod. One of "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"
    logLevel = "INFO",
    ---The scale of the crosshair icon
    crosshairScale = 1.0,
    ---The scale of the ownership indicator icon
    indicatorScale = 1.0,
    ---If true, hide the crosshair after a short delay
    autoHide = false,
    --If true, uses the Oblivion-style ownership indicator texture
    useTex = true,
}

---@type ShopAround.Config.MCM
config.mcm = mwse.loadConfig(config.metadata.package.name, mcmDefault)

config.save = function()
    mwse.saveConfig(config.metadata.package.name, config.mcm)
end

return config