
--- An assignment which the player has to complete.
Assignment = {
    --- Function that checks whether the current assignment is completed.
    -- @return true when the assignment is completed
    -- @return false otherwise
    completed = nil,
    
    --- Function that checks whether the current assignment is failed.
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
