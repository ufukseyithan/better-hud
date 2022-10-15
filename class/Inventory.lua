local Inventory = class()

local Slot = dofile("sys/lua/sea-framework/app/better-hud/class/InventorySlot.lua")

function Inventory:constructor(hud, startX, startY, color)
    self.hud = hud

    self.startX, self.startY = startX, startY
    self.color = color or sea.Color.white
    self.menus = {}
end

function Inventory:addSlot(menuIndex, index, imagePath)
    local ui = self.ui

    local menus = self.menus

    local menu = menus[menuIndex]

    if not menu then
        menus[menuIndex] = {}

        menu = menus[menuIndex]

        menu[-1] = ui:createText(menuIndex, self.startX + 22, 0, sea.Style.new({
            align = 1,
            verticalAlign = 1,
            textSize = 10,
            color = self.color
        }))
    end

    if menu[index] then
        return
    end

    menu[index] = Slot.new(self, imagePath, 0, 0, self.color)

    self:update()
end

function Inventory:getMenuOfSlot(index)
    for menuIndex, menu in pairs(self.menus) do
        for slotIndex, slot in pairs(menu) do
            if slotIndex == index then
                return menuIndex, menu
            end
        end
    end

    return false
end

function Inventory:removeSlot(index)
    local menuIndex, menu = self:getMenuOfSlot(index)

    if not menu then
        return
    end

    local slot = menu[index]

    if not slot then
        return
    end

    slot:destroy()
    menu[index] = nil

    if table.count(menu) <= 1 then
        menu[-1]:destroy()
        self.menus[menuIndex] = nil
    end

    self:update()
end

function Inventory:activateSlot(index)
    for _, slot in pairs(self:getAllSlots()) do
        slot:deactivate()
    end

    local menuIndex, menu = self:getMenuOfSlot(index)

    if not menu then
        return
    end

    local slot = menu[index]

    if not slot then
        return
    end

    slot:activate()
end

function Inventory:update()
    local x, y = self.startX, self.startY

    for slotsID, slots in pairs(self.menus) do
        slots[-1]:setPosition(self.startX + 22, y)

        for slotID, slot in pairs(slots) do
            if slotID > -1 then
                slot:setPosition(x, y)

                x = x - 34
            end
        end

        x = self.startX
        y = y - 34
    end
end

function Inventory:setColor(color)
    self.color = color

    for _, menu in pairs(self.menus) do
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

function Inventory:getAllSlots()
    local slots = {}

    for _, menu in pairs(self.menus) do
        for slotID, slot in pairs(menu) do
            if slotID > -1 then
                table.insert(slots, slot)
            end
        end
    end

    return slots
end

function Inventory:destroy()
    for _, menu in pairs(self.menus) do
        for _, slot in pairs(menu) do
            slot:destroy()
        end
    end

    self.menus = {}
end

-------------------------
--       GETTERS       --
-------------------------

function Inventory:getUiAttribute()
    return self.hud.ui
end

-------------------------
--        INIT         --
-------------------------

return Inventory