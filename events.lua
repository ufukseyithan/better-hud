bh.Bar = dofile("sys/lua/sea-framework/app/better-hud/class/Bar.lua")

-- Events

sea.addEvent("onHookJoin", function(player)
    local ui = player.ui

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
end)

sea.addEvent("onHookSpawn", function(player)
    -- show hud

    player:updateHealth()
    player:updateArmor()
end)

sea.addEvent("onHookDie", function(player)
    -- hide hud
end)

sea.addEvent("onHookCollect", function(player)
    player:updateArmor()
end)

sea.addEvent("onHookBuy", function(player, itemType)
    player:updateArmor()
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

function sea.Player:updateHealth(health, maxHealth)
    health = health or self.health
    maxHealth = maxHealth or self.maxHealth

    ratio = health / maxHealth
    
    self.healthIcon.style.color = bh.getHealthBarColor(ratio)
    self.healthIcon:update()

    self.healthText:setText(health)
    self.healthText.style.color = bh.getHealthBarColor(ratio)
    self.healthText:update()

    self.healthBar:setRatio(ratio)
    self.healthBar:setColor(bh.getHealthBarColor(ratio))
end

function sea.Player:updateArmor(armor, maxArmor)
    armor = armor or self.armor
    maxArmor = maxArmor or 100

    if armor > 200 then
        armor = sea.ItemType.armorToItem(armor).name
    else
        local ratio = armor / maxArmor

        self.armorBar:setRatio(ratio)
    end

    self.armorText:setText(tostring(armor):upper())
end