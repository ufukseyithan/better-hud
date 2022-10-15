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

    player:onItemAdded(itemType)
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

        player:onItemAdded(itemType)
      
        player:updateMoney()
    end

    timerEx(1, "update", 1, player)
end)

sea.addEvent("onHookAttack", function(player)
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