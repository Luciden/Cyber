Player = {}

function math.sign(x)
    if     x < 0  then return -1
    elseif x == 0 then return 0
    else               return 1
    end
end

function Player:render()
    local x = self.gridX * world.tileSize + self.offX
    local y = (self.gridY - 1) * world.tileSize + self.offY
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.rectangle( "fill", x, y, 32, 64 )
end

function Player:move( dir )
    if not self.moving then
        self.direction = dir
        
        -- Check Collisions
        if   (dir == LEFT and self.gridX > 1 and not world:isSolid( self.gridX - 1, self.gridY))
          or (dir == RIGHT and self.gridX < 8 and not world:isSolid( self.gridX + 1, self.gridY))
          or (dir == UP and self.gridY > 1 and not world:isSolid( self.gridX, self.gridY - 1))
          or (dir == DOWN and self.gridY < 8 and not world:isSolid( self.gridX, self.gridY + 1)) then
            self.moving = true
        else
            self.moving = false
        end
    end
end

function Player:update( dt )
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

    if self.moving then
        if math.abs(self.offX) > world.tileSize or math.abs(self.offY) > world.tileSize then
            -- Reset position to the grid position
            self.gridX = self.gridX + math.sign(self.offX)
            self.gridY = self.gridY + math.sign(self.offY)
            
            self.offX = 0
            self.offY = 0
            
            self.moving = false
        else
            if self.direction == DOWN then
                self.offY = self.offY + self.speed * world.tileSize * dt
            elseif self.direction == UP then
                self.offY = self.offY - self.speed * world.tileSize * dt
            elseif self.direction == LEFT then
                self.offX = self.offX - self.speed * world.tileSize * dt
            elseif self.direction == RIGHT then
                self.offX = self.offX + self.speed * world.tileSize * dt
            end
        end
    end
end
