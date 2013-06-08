World = {}

function World.new()
    local world = {}
    
    world.tileSize = 32
    
    world.maps = {}
    world.objects = {}
    world.computer = {}
    world.assignments = {}
    
    world.showAssignments = true
    
    world.update = World.update
    world.render = World.render
    
    world.addAssignment = World.addAssignment
    
    world.isSolid = World.isSolid
    world.interact = World.interact
    world.activatePortal = World.activatePortal
    world.isSolidObject = World.isSolidObject
    
    world.lastUpdate = love.timer.getTime()
    
    return world
end

function World:update()
    -- Update time
    

    -- Only update the assignments once per larger interval
    local t = love.timer.getTime()    
    if t > self.lastUpdate + 1 then
        for _, assignment in pairs(self.assignments) do
            assignment:update()
        end
        self.lastUpdate = t
    end
end

function World:render()
    local map = player.map
    
    if not map then
        print( "No map selected to render!" )
        return
    end

    -- Render gridlines
    if self.debug then
        -- render outline
        love.graphics.setColor( 128, 128, 128 )
        love.graphics.rectangle( "line", self.tileSize, self.tileSize,
                                 map.width * self.tileSize, map.height * self.tileSize )
        -- render grid lines
        for i = 1, map.width do
            local x = self.tileSize + i * self.tileSize
            love.graphics.line( x, self.tileSize, x, self.tileSize + map.height * self.tileSize )
        end
        for i = 1, map.height do
            local y = self.tileSize + i * self.tileSize
            love.graphics.line( self.tileSize, y, self.tileSize + map.width * self.tileSize, y )
        end
    end
    
    -- Render the tiles
    for i = 1, map.width do
        for j = 1, map.height do
            local tile = map:tile( i, j )
            tile.render( i, j )
        end
    end
    
    -- Render current map's objects
    for _, object in pairs(self.objects) do
        if map == object.map then
            object:render()
        end
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
        self.terminal.cOS.render( self.terminal, x, y, w, h )
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
    
    if self.showAssignments then
        local w = 320
        local h = love.graphics.getHeight()
        
        local x = love.graphics.getWidth() - w
        local y = 0
        
        local offset = 0
        
        love.graphics.setColor( 32, 16, 0 )
        love.graphics.rectangle( "fill", x, y, w, h )
        for i, a in ipairs( self.assignments ) do
            a:render( x, y + offset, w, h )
        end
    end
end

function World:addAssignment( assignment )
    table.insert( self.assignments, assignment )
end

function World:isSolidObject( map, x, y )
    -- Check if there is a solid object there
    for _, object in pairs(self.objects) do
        if object.map == map and object.x == x and object.y == y then
            -- Calculate from footprint (TODO)
            
            -- Check if it is a door and is opened
            if object.isDoor and object:isOpen() then
                return false
            end
            
            -- 
            if object.solid then
                return true
            end
        end
    end
    
    return false
end

function World:interact( x, y )
    for _, object in pairs(self.objects) do
        if object.map == player.map and object.x == x and object.y == y then
            action = object.interaction
            if action == interaction.terminal then
                -- Display that particular terminal
                self.terminal = object
            elseif action == interaction.conversation then
                -- Start a new conversation
                self.conversation = Conversation.new( object )
            elseif action == interaction.open then
                -- Try to open the door
                -- if it is locked, open interface with keys/lockpick/lock
                if not object:isLocked() then
                    print( "open door" )
                    object:open()
                else
                    -- Start lock opening/picking session
                    self.lockpick = nil
                end
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
