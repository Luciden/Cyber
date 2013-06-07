require("utils")

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
        
        -- the active map
        map = nil,
        
        objects = {},
        
        computer = {},
        
        assignments = {},
        
        terminal = nil,
        
        update = World.update,
        render = World.render,
        isSolid = World.isSolid,
        interact = World.interact
    }
    
    player = {
        gridX = nil,
        gridY = nil,
        offX  = 0,
        offY  = 0,
        moving = false,
        direction = DOWN,
        speed = 2,
        
        money = 0,
        inventory = {},
        
        footprint = { { 0, 0 } },
        
        render = Player.render,
        move   = Player.move,
        update = Player.update,
        
        receiveMoney = function( self, amount )
            money = money + amount
        end,
        
        receiveItem = function( self, item )
            table.insert( self.inventory, item )
        end
    }
    
    -- Add the test office map
    table.insert( world.maps, {
        id = 1,
        
        width = 10,
        height = 10,
        
        tiles = 
          { { Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.wall },
            { Tile.wall, Tile.wall, Tile.wall, Portal.new( 2, { x = 2, y = 1 }, { DOWN } ), Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall, Tile.wall } }
    })
    
    -- Add a small outside map
    table.insert( world.maps, {
        id = 2,
        
        width = 3,
        height = 3,
        
        tiles =
          { { Tile.wall, Portal.new( 1, { x = 4, y = 10 }, { UP } ), Tile.wall },
            { Tile.floor, Tile.floor, Tile.floor },
            { Tile.floor, Tile.floor, Tile.floor } }
    })
    
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
    table.insert( world.objects, {
        gridX = 2,
        gridY = 1,
        direction = LEFT,
        interaction = interaction.terminal,
        
        solid = true,
        
        render = function( self )
            local x = self.gridX * world.tileSize
            local y = self.gridY * world.tileSize
            local w = world.tileSize
            local h = world.tileSize
            
            love.graphics.setColor( 0, 0, 196 )
            love.graphics.rectangle( "fill", x, y, w, h )
        end,
        
        computer = Computer.new( SOS )
    })
    
    -- Add a Person with whom to converse with.
    table.insert( world.objects, {
        gridX = 1,
        gridY = 3,
        direction = UP,
        interaction = interaction.conversation,
        
        solid = true,
        
        render = Person.render,
        
        person = Person.new( "Alice" )
    })
    
    for _, m in ipairs( world.maps ) do
        print( m.id )
    end
    
    world.map = world.maps[1]
    player.gridX = 3
    player.gridY = 2
    
    --[[
    table.insert( world.objects, {
        gridX = 1,
        gridY = 2,
        direction = UP,
        interaction = interaction.terminal,
        
        solid = true,
        
        render = function( self )
            local x = self.gridX * world.gridSize
            local y = self.gridY * world.gridSize
            local w = world.gridSize
            local h = world.gridSize
            
            love.graphics.setColor( 196, 0, 0 )
            love.graphics.rectangle( "fill", x, y, w, h )
        end,
        
        computer = Computer.new( SOS )
    })--]]
end

function love.update(dt)
    world:update(dt)
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
            world.terminal.computer:inputCharacter( key )
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
            ix, iy = World.facingPos( player.gridX, player.gridY, player.direction )

            world:interact( ix, iy )
        elseif key == "escape" then
            love.event.push("quit")
        end
    end
end