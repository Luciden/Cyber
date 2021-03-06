require("utils")

require("world.constants")
require("world.object")
require("world.map")
require("world.world")
require("world.player")
require("world.person")
require("world.door")

require("conversation.conversation")

require("computer.sos")
require("computer.computer")

require("assignment.assignment")

DOWN  = "down"
UP    = "up"
LEFT  = "left"
RIGHT = "right"
NONE  = "none"

function love.load()
    world = World.new()
    
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
    
    world:addAssignment( Assignment.new( 
        { { wasThere = false, completed = function( self ) return self.wasThere end,
            update = function( self ) if player.map == mapOffice and player.x == 5 and player.y == 5 then self.wasThere = true end end,
            description = function( self ) return "Go to position (5, 5) in the office" end } },
          function( self ) player:receiveMoney( 10 ) end,
          nil, nil )
    )
    
    -- Add an empty computer
    table.insert( world.objects, Computer.new( mapOffice, 4, 2, LEFT, SOS ) )
    
    -- Add a Person with whom to converse with.
    table.insert( world.objects, Person.new( mapOffice, 2, 3, UP, "Alice" ) )
    
    -- Add a door  to the office
    table.insert( world.objects, Door.new( mapOffice, 4, 10, UP ) )
    
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