---
Person = {
    name = nil,
    
    --- Collection of facts
    knowledge = nil
}

function Person.new( map, x, y, dir, name )
    local person = Object.new( map, x, y, nil, dir )
    
    person.name = name
    
    person.knowledge = {}
    
    person.interaction = interaction.conversation
    
    person.render = Person.render
    person.processQuery = Person.processQuery
    
    
    return person
end

--- In conversations, this is used to create a response.
-- Makes use of the person's personal knowledge, job and permissions.
function Person:processQuery( q )
    --
    local intent = q.intention
    print(intent)
    
    if intent == nil then
        -- This shouldn't happen
        world.conversation:NPCTalk( "All hail the Hypnotoad!" )
    elseif intent == Intention.types.greeting then
        print( "I am greeting now" )
        world.conversation:NPCTalk( "Hello, how can I help you?" )
    end
end

--- Checks whether the person thinks the fact is true/plausible.
function Person:checkFact( f )
    
end

function Person.render( object )
    local x = object.x * world.tileSize
    local y = (object.y - 1) * world.tileSize
    
    love.graphics.setColor( 64, 64, 64 )
    love.graphics.rectangle( "fill", x, y, 32, 64 )
end
