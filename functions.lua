function play_sound(snd)
	if settings.game.options.sound then 
		audio.play(snd)
	end
end

function print_r (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        print_r (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end

function print_matrix(m, delim)
	delim = delim or ""
	for _,r in pairs(m) do
		local l = ""
		for _,v in pairs(r) do
			l = l..v..delim
		end
		print(l)
	end
end

function finger_rotate(event)
        local t = event.target
        local phase = event.phase
        
        if (phase == "began") then
                display.getCurrentStage():setFocus( t )
                t.isFocus = true
                
                -- Store initial position of finger
                t.x1 = event.x
                t.y1 = event.y
                
        elseif t.isFocus then
                if (phase == "moved") then
                        t.x2 = event.x
                        t.y2 = event.y
                        
                        angle1 = 180/math.pi * math.atan2(t.y1 - t.y , t.x1 - t.x)
                        angle2 = 180/math.pi * math.atan2(t.y2 - t.y , t.x2 - t.x)
--                        print("angle1 = "..angle1)
                        rotationAmt = angle1 - angle2
--print(rotationAmt)
						if rotationAmt>2.5 then
							rotationAmt = 2.5
						elseif rotationAmt<-2.5 then
							rotationAmt = -2.5
						end
 
                        --rotate it
                        t.rotation = t.rotation - rotationAmt
                        print ("t.rotation = "..t.rotation)
                        
                        t.x1 = t.x2
                        t.y1 = t.y2
                        
                elseif (phase == "ended") then
                        
                        display.getCurrentStage():setFocus( nil )
                        t.isFocus = false
                end
        end
        
        -- Stop further propagation of touch event
        return true
end

--[[
copy = function (t1)
	t2 = {}
	for k,v in pairs(t1) do t2[k] = v end
	return t2
end
]]

function img_size(img)
	local i = display.newImage(img, 10000, 10000)
	local sx,sy = i.width, i.height
	i:removeSelf()
	return {sx,sy}
end

function in_table ( e, t )
	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false
end

function addslashes(s)
  -- Double quote, single quote, and backslash (per the PHP
  -- manual):
  s = string.gsub(s, "(['\"\\])", "\\%1")
  -- The null character gets turned into a pair of printing
  -- characters by PHP addslashes.  Let's do the same:
  return (string.gsub(s, "%z", "\\0"))
end -- addslashes



function distance(o1,o2)
	return math.sqrt((o1.x-o2.x)^2+(o1.y-o2.y)^2)
end

function find_nearest(point, arr)
	local ne, nd = nil, 100000
	for _,e in pairs(arr) do
		if distance(point, e)<nd then
			nd = distance(point, e)
			ne = e
		end
	end
	return ne
end

function is_in_circle(p, x,y, radius)
	if distance(p, {x=x,y=y})<radius then return true end
	return false
end

function is_in_rect(point, rect)
	if point.x>=rect[1] and point.x<=rect[3] and point.y>=rect[2] and point.y<=rect[4] then return true end
	return false
end

function onscreen(point)
	return is_in_rect(point, {1,1, display.contentWidth, display.contentHeight})
end


function MyapplyForce(self, forceX, forceY, x,y, step_up, step_down, power_bound)
	if self.MyapplyForceData then
		if self.MyapplyForceData.direction == "down" then
			self.MyapplyForceData.forceX = self.MyapplyForceData.c_forceX+forceX
--			print(self.MyapplyForceData.forceX, self.MyapplyForceData.c_forceX, forceX)
			self.MyapplyForceData.direction = "up"
		else
			self.MyapplyForceData.forceX = self.MyapplyForceData.forceX+forceX
		end
		if self.MyapplyForceData.forceX > 0 then
			if self.MyapplyForceData.forceX>power_bound then self.MyapplyForceData.forceX = power_bound end
		else
			if self.MyapplyForceData.forceX<-power_bound then self.MyapplyForceData.forceX=-power_bound end
		end
		return
	end
	if forceX>0 then
		if forceX>power_bound then forceX = power_bound end
	else
		if forceX<-power_bound then forceX = -power_bound end
	end
	self.MyapplyForceData = {forceX=forceX, forceY=forceY, x=x,y=y, c_forceX=0, c_forceY=0, direction="up", step_up = step_up, step_down = step_down}

	local myclosure

	function MyapplyForceListener(self)
		local fd = self.MyapplyForceData
		if (fd.c_forceX>0 and fd.forceX>0) or (fd.c_forceX<0 and fd.forceX<0) then
			self:applyForce(fd.c_forceX, fd.c_forceY, fd.x, fd.y)
		end
		if fd.direction=="up" then
			if fd.forceX>0 then
				fd.c_forceX = fd.c_forceX + fd.step_up
				if fd.c_forceX>fd.forceX then fd.c_forceX=fd.forceX fd.direction="down" end
			else
				fd.c_forceX = fd.c_forceX - fd.step_up
				if fd.c_forceX<fd.forceX then fd.c_forceX=fd.forceX fd.direction="down" end
			end
		else
			if fd.forceX>0 then
				fd.c_forceX = fd.c_forceX - fd.step_down
				if fd.c_forceX<0 then
					Runtime:removeEventListener("enterFrame", myclosure)
					self.MyapplyForceData = nil
				end
			else
				fd.c_forceX = fd.c_forceX + fd.step_down
				if fd.c_forceX>0 then
					Runtime:removeEventListener("enterFrame", myclosure)
					self.MyapplyForceData = nil
				end
			end
		end
	end

	myclosure = function() return MyapplyForceListener( self ) end
	Runtime:addEventListener("enterFrame", myclosure)
	
--	print("MyappplyForce:", self, forceX, forceY, x,y)
end

table.count = function(t)  
  local c = 0  
  for _ in pairs(t) do  
    c = c + 1  
  end  
  return c  
end

table.reverse = function(t)
	local max = #t
	local rev = {}
	for i,v in ipairs(t) do  
		rev[max-i+1] = v
	end  
	return rev
end

table.delete = function(t,e)
	for _,e_ in pairs(t) do
		if e_==e then
			t[_] = nil
			return true
		end
	end
	return false
end

table.inject = function(to, from)
	for k,v in pairs(from) do
		to[k] = v
	end
end

table.shift = function(table)
	if not table[1] then return nil end
	local val = table[1]
	for k,v in pairs(table) do
		if k>1 then
			table[k-1] = table[k]
		end
	end
	table[#table] = nil
	return val
end

function intersection(p11,p12,p21,p22)
	    local Z  = (p12.y-p11.y)*(p21.x-p22.x)-(p21.y-p22.y)*(p12.x-p11.x);
	    local Ca = (p12.y-p11.y)*(p21.x-p11.x)-(p21.y-p11.y)*(p12.x-p11.x);
	    local Cb = (p21.y-p11.y)*(p21.x-p22.x)-(p21.y-p22.y)*(p21.x-p11.x);

	    if Z == 0 and Ca == 0 and Cb == 0 then return nil end


	    if Z == 0 then return nil end


	    local Ua = Ca/Z;
	    local Ub = Cb/Z;

		local pt = {}
	    pt.x = p11.x + (p12.x - p11.x) * Ub;
	    pt.y = p11.y + (p12.y - p11.y) * Ub;

	    if 0 <= Ua and Ua <= 1 and 0 <= Ub and Ub <= 1 then
--	        ( (Ua == 0)||(Ua == 1)||(Ub == 0)||(Ub == 1) ) ?
--	            result.type = ctOnBounds :
--	            result.type = ctInBounds;
	    else
	        return nil
		end

	    return pt
end


function copy(object)  
	local lookup_table = {}  

	local function _copy(object)  
		if type(object) ~= "table" then  
			return object  
		elseif lookup_table[object] then  
			return lookup_table[object]  
		end  
		local new_table = {}  
		lookup_table[object] = new_table  
		for index, value in pairs(object) do  
			new_table[_copy(index)] = _copy(value)  
		end 
		return setmetatable(new_table, _copy(getmetatable(object)))  
	end  

	return _copy(object)  
end

function url_decode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end