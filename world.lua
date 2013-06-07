World = {}

function World:update()
    local t = love.timer.getTime()
    
    if t > self.lastUpdate + 1 then
        for _, assignment in pairs(self.assignments) do
            assignment:update()
        end
        self.lastUpdate = t
    end
end

function World:render()
    if not self.map then
        print( "No map selected to render!" )
        return
    end

    -- Render gridlines
    if self.debug then
        -- render outline
        love.graphics.setColor( 128, 128, 128 )
        love.graphics.rectangle( "line", self.tileSize, self.tileSize,
                                 self.map.width * self.tileSize, self.map.height * self.tileSize )
        -- render grid lines
        for i = 1, self.map.width do
            local x = self.tileSize + i * self.tileSize
            love.graphics.line( x, self.tileSize, x, self.tileSize + self.map.height * self.tileSize )
        end
        for i = 1, self.map.height do
            local y = self.tileSize + i * self.tileSize
            love.graphics.line( self.tileSize, y, self.tileSize + self.map.width * self.tileSize, y )
        end
    end
    
    -- Render the tiles
    for i = 1, self.map.width do
        for j = 1, self.map.height do
            local tile = self.map:tile( i, j )
            tile.render( i, j )
        end
    end
    
    for _, object in pairs(self.objects) do
        object:render()
    end
    
    if self.terminal then
        local w = 640
        local h = 480
        
        local b = 4
        
        local x = love.graphics.getWidth() - w - b
        local y = love.graphics.getHeight() - h - b
        
        -- Create the Terminal border
        love.graphics.setColor( 64, 64, 64 )
        love.graphics.rectangle( "fill", x - b, y - b, w + 2 * b, h + 2 * b )
        
        -- Draw the terminal itself
        self.terminal.computer.cOS.render( self.terminal.computer, x, y, w, h )
    end
    
    if self.conversation then
        local w = 768
        local h = 384
        
        local b = 2
        
        local x = (love.graphics.getWidth() - w ) / 2
        local y = love.graphics.getHeight() - h - 32
        
        love.graphics.setColor( 64, 64, 128 )
        love.graphics.rectangle( "fill", x - b, y - b, w + 2 * b, h + 2 * b )
        self.conversation:render( x, y, w, h )
    end
end

function World:isSolid( x, y )
    -- Check if it is within bounds (everything out of bounds is considered as solid)
    if x < 1 or y < 1 or x > self.map.width or y > self.map.height then
        return true
    end
    
    -- First check if it is a wall or similar in the map
    local tile = self.map:tile( x, y )
    if tile.solid then
        return true
    end
    
    -- Check if there is a solid object there
    for _, object in pairs(self.objects) do
        if object.gridX == x and object.gridY == y then
            return true
        end
    end
    
    return false
end

function World:interact( x, y )
    for _, object in pairs(self.objects) do
        if object.gridX == x and object.gridY == y then
            action = object.interaction
            if action == interaction.terminal then
                -- Display that particular terminal
                self.terminal = object
            elseif action == interaction.conversation then
                -- Start a new conversation
                self.conversation = Conversation.new( object )
            end
            return true
        end
    end
end

---
-- @param l location
-- @param d direction
function World:activatePortal( d )
    print( player.gridX, player.gridY )
    for _, p in ipairs( self.map.portals ) do
        if p.x == player.gridX and p.y == player.gridY and p.direction == d then
            print( "teleporting" )
            -- Move the player to the specified location
            world.map = p.destination
            player.gridX = p.dx
            player.gridY = p.dy
            
            return true
        end
    end
    
    return false
end

function World.facingPos( x, y, d )
    if d == LEFT then
        return (x - 1), y
    elseif d == RIGHT then
        return (x + 1), y
    elseif d == UP then
        return x, (y - 1)
    elseif d == DOWN then
        return x, (y + 1)
    end
end
