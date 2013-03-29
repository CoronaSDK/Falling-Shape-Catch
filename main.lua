display.setStatusBar(display.HiddenStatusBar)
io.output():setvbuf('no')

require "functions"
director = require("director")
mainGroup = display.newGroup()
mainGroup:insert(director.directorView)
require("physics")
physics.start()

director:changeScene({level=1}, "play")
