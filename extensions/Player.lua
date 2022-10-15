function sea.Player:onItemAdded(itemType)
    if itemType:isArmor() then
        self:updateArmor(itemType:toArmor())
    end

    self:addInventorySlot(itemType)

    self:updateAmmo()
    self:updateCurrentWeapon()
end

function sea.Player:addInventorySlot(itemType)
    if not bh.config.inventory then
        return
    end

    local slot = itemType.slot

    if itemType.slot == 0 then
        return
    end

    local inventory = self.hud.inventory

    local color = bh.getHealthBarColor(self.health / self.maxHealth)

    if not inventory[slot] then
        inventory[slot] = {}

        inventory[slot][-1] = self.ui:createText(slot, 846, 0, sea.Style.new({
            align = 1,
            verticalAlign = 1,
            textSize = 10,
            color = color
        }))
    end

    if inventory[slot][itemType.id] then
        return
    end

    inventory[slot][itemType.id] = bh.InventorySlot.new(self.ui, itemType:getImagePath("kill"), 0, 0, color)

    self:updateInventory()
end

function sea.Player:removeInventorySlot(itemType)
    if not bh.config.inventory then
        return
    end

    local slot = itemType.slot

    if itemType.slot == 0 then
        return
    end

    local inventory = self.hud.inventory

    if not inventory[slot] then
        return
    end

    if not inventory[slot][itemType.id] then
        return
    end

    inventory[slot][itemType.id]:destroy()
    inventory[slot][itemType.id] = nil

    if table.count(inventory[slot]) <= 1 then
        inventory[slot][-1]:destroy()
        inventory[slot] = nil
    end

    self:updateInventory()
end

function sea.Player:updateInventory()
    if not bh.config.inventory then
        return
    end

    local startX, startY = 824, 406

    for slotsID, slots in pairs(self.hud.inventory) do
        slots[-1]:setPosition(846, startY)

        for slotID, slot in pairs(slots) do
            if slotID > -1 then
                slot:setPosition(startX, startY)

                startX = startX - 34
            end
        end

        startX = 824
        startY = startY - 34
    end
end

function sea.Player:updateHealth(health, maxHealth)
    health = health or self.health
    maxHealth = maxHealth or self.maxHealth

    local ratio = health / maxHealth
    local color = bh.getHealthBarColor(ratio)

    local hud = self.hud
    local healthHUD = hud.health

    healthHUD.icon.style.color = color
    healthHUD.icon:update()

    healthHUD.text:setText(health)
    healthHUD.text.style.color = color
    healthHUD.text:update()

    healthHUD.bar:setRatio(ratio)
    healthHUD.bar:setColor(color)

    local ammoHUD = hud.ammo

    ammoHUD.text.style.color = color
    ammoHUD.text:update()
    ammoHUD.spareText.style.color = color
    ammoHUD.spareText:update()

    local currentWeaponText = hud.currentWeaponText

    currentWeaponText.style.color = color
    currentWeaponText:update()

    for _, menu in pairs(hud.inventory) do
        for _, slot in pairs(menu) do
            if slot.slotImage then -- if it is a inventory slot
                slot:setColor(color)
            else 
                -- it is a text
                slot.style.color = color
                slot:update()
            end
        end
    end
end

function sea.Player:updateArmor(armor, maxArmor)
    armor = armor or self.armor
    maxArmor = maxArmor or 100

    local ratio = armor / maxArmor

    if armor > 200 then
        armor = sea.ItemType.armorToItem(armor).name
        
        ratio = 1
    end

    self.hud.armor.bar:setRatio(ratio)

    self.hud.armor.text:setText(tostring(armor):upper())
end

function sea.Player:updateAmmo(loaded, spare)
    local ammo = self:getCurrentAmmo()

    loaded = loaded or ammo[1] or "0"
    spare = sea.game.infiniteAmmo == "1" and "INF" or (spare or ammo[2] or "0")

    spare = string.format("%03d", spare)

    self.hud.ammo.text:setText(loaded)
    self.hud.ammo.spareText:setText("/ "..spare)
end

function sea.Player:updateMoney(money)
    money = money or self.money

    self.hud.moneyText:setText("$"..money)
end

function sea.Player:updateCurrentWeapon(itemType)
    itemType = itemType or self.item

    if not itemType then
        return
    end

    self.lastSelectedItem = itemType

    local hud = self.hud

    hud.currentWeaponText:setText(itemType.name)

    if not bh.config.inventory then
        return
    end

    for _, slot in pairs(self:getAllInventorySlots()) do
        slot:deactivate()
    end

    local menu = hud.inventory[itemType.slot]

    if not menu then
        return
    end

    if not menu[itemType.id] then
        return
    end

    menu[itemType.id]:activate()
end

function sea.Player:getAllInventorySlots()
    if not bh.config.inventory then
        return
    end

    local slots = {}

    for _, menu in pairs(self.hud.inventory) do
        for slotID, slot in pairs(menu) do
            if slotID > -1 then
                table.insert(slots, slot)
            end
        end
    end

    return slots
end

function sea.Player:destroyInventory()
    if not bh.config.inventory then
        return
    end

    for _, menu in pairs(self.hud.inventory) do
        for _, slot in pairs(menu) do
            slot:destroy()
        end
    end

    self.hud.inventory = {}
end

function sea.Player:refreshInventory()
    if not bh.config.inventory then
        return
    end

    self:destroyInventory()

    for _, itemType in pairs(self:getItems()) do
        self:addInventorySlot(itemType)
    end
end