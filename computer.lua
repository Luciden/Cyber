
--- Abstraction of Operating Systems
-- These provide different behaviours for specific inputs.
OS = {
    --- Function that initialises OS dependent variables
    -- @param comp the computer on which to initialise
    init = function( comp ) end,
    
    --- Function for keyboard input
    -- @param comp the computer on which it runs
    -- @param c the character/key that was pressed
    keyboard = function( comp, c ) end,
    
    --- Function that handles mouse input
    -- @param comp the computer on which it runs
    -- @param b button that was pressed, left or right
    -- @param x x coordinate on the terminal screen
    -- @param y y coordinate on the terminal screen
    mouse = function( comp, b, x, y ) end,
    
    --- Function that handles display on the screen
    -- @param comp the computer on which the os runs
    -- @param x x coordinate on the real screen
    -- @param y y coordinate on the real screen
    -- @param w width of the terminal on the screen
    -- @param h height of the terminal on the screen
    render = function( comp, x, y, w, h ) end,
}

--- Represents a single computer.
Computer = {
    --- Tree of the filesystem on this computer.
    -- This is the root directory.
    files = nil,
    
    --- Operating System that this system runs
    cOS = nil,
    
    --- Current directory
    directory = nil
}

--- Abstraction of a directory
Directory = {
    --- This should be set to signify it as a directory.
    isDirectory = true,
    name = nil,
    permissions = nil,
    
    --- The parent directory or nil if it is the root
    parent = nil,
    --- List with all subdirectories
    directories = {},
    --- List with all the files
    files = {}
}

---
-- @parem name name of this directory
-- @param parent parent directory
function Directory.new( name, parent )
    local dir = {
        isDirectory = true,
        directories = {},
        files = {} 
    }
    
    if parent then
        dir.name = name:upper()
        dir.parent = parent
    end
    
    return dir
end

File = {
    --- Should be set to true to signify it as a file
    isFile = true,
    
    --- String with the name
    name = nil,
    
    --- String with the contents of this file
    contents = nil
}

function File.new( name )
    return {
        isFile = true,
        name = name:upper(),
        contents = ""
    }
end

function Computer.new( map, x, y, dir, system, fs )
    fs = fs or Directory.new()
    local pc = Object.new( map, x, y, 0, dir )
    
    pc.interaction = interaction.terminal
    pc.render = Computer.render
    
    pc.files = fs
    pc.cOS = system
    
    pc.directory = fs
    
    pc.inputCharacter = Computer.inputCharacter
    pc.pwd = Computer.pwd
    pc.mkdir = Computer.mkdir
    pc.cd = Computer.cd
    pc.ls = Computer.ls
    pc.touch = Computer.touch
    
    pc.isDir = Computer.isDir
    
    -- Initialise the OS
    pc.cOS.init( pc )
    
    return pc
end

function Computer:isActive()
    return false
end

function Computer:hasFile()
end

function Computer:inputCharacter( c )
    self.cOS.keyboard( self, c )
end

--- String representation of the current directory
function Computer:pwd()
    return Computer.path( self.directory )
end

function Computer.path( dir )
    if not dir.parent then
        return "/"
    else
        return Computer.path( dir.parent ) .. dir.name .. "/"
    end
end

function Computer:isDir( dirName )
    local name = dirName:upper()
    
    for _, d in ipairs( self.directory.directories ) do
        if d.name == name then
            return true
        end
    end
    
    return false
end

--- Create a new directory in the current directory
function Computer:mkdir( dirName )
    local name = dirName:upper()
    if not Computer.isDir( self, name ) then
        table.insert( self.directory.directories, Directory.new( name, self.directory ) )
        return true
    else
        return false
    end
end

function Computer:ls()
    local dirs = {}
    local files = {}
    for _, d in ipairs( self.directory.directories ) do
        table.insert( dirs, d.name )
    end
    
    for _, f in ipairs( self.directory.files ) do
        table.insert( files, f.name )
    end
    
    return dirs, files
end

function Computer:cd( dirName )
    if dirName == ".." then
        if self.directory.parent then
            self.directory = self.directory.parent
        end
        
        return true    
    end
    
    -- When it's not the special thing
    local name = dirName:upper()
    
    for _, d in ipairs( self.directory.directories ) do
        if d.name == name then
            self.directory = d
            return true
        end
    end
    
    return false
end

function Computer:createFile( fname )
    local name = fname:upper()
    
    for _, f in ipairs( self.directory.files ) do
        if f.name == name then
            -- already exists
            return false
        end
    end
    
    table.insert( self.directory.files, File.new( name ) )
    return true
end

function Computer:touch( fname )
    return Computer.createFile( self, fname:upper() )
end

function Computer:render()
    local x = self.x * world.tileSize
    local y = self.y * world.tileSize
    local w = world.tileSize
    local h = world.tileSize
    
    love.graphics.setColor( 0, 0, 196 )
    love.graphics.rectangle( "fill", x, y, w, h )
end
