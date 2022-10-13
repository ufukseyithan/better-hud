bh.Bar = dofile("sys/lua/sea-framework/app/better-hud/class/Bar.lua")
bh.InventorySlot = dofile("sys/lua/sea-framework/app/better-hud/class/InventorySlot.lua")

-- Events

sea.addEvent("onHookJoin", function(player)
    local ui = player.ui

    player.hud = {
        inventory = {}
    }

    -- Health
    player.healthIcon = ui:createPanel("<spritesheet:gfx/hud_symbols.bmp:64:64:b>", 20, 444, sea.Style.new({
        frame = 1,
        scale = {x = 0.2, y = 0.2}
    }))
    player.healthText = ui:createText("100", 30, 444, sea.Style.new({
        verticalAlign = 1,
        textSize = 10
    }))

    player.healthBar = bh.Bar.new(ui, 10, 466, sea.Color.white, {x = 2, y = 0.5})

    -- Armor
    local armorColor = sea.Color.new(50, 50, 220)

    player.armorIcon = ui:createPanel("<spritesheet:gfx/hud_symbols.bmp:64:64:b>", 70, 444, sea.Style.new({
        frame = 2,
        scale = {x = 0.2, y = 0.2},
        color = armorColor
    }))
    player.armorText = ui:createText("0", 80, 444, sea.Style.new({
        verticalAlign = 1,
        color = armorColor,
        textSize = 10
    }))

    player.armorBar = bh.Bar.new(ui, 10, 458, armorColor, {x = 2, y = 0.25})

    -- Ammo
    player.ammoText = ui:createText("0", 790, 462, sea.Style.new({
        align = 2,
        verticalAlign = 1,
        textSize = 26
    }))
    player.ammoSpareText = ui:createText("/ 0", 800, 466, sea.Style.new({
        verticalAlign = 1
    }))

    -- Current Weapon
    player.currentWeaponText = ui:createText("None", 830, 442, sea.Style.new({
        align = 2,
        verticalAlign = 1,
        textSize = 10
    }))
end)

sea.addEvent("onHookSpawn", function(player)
    -- show hud

    player:updateHealth()
    player:updateArmor()

    local function updateCurrentWeapon()
        player:updateAmmo()
        player:updateCurrentWeapon()
    end

    timerEx(1, updateCurrentWeapon)
end)

sea.addEvent("onHookDie", function(player)
    -- hide hud
end)

sea.addEvent("onHookCollect", function(player, item, itemType)
    player:updateArmor()
    player:addInventorySlot(itemType)
end)

sea.addEvent("onHookBuy", function(player, itemType)
    if itemType:isArmor() then
        player:updateArmor(itemType:toArmor())
    end

    player:addInventorySlot(itemType)
end)

sea.addEvent("onHookAttack", function(player)
    -- Bots do give error for some reason
    if player.bot then
        return
    end

    player:updateAmmo()
end)

sea.addEvent("onHookSelect", function(player)
    player:updateAmmo()
    player:updateCurrentWeapon()
end)

sea.addEvent("onHookReload", function(player)
    player:updateAmmo()
end)

sea.addEvent("onHookHit", function(player, source, itemType, damage, armorDamage)
    player:updateHealth(player.health - damage)
    player:updateArmor(player.armor - armorDamage)
end)

-- Functions

function bh.getHealthBarColor(ratio)
    if ratio <= 0.3 then 
        return sea.Color.new(255, 20, 20)
    elseif ratio < 1 then
        return sea.Color.new(255, 200, 20)
    else
        return sea.Color.new(20, 255, 20)
    end
end

function sea.Player:addInventorySlot(itemType)
    local slot = itemType.slot

    self.hud.inventory[slot][itemType.id] = bh.InventorySlot.new(self.ui, itemType.imagePath, 70, 444)
end

function sea.Player:updateHealth(health, maxHealth)
    health = health or self.health
    maxHealth = maxHealth or self.maxHealth

    ratio = health / maxHealth

    local color = bh.getHealthBarColor(ratio)
    
    self.healthIcon.style.color = color
    self.healthIcon:update()

    self.healthText:setText(health)
    self.healthText.style.color = color
    self.healthText:update()

    self.healthBar:setRatio(ratio)
    self.healthBar:setColor(color)

    self.ammoText.style.color = color
    self.ammoText:update()
    self.ammoSpareText.style.color = color
    self.ammoSpareText:update()

    self.currentWeaponText.style.color = color
    self.currentWeaponText:update()
end

function sea.Player:updateArmor(armor, maxArmor)
    armor = armor or self.armor
    maxArmor = maxArmor or 100

    local ratio

    if armor > 200 then
        armor = sea.ItemType.armorToItem(armor).name
        
        ratio = armor / maxArmor
    else
        ratio = 1
    end

    self.armorBar:setRatio(ratio)

    self.armorText:setText(tostring(armor):upper())
end

function sea.Player:updateAmmo(loaded, spare)
    local ammo = self:getCurrentAmmo()

    loaded = loaded or ammo[1]
    spare = spare or ammo[2]

    self.ammoText:setText(loaded)
    self.ammoSpareText:setText("/ "..spare)
end

function sea.Player:updateCurrentWeapon(currentWeaponName)
    currentWeaponName = currentWeaponName or self.item.name

    self.currentWeaponText:setText(currentWeaponName)
end