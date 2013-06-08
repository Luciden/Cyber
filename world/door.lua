--- A western style swinging door with key.
Door = {
    -- specifies whether it is in the closed or opened state
    open = nil,
    
    -- specifies whether the key is turned or not
    locked = nil
}

function Door.new( map, x, y, dir )
    local door = Object.new( map, x, y, 0, dir )
    
    door.opened = false
    door.locked = false
    
    door.interaction = interaction.open
    
    door.render = Door.render
    
    door.isOpen = Door.isOpen
    door.isLocked = Door.isLocked
    
    door.open = Door.open
    door.close = Door.close
    door.lock = Door.lock
    door.unlock = Door.unlock
    
    return door
end

function Door:isOpen()
    return self.opened
end

function Door:isLocked()
    return self.locked
end

function Door:open()
    if not self.opened and not self.locked then
        self.opened = true
    end
end

function Door:close()
    if not self.locked then
        self.opened = false
    end
end

function Door:lock()
    -- if key in door
    self.locked = true
end

function Door:unlock()
    -- if key in door
    self.locked = false
end

function Door:render( x, y )
    local x = self.x * world.tileSize
    local y = self.y * world.tileSize
    local w = world.tileSize
    local h = world.tileSize
    
    if self.opened then
        love.graphics.setColor( 255, 255, 255 )
    else
        love.graphics.setColor( 0, 0, 0 )
    end
    
    love.graphics.rectangle( "fill", x, y, w, h )
end
