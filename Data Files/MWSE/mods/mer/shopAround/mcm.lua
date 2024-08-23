local common = require("mer.shopAround.common")
local messages = common.messages
local config = common.config
local metadata = config.metadata

local LINKS_LIST = {
    {
        text = messages.ReleaseHistory(),
        url = "https://github.com/jhaakma/shop-around/releases"
    },
    -- {
    --     text = "Nexus",
    --     url = "https://www.nexusmods.com/morrowind/mods/52872"
    -- },
    {
        text = messages.BuyMeACoffee(),
        url = "https://ko-fi.com/merlord"
    },
}
local CREDITS_LIST = {
    {
        text = messages.MadeBy(),
        url = "https://www.nexusmods.com/users/3040468?tab=user+files",
    },
}

local function addSideBar(component)
    component.sidebar:createCategory(metadata.package.name)
    component.sidebar:createInfo{ text = metadata.package.description}

    local linksCategory = component.sidebar:createCategory(messages.Links())
    for _, link in ipairs(LINKS_LIST) do
        linksCategory:createHyperLink{ text = link.text, url = link.url }
    end
    local creditsCategory = component.sidebar:createCategory(messages.Credits())
    for _, credit in ipairs(CREDITS_LIST) do
        if credit.url then
            creditsCategory:createHyperLink{ text = credit.text, url = credit.url }
        else
            creditsCategory:createInfo{ text = credit.text }
        end
    end
end

local function registerMCM()
    local template = mwse.mcm.createTemplate{ name = metadata.package.name }
    template:saveOnClose(metadata.package.name, config.mcm)
    template:register()

    local page = template:createSideBarPage{ label = messages.Settings()}
    addSideBar(page)

    page:createOnOffButton{
        label = messages.EnableMod(),
        description = messages.EnableModDescription(),
        variable = mwse.mcm.createTableVariable{
            id = "enableDirectPurchase",
            table = config.mcm
        }
    }

    page:createDropdown{
        label = messages.LogLevel(),
        description = messages.LogLevelDescription(),
        options = {
            { label = "TRACE", value = "TRACE"},
            { label = "DEBUG", value = "DEBUG"},
            { label = "INFO", value = "INFO"},
            { label = "ERROR", value = "ERROR"},
            { label = "NONE", value = "NONE"},
        },
        variable =  mwse.mcm.createTableVariable{ id = "logLevel", table = config.mcm},
        callback = function(self)
            for _, logger in pairs(common.loggers) do
                logger:setLogLevel(self.variable.value)
            end
        end
    }

end
event.register("modConfigReady", registerMCM)
