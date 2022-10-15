function sea.Player:onItemAdded(itemType)
    if itemType:isArmor() then
        self:updateArmor(itemType:toArmor())
    end

    self.hud:addInventorySlotFor(itemType)

    self:updateAmmo()
    self:updateCurrentWeapon()
end

function sea.Player:onItemRemoved(itemType)
    self.hud:removeInventorySlotFor(itemType)

    self:updateAmmo()
    self:updateCurrentWeapon()
end

function sea.Player:updateHealth(health, maxHealth)
    health = health or self.health
    maxHealth = maxHealth or self.maxHealth

    local color = bh.getHealthBarColor(health / maxHealth)

    self.hud:updateHealth(health, maxHealth, color)
end

function sea.Player:updateArmor(armor, maxArmor)
    armor = armor or self.armor
    maxArmor = maxArmor or 100

    self.hud:updateArmor(armor, maxArmor)
end

function sea.Player:updateAmmo(loaded, spare)
    local ammo = self:getCurrentAmmo()

    self.hud:updateAmmo(loaded or ammo[1], spare or ammo[2])
end

function sea.Player:updateMoney(money)
    money = money or self.money

    self.hud:updateMoney(money)
end

function sea.Player:updateCurrentWeapon(itemType)
    itemType = itemType or self.item

    if not itemType then
        return
    end

    self.lastSelectedItem = itemType

    self.hud:updateCurrentWeapon(itemType)
end