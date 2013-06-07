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
