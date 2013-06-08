
Objective = {
    -- Function that returns a boolean when the objective is completed
    completed = nil,
    
    update = nil,
    
    -- Function that gives a string with the subgoal
    description = nil
}

--- An assignment which the player has to complete.
Assignment = {
    font = love.graphics.newFont( 16 ),
    
    completed = nil,
    
    --- Function that checks whether the current assignment is failed.
    -- Normally used with time limits.
    -- @return true when the assignment has already failed
    -- @return false otherwise
    failed = nil,
    
    --- Function that is executed when the assignment is turned in and completed.
    reward = nil,
    
    --- Function that updates the current state of the assignment.
    -- This function is called repeatedly to update variables associated with
    -- this assignment.
    -- Can be used to set toggled variables (been there, did this) for example.
    update = nil
}

function Assignment.new( objectives, reward, update, failed )
    update = update or Assignment.update
    failed = failed or Assignment.failed
    
    return {
        objectives = objectives,
        reward = reward,
        update = update,
        failed = failed,
        
        completed = Assignment.completed,
        render = Assignment.render
    }
end

--- Function that checks whether the current assignment is completed.
-- @return true when the assignment is completed
-- @return false otherwise
function Assignment:completed()
    if not self.failed then
        -- Check to see that every subtask was completed
        for _, task in ipairs( self.objectives ) do
            if not task:completed() then
                return false
            end
        end
        
        print( "completed" )
        return true
    end
    
    return false
end

function Assignment:update()
    for _, task in ipairs( self.objectives ) do
        task:update()
    end
end

function Assignment:failed()
    return false
end

--- Renders text that is associated with this assignment on the assignment list.
-- @param x
-- @param y coordinates on screen from where to draw
-- @param w
-- @param h width and height of the rectangle that is available for displaying
-- @return actual height used
function Assignment:render( x, y, w, h )
    local h = 0
    -- For all active subobjectives
     -- Get the sentence for it and display it
    for i, task in ipairs( self.objectives ) do
        if task:completed() then
            love.graphics.setColor( 128, 128, 128 )
        else
            love.graphics.setColor( 255, 255, 255 )
        end
        love.graphics.setFont( Assignment.font )
        love.graphics.print( task:description(), x, y + h )
        
        -- Calculate height
        h = h + Assignment.font:getHeight()
    end
    
    return h
end

