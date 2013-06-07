--- A kind of 'session' between a player and npc.
-- One of the functions for the Conversation structure is to collect intentions
-- and authorisations so that the NPC can reason about them.
Conversation = {
    -- Number of lines that can be displayed in the conversation window,
    -- excluding player's sentence.
    lines = 11,
    -- Number of characters that fit on one line.
    chars = 24,
    
    font = love.graphics.newFont( 32 ),
    
    -- The person with whom the player is conversing
    npc = nil,
    
    --- Sentences that were said before.
    -- List of Sentence structures.
    history = nil,
    --- What the player is saying now
    sentence = nil
}

--- Create a new conversation.
--
function Conversation.new( person )
    return {
        npc = person,
        history = {},
        sentence = "",
        
        playerTalk = Conversation.playerTalk,
        NPCTalk = Conversation.NPCTalk,
        addCharacter = Conversation.addCharacter,
        leave = Conversation.leave,
        
        render = Conversation.render,
        renderPlayerSentence = Conversation.renderPlayerSentence,
        displayChar = Conversation.displayChar
    }
end

--- Player says a sentence.
-- @param s String representing what the player says.
function Conversation:playerTalk()
    -- Parse it and convert it to a Query structure.
    local q = Query.parseSentence( self.sentence )
    
    -- Add it to history
    table.insert( self.history, { words = self.sentence, query = q, speaker = "Player" } )
    
    -- Reset player's text
    self.sentence = ""
    
    -- Let the NPC create a response
    self.npc:processQuery( q )
end

function Conversation:NPCTalk( s )
    table.insert( self.history, { words = s, speaker = "NPC" } )
end


function Conversation:addCharacter( c )
    if #c == 1 then
        local b = string.byte(c)
        local add = ""
        
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            if b >= string.byte("a") and b <= string.byte("z") then
                add = c:upper()
            elseif c == "1" then
                add = "!"
            elseif c == "/" then
                add = "?"
            end
        else
            if ( b >= string.byte("a") and b <= string.byte("z") )
            or ( b >= string.byte("0") and b <= string.byte("9") ) then
                add = c
            elseif c == " " then
                add = " "
            elseif c == "." then
                add = "."
            elseif c == "," then
                add = ","
            end
        end
        
        self.sentence = self.sentence .. add
    elseif c == "return" then
        self:playerTalk()
    elseif c == "backspace" then
        self.sentence = string.sub( self.sentence, 1, -2 )
    end
end

---
-- Handle stuff like confusion when a person was still talking.
function Conversation:leave()
    
end

--- Breaks up lines according to a font and number of pixels.
-- @param s string to wrap
-- @param
function Conversation.wordWrap( s, w )
    local t = s
    local f = Conversation.font
    local wraps = {}
    
    -- While the string should be wrapped
    while f:getWidth(t) > w do
        -- Try substrings in increasing size until there is one that is too large
        for l = 1, #t do
            local sub = string.sub( t, 1, l )
            if f:getWidth( sub ) > w then
                -- The previous length was the best fit
                table.insert( wraps, string.sub( t, 1, l - 1 ) )
                t = string.sub( t, l, -1 )
                break
            end
        end
    end
    -- Add last partial substring
    if #t > 0 then
        table.insert( wraps, t )
    end
    
    return wraps
end

