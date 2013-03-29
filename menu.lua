module(..., package.seeall)
new = function ( params )
	local catched = params.catched
	local level = params.level
	local objects = params.objects

	local function clean_up()
		Runtime:removeEventListener("touch", touch_screen)
	end
	
	local function next_level(event)
		if event.phase=="ended" then
			clean_up()
			director:changeScene({level=level+1}, "play")
		end
	end

	local initVars = function ()
		localGroup = display.newGroup()
		local bg = display.newRect(0,0, display.contentWidth, display.contentHeight)
		bg:setFillColor(167, 212, 249)
		localGroup:insert(bg)
		
		local stars = 0
		if catched>=0.5*objects then stars = 1 end
		if catched>=0.75*objects then stars = 2 end
		if catched>=0.9*objects then stars = 3 end
		
		local lbl = display.newText("Catched: "..catched..", Total: "..objects..", Your stars: "..stars, 0,0, native.systemFont, 16)
		lbl.x, lbl.y = display.contentWidth/2, display.contentHeight/2
		lbl:setTextColor(178, 185, 0)
		localGroup:insert(lbl)
		
		bg:addEventListener("touch", next_level)
	end	
	
	
	initVars()
	return localGroup
end