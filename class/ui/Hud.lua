local Hud = class()

function Hud:constructor(ui, color)
    self.ui = ui

    self.color = color or sea.Color.white

    local armorColor = sea.getColor("armor")

    self.inventory = bh.Inventory.new(self, 824, 406, self.color)

    self.health = {
        icon = ui:createPanel("<spritesheet:gfx/hud_symbols.bmp:64:64:b>", 20, 444, sea.Style.new({
            frame = 1,
            scale = {x = 0.2, y = 0.2}
        })),
        text = ui:createText("100", 30, 444, sea.Style.new({
            verticalAlign = 1,
            textSize = 10
        })),

        bar = bh.Bar.new(ui, 10, 466, sea.Color.white, {x = 2, y = 0.5})
    }

    self.armor = {
        icon = ui:createPanel("<spritesheet:gfx/hud_symbols.bmp:64:64:b>", 70, 444, sea.Style.new({
            frame = 2,
            scale = {x = 0.2, y = 0.2},
            color = armorColor
        })),
        text = ui:createText("0", 80, 444, sea.Style.new({
            verticalAlign = 1,
            color = armorColor,
            textSize = 10
        })),

        bar = bh.Bar.new(ui, 10, 458, armorColor, {x = 2, y = 0.25})
    }

    self.ammo = {
        text = ui:createText("0", 806, 462, sea.Style.new({
            align = 2,
            verticalAlign = 1,
            textSize = 26
        })),
        spareText = ui:createText("/ 000", 840, 466, sea.Style.new({
            align = 2,
            verticalAlign = 1,
            opacity = 0.66
        }))
    }

    self.currentWeaponText = ui:createText("None", 840, 436, sea.Style.new({
        align = 2,
        verticalAlign = 1,
        textSize = 10,
        opacity = 0.66
    }))

    self.moneyText = ui:createText("$0", 10, 110, sea.Style.new({
        color = sea.Color.green
    }))
end

function Hud:addInventorySlotFor(itemType)
    if not bh.config.inventory then
        return
    end

    if itemType.slot == 0 then
        return
    end

    self.inventory:addSlot(itemType.slot, itemType.id, itemType:getImagePath("kill"))
end

function Hud:removeInventorySlotFor(itemType)
    if not bh.config.inventory then
        return
    end

    self.inventory:removeSlot(itemType.id)
end

function Hud:activateSlot(itemType)
    if not bh.config.inventory then
        return
    end

    self.inventory:activateSlot(itemType.id)
end

function Hud:updateInventory()
    if not bh.config.inventory then
        return
    end

    self.inventory:update()
end

function Hud:getAllInventorySlots()
    if not bh.config.inventory then
        return
    end

    return self.inventory:getAllSlots()
end

function Hud:setInventoryColor(color)
    if not bh.config.inventory then
        return
    end
    
    self.inventory:setColor(color)
end

function Hud:destroyInventory()
    if not bh.config.inventory then
        return
    end

    self.inventory:destroy()
end

function Hud:refreshInventory(with)
    if not bh.config.inventory then
        return
    end

    self.inventory:destroy()

    for _, itemType in pairs(with) do
        self.inventory:addSlot(itemType.slot, itemType.id, itemType:getImagePath("kill"))
    end
end

function Hud:updateHealth(health, maxHealth, color)
    local ratio = health / maxHealth

    local healthHUD = self.health

    healthHUD.icon.style.color = color
    healthHUD.icon:update()

    healthHUD.text:setText(health)
    healthHUD.text.style.color = color
    healthHUD.text:update()

    healthHUD.bar:setRatio(ratio)
    healthHUD.bar:setColor(color)

    local ammoHUD = self.ammo

    ammoHUD.text.style.color = color
    ammoHUD.text:update()
    ammoHUD.spareText.style.color = color
    ammoHUD.spareText:update()

    local currentWeaponText = self.currentWeaponText

    currentWeaponText.style.color = color
    currentWeaponText:update()

    self.inventory:setColor(color)
end

function Hud:updateArmor(armor, maxArmor)
    local ratio = armor / maxArmor

    if armor > 200 then
        armor = sea.ItemType.armorToItem(armor).name
        
        ratio = 1
    end

    local armorHUD = self.armor

    armorHUD.bar:setRatio(ratio)
    armorHUD.text:setText(tostring(armor):upper())
end

function Hud:updateAmmo(loaded, spare)
    loaded = loaded or "0"
    spare = sea.game.infiniteAmmo == "1" and "INF" or string.format("%03d", (spare or "0"))

    local ammoHUD = self.ammo

    ammoHUD.text:setText(loaded)
    ammoHUD.spareText:setText("/ "..spare)
end

function Hud:updateMoney(money)
    self.moneyText:setText("$"..money)
end

function Hud:updateCurrentWeapon(itemType)
    self.currentWeaponText:setText(itemType.name)

    self.inventory:activateSlot(itemType.id)
end

-------------------------
--        INIT         --
-------------------------

return Hud