bh.Bar = dofile("sys/lua/sea-framework/app/better-hud/class/Bar.lua")
bh.InventorySlot = dofile("sys/lua/sea-framework/app/better-hud/class/InventorySlot.lua")

local count = 0
for k, v in pairs(sea.itemType) do
	sea.Item.spawn(v.id, 10 + count, 15)
	count = count + 1
end

-- Events

sea.addEvent("onHookJoin", function(player)
    if player.bot then
        return
    end

    local ui = player.ui

    local armorColor = sea.getColor("armor")

    player.hud = {
        inventory = {},

        -- Health
        health = {
            icon = ui:createPanel("<spritesheet:gfx/hud_symbols.bmp:64:64:b>", 20, 444, sea.Style.new({
                frame = 1,
                scale = {x = 0.2, y = 0.2}
            })),
            text = ui:createText("100", 30, 444, sea.Style.new({
                verticalAlign = 1,
                textSize = 10
            })),

            bar = bh.Bar.new(ui, 10, 466, sea.Color.white, {x = 2, y = 0.5})
        },

        armor = {
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
        },

        ammo = {
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
        },

        -- Current Weapon
        currentWeaponText = ui:createText("None", 840, 436, sea.Style.new({
            align = 2,
            verticalAlign = 1,
            textSize = 10,
            opacity = 0.66
        })),

        moneyText = ui:createText("$0", 10, 110, sea.Style.new({
            color = sea.Color.green
        }))
    }
end)

sea.addEvent("onHookSpawn", function(player)
    if player.bot then
        return
    end

    -- show hud

    local function update()
        player:refreshInventory()

        player:updateHealth()
        player:updateArmor()
    
        player:updateAmmo()
        player:updateCurrentWeapon()

        player:updateMoney()
    end

    timerEx(1, update)
end)

sea.addEvent("onHookDie", function(player)
    if player.bot then
        return
    end
    
    -- hide hud
end)

sea.addEvent("onHookCollect", function(player, item, itemType)
    if player.bot then
        return
    end

    player:updateArmor()
    player:addInventorySlot(itemType)
end)

sea.addEvent("onHookDrop", function(player, item, itemType)
    if player.bot then
        return
    end

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
    if player.bot then
        return
    end

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

        player:updateMoney()
    end

    timerEx(1, "update", 1, player)
end)

sea.addEvent("onHookAttack", function(player)
    if player.bot then
        return
    end

    if player.bot then
        return
    end

    player:updateAmmo()

    local lastSelectedItem = player.lastSelectedItem

    if lastSelectedItem:isConsumable() then
        if not player:hasItem(lastSelectedItem.id) then
            player:removeInventorySlot(lastSelectedItem)
        end
    end
end)

sea.addEvent("onHookBombplant", function(player)
    if player.bot then
        return
    end

    player:removeInventorySlot(player.lastSelectedItem)

    player:updateMoney()
end)

sea.addEvent("onHookKill", function(player)
    if player.bot then
        return
    end

    player:updateMoney()
end)

sea.addEvent("onHookBuild", function(player, objectType)
    if player.bot then
        return
    end

    player:updateAmmo()

    local objectTypeID = objectType.id

    if objectTypeID == 20 or objectTypeID == 21 then
        local lastSelectedItem = player.lastSelectedItem

        if not player:hasItem(lastSelectedItem.id) then
            player:removeInventorySlot(lastSelectedItem)
        end
    end
end)

sea.addEvent("onHookSelect", function(player, itemType)
    if player.bot then
        return
    end

    player:updateAmmo()
    player:updateCurrentWeapon()
end)

sea.addEvent("onHookReload", function(player, mode)
    if player.bot then
        return
    end

    if mode == 1 then
        return
    end
    
    player:updateAmmo()
end)

sea.addEvent("onHookHit", function(player, source, itemType, damage, armorDamage)
    if player.bot then
        return
    end

    if type(source) == "table" then
        if not player:isEnemyTo(source) then
            return
        end
    end

    player:updateHealth(player.health - damage)
    player:updateArmor(player.armor - armorDamage)
end)

-- Functions

function bh.getHealthBarColor(ratio)
    if ratio <= 0.3 then 
        return sea.Color.red
    elseif ratio < 0.9 then
        return sea.Color.yellow
    else
        return sea.Color.green
    end
end

-- Extensions

function sea.Player:addInventorySlot(itemType)
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
    for _, menu in pairs(self.hud.inventory) do
        for _, slot in pairs(menu) do
            slot:destroy()
        end
    end

    self.hud.inventory = {}
end

function sea.Player:refreshInventory()
    self:destroyInventory()

    for _, itemType in pairs(self:getItems()) do
        self:addInventorySlot(itemType)
    end
end