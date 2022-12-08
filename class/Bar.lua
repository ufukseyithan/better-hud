local Bar = class()

function Bar:constructor(ui, x, y, color, scale)
    local imagePath = sea.app.bh.path.gfx.."bar.png"

    self.scale = scale and {x = scale.x, y = scale.y} or {x = 1, y = 1} 

    local styleProperties = {
        color = color,
        scale =  scale and {x = scale.x, y = scale.y} or {x = 1, y = 1} 
    }

    local style = sea.Style.new(styleProperties)

    local stylePropertiesWithOpacity = deepcopy(styleProperties)
    stylePropertiesWithOpacity.opacity = Bar.opacity
    local styleWithOpacity = sea.Style.new(stylePropertiesWithOpacity)

    self.background = ui:createPanel(imagePath, x, y, styleWithOpacity)
    self.fill = ui:createPanel(imagePath, x, y, style)
end

function Bar:setRatio(ratio)
    self.fill.style.scale.x = self.scale.x * ratio

    self.fill:update()
end

function Bar:setColor(color)
    self.background.style.color = color
    self.fill.style.color = color

    self.background:update()
    self.fill:update()
end

function Bar:show()
    self.background:show()
    self.fill:show()
end

function Bar:hide()
    self.background:hide()
    self.fill:hide()
end

-------------------------
--       CONSTS        --
-------------------------

Bar.opacity = 0.5

-------------------------
--        INIT         --
-------------------------

return Bar