
--- Simple Operating System
-- A basic CLI interface with simple commands
-- Displays 16 lines of 32 characters wide
SOS = {
    width = 32,
    height = 16,
    bg = { r = 0, g = 0, b = 0 },
    fg = { r = 255, g = 255, b = 255 },
    font = love.graphics.newFont( "Grand9K Pixel.ttf", 24 )
}

function SOS.init( comp )
    print( "Initialising SOS" )
    comp.prompt = ">"
    comp.command = ""
    comp.history = {}
end

--- Displays characters on the screen and handles the commands.
function SOS.keyboard( comp, c )
    if #c == 1 then
        local b = string.byte(c)
        if ( b >= string.byte(" ") and b <= string.byte("/") ) 
        or ( b >= string.byte(":") and b <= string.byte("@") )
        or ( b >= string.byte("[") and b <= string.byte("`") )
        or ( b >= string.byte("{") and b <= string.byte("~") ) then
            comp.command = comp.command .. c
        elseif b >= string.byte("0") and b <= string.byte("9") then
            comp.command = comp.command .. c
        elseif b >= string.byte("a") and b <= string.byte("z") then
            -- only display uppercase
            comp.command = comp.command .. string.upper(c)
        end
    elseif c == "return" then
        SOS.parseCommand( comp )
    elseif c == "backspace" then
        -- remove last character from command
        comp.command = string.sub( comp.command, 1, -2 )
    end
end

--- The mouse is not supported in SOS
-- Does nothing.
function SOS.mouse( comp, b, x, y )
end

function SOS.parseCommand( comp )
    -- Add the command to the display history
    table.insert( comp.history, { text = comp.command, source = "cmd" } )
    
    -- Break up command line into separate words
    local line = {}
    for w in string.gmatch( comp.command, "[%w%.]+" ) do
        table.insert( line, w )
    end
    
    cmd = line[1]
    
    if cmd == "LIST" or cmd == "LS" or cmd == "DIR" then
        -- List the directory contents
        local dirs, files = comp:ls()
        table.sort( dirs )
        table.sort( files )
        
        SOS.print( comp, comp:pwd() )
        for _, dir in ipairs( dirs ) do
            SOS.print( comp, "`- " .. dir )
        end
        for _, file in ipairs( files ) do
            SOS.print( comp, "` " .. file )
        end
    elseif cmd == "TREE" then
        -- Create a tree from the current directory
        SOS.print( comp, "NOT YET IMPLEMENTED" )
    elseif cmd == "PWD" then
        -- Display the current directory path
        SOS.print( comp, comp:pwd() )
    elseif cmd == "MKDIR" then
        if #line < 2 then
            SOS.print( comp, "INVALID USAGE" )
            SOS.print( comp, "MKDIR NAME" )
        else
            local name = line[2]
            if comp:mkdir( name ) then
                SOS.print( comp, "CREATED " .. name:upper() )
            else
                SOS.print( comp, name:upper() .. " ALREADY EXISTS" )
            end
        end
    elseif cmd == "CD" then
        if #line < 2 then
            SOS.print( comp, "INVALID USAGE" )
            SOS.print( comp, "CD NAME" )
        else
            -- Change to a subdirectory or the parent directory
            local name = line[2]
            if comp:cd( name ) then
                SOS.print( comp, comp:pwd() )
            else
                SOS.print( comp, "DIR DOES NOT EXIST" )
            end
        end
    elseif cmd == "TOUCH" then
        -- Touch the file (i.e. in SOS, create file)
        if #line < 2 then
            SOS.print( comp, "INVALID USAGE" )
            SOS.print( comp, "TOUCH NAME" )
        else
            local name = line[2]
            comp:touch( name )
            SOS.print( comp, "TOUCHED " .. name:upper() )
        end
    elseif cmd == "VIEW" then
        -- Output a file's contents to the screen
        SOS.print( comp, "NOT YET IMPLEMENTED" )
    elseif cmd == "OPEN" then
        -- Open a file to edit it in text mode
        SOS.print( comp, "NOT YET IMPLEMENTED" )
    elseif cmd == "HELLO" then
        -- Hello World
        SOS.print( comp, "HELLO, WORLD!" )
    elseif cmd == nil then
        SOS.print( comp, comp.prompt )
    else
        SOS.print( comp, "INVALID COMMAND" )
    end
    
    comp.command = ""
end

--- 'Display' a line on the screen
function SOS.print( comp, s )
    table.insert( comp.history, { text = s, source = "output" } )
end

--- Breaks up the string
-- @param s string to wrap
-- @return a table of the lines
function SOS.wordWrap( s, w )
    local t = s
    local wraps = {}
    while #t > w do
        table.insert( wraps, string.sub( t, 1, w ) )
        t = string.sub( t, w + 1 )
    end
    -- Add the last partial substring
    if #t > 0 then
        table.insert( wraps, t )
    end
    
    return wraps
end

---
-- displays 16 lines of 32 characters wide
function SOS.render( comp, x, y, w, h )
    -- Clear the screen
    love.graphics.setColor( SOS.bg.r, SOS.bg.g, SOS.bg.b )
    love.graphics.rectangle( "fill", x, y, w, h )

    -- Prepare color
    love.graphics.setColor( SOS.fg.r, SOS.fg.g, SOS.fg.b )
    
    -- Number of lines currently displayed
    -- Stack in which the first element is displayed topmost
    local lines = {}
    
    -- Display the prompt with the current command
    for _, line in pairs( SOS.wordWrap( comp.prompt .. " " .. comp.command .. "_", SOS.width ) ) do
        table.insert( lines, line )
    end
    
    -- Calculate the remaining line wraps from reverse history
    local i = #comp.history
    while #lines < SOS.height and i > 0 do
        -- Check latest history
        local h = comp.history[i]
        local hline = nil
        
        if h.source == "cmd" then
            hline = comp.prompt .. " " .. comp.history[i].text
        elseif h.source == "output" then
            hline = comp.history[i].text
        end
        
        hline = SOS.wordWrap( hline, SOS.width )
        
        -- Calculate how many lines can still be added
        local n = SOS.height - #lines
        local tmp = {}
        -- Set the lines into the right order (reversed)
        while n >= 0 do
            table.insert( tmp, 1, hline[ #hline - n ] )
            n = n - 1
        end
        -- Add the ordered lines to the main lines
        for _, line in ipairs( tmp ) do
            table.insert( lines, 1, line )
        end
        i = i - 1
    end
    
    -- Display all the lines
    for n, line in ipairs( lines ) do
        SOS.displayString( x, y, w, h, n - 1, line )
    end
end

--- Displays a string on the given line.
-- Assumes the wordwrap has already been done.
function SOS.displayString( x, y, w, h, l, s )
    for i = 1, #s do
        SOS.displayChar( x, y, w, h, i - 1, l, string.sub( s, i, i ) )
    end
end

---
-- @param x on screen
-- @param y on screen
-- @param tx x of cell on terminal
-- @param ty y of cell on terminal
-- @param c character to display
function SOS.displayChar( x, y, w, h, tx, ty, c )
    local cw = w / SOS.width
    local ch = h / SOS.height
    
    local ax = x + tx * cw
    local ay = y + ty * ch
    
    -- local sx = cw / SOS.font.getWidth( SOS.font, c)
    -- local sy = ch / SOS.font.getHeight( SOS.font, c)
    
    love.graphics.setColor( SOS.fg.r, SOS.fg.g, SOS.fg.b )
    love.graphics.setFont( SOS.font )
    love.graphics.print( c, ax, ay, 0 )
end