Player = {}

function Player.new()
    local player = Object.new( nil, 0, 0, 2, DOWN )
    
    player.money = 0
    player.inventory = {}
    
    player.footprint = { {0, 0} }
    
    player.render = Player.render
    
    return player
end

function Player:render()
    local x = self.x * world.tileSize + self.offx
    local y = (self.y - 1) * world.tileSize + self.offy
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.rectangle( "fill", x, y, 32, 64 )
end
