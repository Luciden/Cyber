
--- A Tile is a set of properties for a location (square) in the world.
--
Tile = {
    -- the tileset to use
    tileset = nil,
    -- which tile from the tileset to uses
    tile = nil,
    
    wall = {
        solid = true
    },
    
    floor = {
        solid = false
    }
}

function Tile.new( set, t )
    return { tileset = set, tile = t }
end

--- Provides means to go inside/outside/change locations
Portal = {
    -- id from the map that this leads to
    destination = nil,
    
    -- Coordinates that this teleports to
    x = nil,
    y = nil
}

---
-- @param dest destination map
-- @param l coordinates in the map
function Portal.new( dest, l, dirs )
    return {
        destination = dest,
        
        x = l.x,
        y = l.y,
        
        directions = dirs
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
    objects = nil
}

--- See which tile is at the location relative to origin
function Map:tile( x, y )
    return tiles[x][y]
end
