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

    player.hud = bh.Hud.new(player.ui, sea.Color.white)
end)

sea.addEvent("onHookSpawn", function(player)
    if player.bot then
        return
    end

    -- show hud

    local function update()
        player.hud:refreshInventory(player:getItems())

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
        player:onItemRemoved(itemType)
    end

    timerEx(1, update)
end)

sea.addEvent("onHookBuy", function(player, itemType)
    if player.bot then
        return
    end

    local money = player.money

    function update()
        if money == player.money then
            -- Buy wasn't processed
            return
        end

        player:onItemAdded(itemType)
      
        player:updateMoney()
    end

    timerEx(1, update)
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