function Conversation:render( x, y, w, h )
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.setFont( Conversation.font )
    -- Display previous lines
    local lines = {}
    
    -- See which lines from history will be displayed
    local i = #self.history
    while #lines < Conversation.lines and i > 0 do
        -- Check latest history
        local hline = Conversation.wordWrap( self.history[i].words, w )
        
        local n = Conversation.lines - #lines
        local tmp = {}
        
        while n >= 0 do
            table.insert( tmp, 1, hline[ #hline - n ] )
            n = n - 1
        end
        
        for _, line in ipairs( tmp ) do
            table.insert( lines, 1, line )
        end
        i = i - 1
    end
    
    local ch = h / (Conversation.lines + 1)
    
    -- Display the actual lines
    for n, line in ipairs( lines ) do
        love.graphics.print( line, x, y + (n-1) * ch )
    end
    
    -- Display the player's current line
    self:renderPlayerSentence( x, y + Conversation.lines * ch, w, h )
end

function Conversation:renderPlayerSentence( x, y, w, h )
    -- Add the cursor
    local cursor = "> " .. self.sentence .. "_"
    
    -- First calculate which characters are displayed on screen
    -- Calculate length of the strings until there is one that fits
    local display = nil
    
    if Conversation.font:getWidth( cursor ) <= w then
        display = cursor
    else
        -- Take substrings until there is one that fits
        for length = 1, #cursor do
            if Conversation.font:getWidth( string.sub( cursor, -length, -1 ) ) > w then
                -- The previous length was the best fit
                display = string.sub( cursor, -length + 1, -1 )
                break
            end
        end
    end
    
    --[[
    if #cursor > Conversation.chars then
        display = string.sub( cursor, #cursor - Conversation.chars, -1 )
    else
        display = cursor
    end
    
    for i = 1, #display do
        self:displayChar( x, y, w, h, i - 1, Conversation.lines, string.sub( display, i, i ) )
    end
    --]]
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.print( display, x, y )
end

function Conversation:displayChar( x, y, w, h, tx, ty, c )
    local cw = w / Conversation.chars
    local ch = h / ( Conversation.lines + 1 )
    
    local ax = x + tx * cw
    local ay = y + ty * ch
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.setFont( Conversation.font )
    love.graphics.print( c, ax, ay )
end


Intention = {
    --- Some possible intentions
    types = {
        greeting   = "greeting",  -- starting a conversation
        statement  = "statement", -- providing information
        request    = "request",   -- request for an action
        insult     = "insult",
        babble     = "babble"     -- what's that person saying?!?!
    },

    --- This represents what the player wants to do.
    -- A value that can be one of (non-exhaustive):
    --   buy something
    --   get through a locked door
    --   gain some information about someone or something
    --
    -- This is a single enum value from Intention.types.
    goal = nil,
    
    --- Information about the intention.
    -- For example, what the person's name is, when something should happen, or
    -- which door is locked.
    --
    -- This is a collection of facts.
    specifics = nil
}

function Intention.new( goal, specifics )
    return {
        goal = goal,
        specifics = specifics
    }
end

Rule = {
    --- List of patterns that fit this particular result.
    patterns = nil,
    
    --- An Intention.type
    result = nil
}

function Rule.new( patterns, intent )
    return {
        patterns = patterns,
        result = intent,
        
        fit = Rule.fit
    }
end

--- See if the provided sentence fits the rule and generate its result.
-- @param s sentence to check
-- @return an Intention structure with the result, or nil if it does not fit
function Rule:fit( s )
    for _, p in ipairs( self.patterns ) do
        --
        if p:lower() == s:lower() then
            return self.result
        end
    end
    
    return nil
end

--- An abstraction of a sentence, containing mostly pragmatics.
-- This is independent of receiver (NPC) as it conveys the player's intentions.
Query = {
    --- 
    cues = { "open", "give", "send", "" },
    
    --- The set of rules that define the grammar of sentence queries.
    -- These represent patterns in sentences which are then converted.
    rules = { Rule.new( {"Hello", "Good [morning|evening]"}, Intention.types.greeting ) },
    
    --- An Intention structure for this sentence.
    intention = nil,
    
    --- This signifies why the player is authorised for that intention.
    -- Facts that are independent from the intention, if any.
    -- This is a collection of facts.
    information = nil
}

--- Creates a query structure from a sentence.
function Query.parseSentence( s )
    local fit = nil
    -- Go through all rules and fit them
    for _, rule in ipairs( Query.rules ) do
        local try = rule:fit( s )
        if try then
            fit = try
            break
        end
    end
    
    return {
        intention = fit,
        information = nil
    }
end
