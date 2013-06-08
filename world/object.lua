--- An Object is anything that 'exists' in the world.
-- Objects are things that are not part of the environment.
-- They all have a location and some can move, sense, act and 'think'.
--
-- Handles code that is handled for every object such as animation.
Object = {
    -- Map in which the object currently resides
    map = nil,
    
    -- Coordinates in the specified map
    x = nil,
    y = nil,
    
    -- Coordinate offsets for animation purposes
    offx = nil,
    offy = nil,
    
    solid = nil,
    
    -- Facing direction
    direction = nil,
    
    -- Number of tiles per second
    speed = nil,
    -- Is the object currently moving?
    moving = nil,
}

--- This specifies which locations the object occupies.
-- Mostly used for collision detection.
Footprint = {
}

--- Create a new object with the only requirement being location
function Object.new( map, x, y, speed, direction )
    speed = speed or 1
    direction = direction or NONE
    
    return {
        map = map,
        x = x,
        y = y,
        
        offx = 0,
        offy = 0,
        
        solid = true,
        
        speed = speed,
        direction = direction,
        moving = false,
        
        setLocation = Object.setLocation,
        update = Object.update,
        move = Object.move,
        
        -- All objects should specify their own render functions
        render = nil,
        
        canMove = Object.canMove,
        usePortal = Object.usePortal
    }
end

function Object:setLocation( x, y, map )
    map = map or self.map
    
    self.x = x
    self.y = y
    self.map = map
end

-- 
function Object:update( dt )
    if self.moving then
        -- When the object has moved one tile
        if math.abs(self.offx) > world.tileSize or math.abs(self.offy) > world.tileSize then
            -- Reset position to the grid position
            self.x = self.x + math.sign(self.offx)
            self.y = self.y + math.sign(self.offy)
            
            self.offx = 0
            self.offy = 0
            
            self.moving = false
        -- When the object is in the process of moving
        else
            if self.direction == DOWN then
                self.offy = self.offy + self.speed * world.tileSize * dt
            elseif self.direction == UP then
                self.offy = self.offy - self.speed * world.tileSize * dt
            elseif self.direction == LEFT then
                self.offx = self.offx - self.speed * world.tileSize * dt
            elseif self.direction == RIGHT then
                self.offx = self.offx + self.speed * world.tileSize * dt
            end
        end
    end
end

-- 
function Object:move( dir )
    -- Can't move when already moving
    if not self.moving then
        self.direction = dir
        
        -- Check portal, if it activates then it is taken care of, otherwise walk
        if self:usePortal( dir ) then
            -- Do nothing
        else
            -- Check Collisions
            if   ( dir == LEFT  and self:canMove( self.x - 1, self.y ) )
              or ( dir == RIGHT and self:canMove( self.x + 1, self.y ) )
              or ( dir == UP    and self:canMove( self.x, self.y - 1 ) )
              or ( dir == DOWN  and self:canMove( self.x, self.y + 1 ) ) then
                self.moving = true
            else
                self.moving = false
            end
        end
    end
end

--- Convenient function which combines checks.
function Object:canMove( x, y )
    return not self.map:isSolid( x, y ) and not world:isSolidObject( self.map, x, y )
end

--- Try to use a portal.
-- If there is a portal at the current location and it is activated by the
-- action, then the location is set.
-- Otherwise, nothing happens.
-- @return true if a portal was activated, false otherwise
function Object:usePortal( dir )
    for _, p in ipairs( self.map.portals ) do
        if p.x == self.x and p.y == self.y and p.direction == dir then
            -- Move the player to the specified location
            self.map = p.destination
            self.x = p.dx
            self.y = p.dy
            
            return true
        end
    end
    
    return false
end
