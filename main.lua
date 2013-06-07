require("utils")

require("object")
require("map")
require("world")
require("player")
require("person")
require("conversation")
require("computer")
require("assignment")
require("sos")

DOWN  = "down"
UP    = "up"
LEFT  = "left"
RIGHT = "right"
NONE  = "none"

interaction = {
    terminal = 0,
    open     = 1,
    talk     = 2
}

function love.load()
    world = {
        tileSize = 32,
        
        lastUpdate = love.timer.getTime(),
        
        maps = {},
        
        objects = {},
        
        computer = {},
        
        assignments = {},
        
        terminal = nil,
        
        update = World.update,
        render = World.render,
        isSolid = World.isSolid,
        interact = World.interact,
        activatePortal = World.activatePortal,
        isSolidObject = World.isSolidObject
    }
    
    player = Player.new()
    
    mapOffice = Map.new( 1, 10, 10, {
            { Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall }
        }, {  } )
    
    mapStreet = Map.new( 2, 3, 3, {
            { Tile.wall, Tile.floor, Tile.floor },
            { Tile.floor, Tile.floor, Tile.floor },
            { Tile.wall, Tile.floor, Tile.floor }
        }, { Portal.new( { x = 2, y = 1 }, mapOffice, { x = 4, y = 10 }, UP ) } )
        
    mapOffice:addPortal( Portal.new( { x = 4, y = 10 }, mapStreet, { x = 2, y = 1 }, DOWN ) )
    
    for _, portal in ipairs( mapOffice.portals ) do
        print( portal.x, portal.y, portal.direction )
    end
    
    -- Add the test office map
    table.insert( world.maps, mapOffice )
    
    -- Add a small outside map
    table.insert( world.maps, mapStreet )
    
    table.insert( world.assignments, {
        wasThere = false,
        
        completed = function( self )
            return self.wasThere
        end,
        
        failed = function( self )
            return false
        end,
        
        reward = function( self )
            player:receiveMoney( 10 )
        end,
        
        update = function( self )
            if player.gridX == 5 and player.gridY == 5 then
                self.wasThere = true
            end
        end
    })
    
    -- Add an empty computer
    table.insert( world.objects, Computer.new( mapOffice, 4, 2, LEFT, SOS ) )
    
    -- Add a Person with whom to converse with.
    table.insert( world.objects, Person.new( mapOffice, 2, 3, UP, "Alice" ) )
    
    for _, m in ipairs( world.maps ) do
        print( m.id )
    end
    
    player:setLocation( 3, 2, mapOffice )
end

function love.update(dt)
    world:update(dt)
    
    -- Handle player input
    if not (world.terminal or world.conversation) then
        -- First check if we're moving
        if love.keyboard.isDown("down") then
            player:move( DOWN )
        elseif love.keyboard.isDown("up") then
            player:move( UP )
        elseif love.keyboard.isDown("left") then
            player:move( LEFT )
        elseif love.keyboard.isDown("right") then
            player:move( RIGHT )
        end
    end
    
    player:update(dt)
end

function love.draw()
    world:render()
    player:render()
end

function love.keypressed( key )
    -- Currently engaged with terminal
    if world.terminal then
        if key == "escape" then
            world.terminal = nil
        else
            world.terminal:inputCharacter( key )
        end
    elseif world.conversation then
        if key == "escape" then
            -- Leave the conversation
            world.conversation:leave()
            world.conversation = nil
        else
            world.conversation:addCharacter( key )
        end
    else
        if key == " " then
            -- check interaction
            ix, iy = World.facingPos( player.x, player.y, player.direction )

            world:interact( ix, iy )
        elseif key == "escape" then
            love.event.push("quit")
        end
    end
end