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
    player.ammoText = ui:createText("0", 810, 462, sea.Style.new({
        align = 2,
        verticalAlign = 1,
        textSize = 26
    }))
    player.ammoSpareText = ui:createText("/ 0", 840, 466, sea.Style.new({
        align = 2,
        verticalAlign = 1
    }))

    -- Current Weapon
    player.currentWeaponText = ui:createText("None", 840, 436, sea.Style.new({
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
        for _, slot in pairs(player:getAllInventorySlots()) do
            slot:destroy()
        end

        player.hud.inventory = {}

        for _, itemType in pairs(player:getItems()) do
            player:addInventorySlot(itemType)
        end

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

sea.addEvent("onHookDrop", function(player, item, itemType)
    if itemType.id == 50 then
        return
    end

    local function update()
        player:removeInventorySlot(itemType)
        player:updateAmmo()
        player:updateCurrentWeapon()
    end

    timerEx(1, update)
end)

sea.addEvent("onHookBuy", function(player, itemType)
    local money = player.money

    function update(player)
        if money == player.money then
            -- Buy wasn't processed
            return
        end

        if itemType:isArmor() then
            player:updateArmor(itemType:toArmor())
        end

        player:addInventorySlot(itemType)

        player:updateAmmo()
        player:updateCurrentWeapon()
    end

    timerEx(1, "update", 1, player)
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

-- Extensions

function sea.Player:addInventorySlot(itemType)
    local slot = itemType.slot

    if itemType.slot == 0 then
        return
    end

    if not self.hud.inventory[slot] then
        self.hud.inventory[slot] = {}

        self.hud.inventory[slot][-1] = self.ui:createText(slot, 846, 0, sea.Style.new({
            align = 1,
            verticalAlign = 1,
            textSize = 10
        }))
    end

    self.hud.inventory[slot][itemType.id] = bh.InventorySlot.new(self.ui, itemType:getImagePath("kill"), 0, 0)

    self:updateInventory()
end

function sea.Player:removeInventorySlot(itemType)
    local slot = itemType.slot

    if itemType.slot == 0 then
        return
    end

    if not self.hud.inventory[slot] then
        return
    end

    if not self.hud.inventory[slot][itemType.id] then
        return
    end

    self.hud.inventory[slot][itemType.id]:destroy()
    self.hud.inventory[slot][itemType.id] = nil

    if table.count(self.hud.inventory[slot]) <= 1 then
        self.hud.inventory[slot][-1]:destroy()
        self.hud.inventory[slot] = nil
    end

    self:updateInventory()
end

function sea.Player:updateInventory()
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
    self.ammoSpareText:setText("/ "..(spare or "INF"))
end

function sea.Player:updateCurrentWeapon(itemType)
    itemType = itemType or self.item

    if not itemType then
        return
    end

    self.currentWeaponText:setText(itemType.name)

    for _, slot in pairs(self:getAllInventorySlots()) do
        slot:deactivate()
    end

    self.hud.inventory[itemType.slot][itemType.id]:activate()
end

function sea.Player:getAllInventorySlots()
    local s = {}

    for _, slots in pairs(self.hud.inventory) do
        for slotID, slot in pairs(slots) do
            if slotID > -1 then
                table.insert(s, slot)
            end
        end
    end

    return s
end