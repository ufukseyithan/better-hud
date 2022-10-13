local InventorySlot = class()

function InventorySlot:constructor(ui, itemImagePath, x, y)
    self.slotImage = ui:createPanel("gfx/block.bmp", x, y, sea.Style.new({
        scale = {x = 1, y = 1},
        opacity = 0.5
    }))
    self.itemImage = ui:createPanel(itemImagePath, x, y)
end

-------------------------
--        INIT         --
-------------------------

return InventorySlot