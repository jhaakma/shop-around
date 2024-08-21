--[[
    Allows the player to purchase items directly by activating them.
    - Uses the base barter price for the item (as if they selected the item in trade and didn't attempt to haggle)
    - Requires the player to have enough gold to purchase the item
    - Sneak to steal the item instead
]]

local common = require("mer.shopAround.common")

---Open the dialog to purchase an item
---@param itemRef tes3reference
---@param owner tes3mobileNPC
local function openPurchaseMenu(itemRef, owner, price)
    local itemName = itemRef.object.name
    local message = string.format("Purchase %s for %s gold?", itemName, price)
    tes3ui.showMessageMenu{
        message = message,
        buttons = {
            { text = "Yes", callback = function()
                --remove ownership
                itemRef.itemData.owner = nil
                --pay
                tes3.payMerchant{
                    merchant = owner,
                    cost = price
                }
                tes3.playSound{ reference = tes3.player, sound = "Item Gold Up" }
                --pick up
                common.pickUp(itemRef, false)
            end},
        },
        cancels = true,
        cancelText = "No",
    }
end

local function canPurchase(target)
    if not common.config.mcm.enableDirectPurchase then return false end
    if not target then return false end
    if tes3.player.mobile.isSneaking then return false end
    if tes3.hasOwnershipAccess{ target = target} then return false end
    local owner = common.getOwner(target)
    if not owner then return false end
    if not owner.object:tradesItemType(target.object.objectType) then return false end
    return true
end


---Purchase an item by activating it
---@param e activateEventData
event.register("activate", function(e)
    local target = e.target
    if not canPurchase(target) then return end
    local owner = common.getOwner(target)
    local price = tes3.calculatePrice{
        bartering = true,
        object = target.object,
        itemData = target.itemData,
        buying = true,
        merchant = owner
    }
    --player has enough gold
    if tes3.getPlayerGold() < price then
        tes3.messageBox("You do not have enough gold to purchase this item.")
        return false
    end
    openPurchaseMenu(target, owner, price)
    return false
end, { priority = 100 })



---Show "Purchase" in tooltip if applicable
---@param e uiObjectTooltipEventData
event.register("uiObjectTooltip", function(e)
    local target = e.reference
  if not canPurchase(target) then return end
    local owner = common.getOwner(target)
    local price = tes3.calculatePrice{
        bartering = true,
        object = e.reference.object,
        itemData = e.reference.itemData,
        buying = true,
        merchant = owner
    }

    local text = string.format("Purchase (%s Gold)", price)
    local label = e.tooltip:createLabel{
        text = text,
        id = tes3ui.registerID("mer.accidentalTheftProtection.purchase"),
    }

    --player has enough gold
    if tes3.getPlayerGold() >= price then
        label.color = tes3ui.getPalette("active_color")
    else
        label.color = tes3ui.getPalette("disabled_color")
    end
end, { priority = -100 })

event.register("simulate", function(e)
    local target = tes3.getPlayerTarget()
    if not target then return end
    if canPurchase(target) then
        common.resetModdedIndicators()
    end
end, { priority = -100})