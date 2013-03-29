module(..., package.seeall)
new = function ( params )
print("here")
	local level = params.level or 1 -- choose level
print(level)
	local localGroup
	local objects
	local catched
	local levels = {
		{--first level
			obj_per_sec = 0.5, -- how many objects need to be launched per second
			level_time = 30, -- level is 30 seconds
		},
		{--second, etc
			obj_per_sec = 0.7,
			level_time = 40,
		}
	}
	
	local function clean_up()
		objects = {}
		Runtime:removeEventListener("touch", touch_screen)
		Runtime:removeEventListener("enterFrame", main_loop)
	end
	
	local function finish_level()
		clean_up()
		director:changeScene({level=level, catched=catched, objects=levels[level].level_time*levels[level].obj_per_sec}, "menu")
	end
	
	local function start_level()
		timer.performWithDelay(levels[level].level_time*1000, finish_level)
	end

	local last_launch
	main_loop = function()
		local interval = 1000/levels[level].obj_per_sec
		if system.getTimer()-last_launch>=interval then
			--launch
			local obj = math.random(1,2)
			if obj==1 then
				obj = display.newRect(0,0, 30,30)
				physics.addBody( obj, { density = 1.0, friction = 0.3, bounce = 0.2 } )
				obj.type="rect"
			else
				obj = display.newCircle(0,0, 30)
				physics.addBody( obj, { density = 1.0, friction = 0.3, bounce = 0.2, radius=30 } )
				obj.type="circle"
			end
			obj.x, obj.y = math.random(obj.width/2, display.contentWidth-obj.width/2), -obj.height/2
			objects[#objects+1] = obj
			localGroup:insert(obj)
			last_launch = system.getTimer()
		end
	end
	
	touch_screen = function(event)
		if event.phase=="began" then
			for _,o in pairs(objects) do
				if not o.removing then
					if	(o.type=="rect" and is_in_rect(event, {o.x-o.width/2, o.y-o.height/2, o.x+o.width/2, o.y+o.height/2})) or
						(o.type=="circle" and is_in_circle(event, o.x,o.y, o.width/2))
						then
						catched = catched+1
						o.removing = true
						o:setLinearVelocity( 0, 0 )
						transition.to(o, {time=300, alpha=0, onComplete=function()
							o:removeSelf()
							objects[_] = nil
						end})
					end
				end
			end
		end
	end

	local initVars = function ()
		last_launch = 0
		localGroup = display.newGroup()
		objects = {}
		catched = 0
		local bg = display.newRect(0,0, display.contentWidth, display.contentHeight)
		bg:setFillColor(167, 212, 249)
		localGroup:insert(bg)
		Runtime:addEventListener("touch", touch_screen)
		Runtime:addEventListener("enterFrame", main_loop)
		start_level(1)
	end	
	
	
	initVars()
	return localGroup
end