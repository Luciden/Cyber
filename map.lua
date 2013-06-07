
--- A Tile is a set of properties for a location (square) in the world.
--
Tile = {
    -- the tileset to use
    tileset = nil,
    -- which tile from the tileset to uses
    tile = nil,
    
    wall = {
        solid = true,
        
        render = function( x, y )
            love.graphics.setColor( 255, 255, 255 )
            love.graphics.rectangle( "fill", x * world.tileSize, y * world.tileSize,
                                             world.tileSize, world.tileSize )
            end
    },
    
    floor = {
        solid = false,
        
        render = function( x, y )
            love.graphics.setColor( 128, 64, 0 )
            love.graphics.rectangle( "fill", x * world.tileSize, y * world.tileSize,
                                             world.tileSize, world.tileSize )
            end
    }
}

function Tile.new( set, t )
    return { tileset = set, tile = t }
end

--- Provides means to go inside/outside/change locations
Portal = {
    -- id from the map that this leads to
    destination = nil,
    
    -- Coordinates in the current map on which the portal is located
    x = nil,
    y = nil,
    
    -- Coordinates in destination map to where this teleports
    dx = nil,
    dy = nil,
    
    -- The moving direction that activates this portal
    directions = nil
}

---
-- @param dest destination map
-- @param l coordinates in the map
function Portal.new( here, dest, there, dir )
    return {
        destination = dest,
        
        x = here.x,
        y = here.y,
        
        dx = there.x,
        dy = there.y,
        
        directions = dir
    }
end

--- A Map is a representation of a small part of the world.
Map = {    
    -- Dimensions of the bounding box for this map
    width = nil,
    height = nil,
    -- The set of tiles
    tiles = nil,
    
    -- All objects associated with this map with location relative to origin
    objects = nil,
    
    portals = nil
}

function Map.new( id, width, height, tiles, portals )
    return {
        id = id,
        width = width,
        height = height,
        
        tiles = tiles,
        
        portals = portals,    
    
        tile = Map.tile
    }
end

--- See which tile is at the location relative to origin
function Map:tile( x, y )
    return self.tiles[x][y]
end
