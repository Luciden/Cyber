function love.conf(t)
    t.screen.width = 1024
    t.screen.height = 768
    t.screen.fullscreen = false
    t.screen.vsync = true
    t.screen.fsaa = 0
    
    t.title = "Unnamed Cyber Game"
    t.author = "Dennis Merkus"
    t.url = nil
    
    t.version = "0.8.0"
    
    t.console = true
    
    t.identity = nil
    
    t.modules.audio = true
    t.modules.keyboard = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.mouse = true
    t.modules.sound = true
    
    t.modules.physics = false
    t.modules.joystick = false
end