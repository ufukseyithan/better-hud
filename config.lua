bh.config = {
    inventory = true,
    healthAffectsInventoryColor = true --
}

return {
    color = {
        ["armor"] = sea.Color.new(90, 90, 220)
    },

    player = {
        variable = {
            hud = {{}}
        }
    },

    server = {
        setting = {
            hud = 96,
            hudScale = 1
        }
    }
}