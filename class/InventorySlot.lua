local InventorySlot = class()

function InventorySlot:constructor(ui, itemImagePath, x, y)
    self.slotImage = ui:createPanel("gfx/block.bmp", x, y, sea.Style.new({
        scale = {x = 1, y = 1},
        opacity = 0.25
    }))
    self.itemImage = ui:createPanel(itemImagePath, x, y)
end

function InventorySlot:activate()
    self.slotImage.style.opacity = 0.75
    self.slotImage:update()
end

function InventorySlot:deactivate()
    self.slotImage.style.opacity = 0.25
    self.slotImage:update()
end

function InventorySlot:setPosition(x, y)
    self.slotImage:setPosition(x, y)
    self.itemImage:setPosition(x, y)
end

function InventorySlot:destroy()
    self.slotImage:destroy()
    self.itemImage:destroy()
end

-------------------------
--        INIT         --
-------------------------

return InventorySlot