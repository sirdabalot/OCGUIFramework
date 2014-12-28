local components = require("component")
local term = require("term")
local colours = require("colors")
local event = require("event")
local gpu = components.gpu

-- points --

pointMeta = { }

pointMeta.__index = pointMeta

function point( X, Y )
	local p = {
		x = X,
		y = Y
	}
	
	return setmetatable( p, pointMeta )
end

function pointMeta.__tostring()
	term.write("X: " .. self.x .. "\n")
	term.write("Y: " .. self.y .. "\n")
end

function pointMeta.__add( p1, p2 )
	return point( p1.x + p2.x, p1.y + p2.y )
end


-- Gets a point between p1 and p2
function midPoint( p1, p2 )
	rx = math.ceil((p2.x - p1.x)/2)
	ry = math.ceil((p2.y - p1.y)/2)
	return point( rx+p1.x, ry+p1.y )
end

-- Checks point tp and returns true if tp is within the bounds of tlp ( top left point ) and brp ( bottom right point )
function pointInArea( tp, tlp, brp )
	-- Checking x
	if ( ( tp.x >= tlp.x - 1 ) and ( tp.x < brp.x - 1 ) ) then
		-- Checking y
		if ( ( tp.y >= tlp.y ) and ( tp.y < brp.y ) ) then
			return true
		end
	end
	return false
end

-- windows --

windowMeta = { }

windowMeta.__index = windowMeta

function window( P, W, H, T, FGCOL, BGCOL )
	local w = {
		guitype = "window",
		p = P,
		w = W-1,
		h = H,
		t = T,
		fgcol = FGCOL,
		bgcol = BGCOL,
		contents = { }
	}
	
	return setmetatable( w, windowMeta )
end

function windowMeta:draw( )
	-- Do shadow
	gpu.setBackground( 0x000000 )
	gpu.fill( self.p.x+1, self.p.y+1, self.w, self.h, " " )
	-- Do background
	gpu.setBackground( self.bgcol )
	gpu.fill( self.p.x, self.p.y, self.w, self.h, " " )
	-- Do label
	gpu.setForeground( self.fgcol )
	gpu.set( self.p.x, self.p.y, string.rep( "=", self.w ) )
	gpu.set( self.p.x, self.p.y, "#" )
	gpu.set( self.p.x + math.floor( self.w / 2 ) - math.ceil( #self.t / 2 ), self.p.y, self.t )
	-- Do children
	for k, v in pairs( self.contents ) do
		v:draw( )
	end
end

-- buttons --

buttonMeta = { }

buttonMeta.__index = buttonMeta

function button( Win, P, W, H, L, FGCOL, BGCOL, CM )
	local b = {
		guitype = "button",
		win = Win,
		p = P,
		w = W,
		h = H,
		l = L,
		fgcol = FGCOL,
		bgcol = BGCOL,
		cm = CM
	}
	
	br = setmetatable( b, buttonMeta )
	table.insert( b.win.contents, br )
	return br
end

function buttonMeta:draw( )
	-- Do background
	gpu.setBackground( self.bgcol )
	gpu.fill( self.win.p.x + self.p.x-1, self.win.p.y + self.p.y, self.w, self.h, " " )
	-- Do label
	gpu.setForeground( self.fgcol )
	gpu.set( self.win.p.x + self.p.x + math.floor( self.w / 2 ) - math.floor( #self.l / 2 ) - 1, self.win.p.y + self.p.y + math.floor( self.h / 2 ), self.l )
end

-- textbox --

textBoxMeta = { }

textBoxMeta.__index = textBoxMeta

function textBox( Win, P, W, H, T, FGCOL, BGCOL )
	local tb = {
		win = Win,
		p = P,
		w = W,
		h = H,
		t = T,
		fgcol = FGCOL,
		bgcol = BGCOL
	}
	
	tbr = setmetatable( tb, textBoxMeta )
	table.insert( tb.win.contents, tbr )
	return tbr
end

function textBoxMeta:draw( )
	-- Do background
	gpu.setBackground( self.bgcol )
	gpu.fill( self.win.p.x + self.p.x-1, self.win.p.y + self.p.y, self.w, self.h, " " )
	-- Do text
	gpu.setForeground( self.fgcol )
	linesNeeded = math.floor(#self.t/self.w)
	for i = 1, linesNeeded+1 do
		tbSubStr = string.sub( self.t, ( i ) * self.w - self.w+1, ( i ) * self.w )
		gpu.set( self.win.p.x + self.p.x-1, self.win.p.y + self.p.y-1 + i, tbSubStr )
	end
end

-- TextInput --

textInputMeta = { }

textInputMeta.__index = textInputMeta

function textInput( Win, P, W, FGCOL, BGCOL )
	local ti = {
		guitype = "textinput",
		win = Win,
		p = P,
		w = W,
		t = "",
		fgcol = FGCOL,
		bgcol = BGCOL
	}
	
	tir = setmetatable( ti, textInputMeta )
	table.insert( ti.win.contents, tir )
	return tir
end

function textInputMeta:draw( )
	gpu.setForeground( self.fgcol )
	gpu.setBackground( self.bgcol )
	gpu.set( self.win.p.x + self.p.x, self.win.p.y + self.p.y, string.rep( " ", self.w ) )
	gpu.set( self.win.p.x + self.p.x, self.win.p.y + self.p.y, self.t )
end

-- Loop

windowTable = { }

function debugPoint( ... )
	targs = { ... }
	gpu.setBackground( 0x000000 )
	gpu.setForeground( 0xFFFFFF )
	term.write("Debugging...\n")
	for k, v in ipairs( targs ) do
		term.write(tostring(v).."\n")
	end
	term.read()
end

function GUILoop( BGCOL )
	while true do
		-- Draw
		gpu.setBackground( BGCOL )
		term.clear( )
		for k, v in pairs( windowTable ) do
			v:draw( )
		end
		gpu.setForeground( 0xFFFFFF )
		gpu.setBackground( 0x000000 )
		-- Event handling
		ev, ep1, ep2, ep3, ep4, ep5 = event.pull( )
		if ( ev == "touch" ) then -- p1 addr p2 + 3 loc
			for k, curwindow in pairs( windowTable ) do -- loop through windows in window table
				if ( ep2 == curwindow.p.x and ep3 == curwindow.p.y ) then -- Clicked movement cross
					ev, addr, nx, ny = event.pull( "touch" )
					curwindow.p.x = nx
					curwindow.p.y = ny
				end
				for k2, curcontents in pairs( curwindow.contents ) do -- loop through components in looped window
					if ( curcontents.guitype == "textinput" ) then
						tilx = curwindow.p.x + curcontents.p.x
						tirx = curwindow.p.x + curcontents.p.x + curcontents.w 
						tiy = curwindow.p.y + curcontents.p.y 
						if ( ep2 >= tilx and ep2 < tirx and ep3 == tiy ) then -- clicked the text input
							term.setCursor( tilx, tiy )
							repeat
								ev, addr, ch, code = event.pull( "key_down" )
								if ( code ~= 28 and code ~= 42 and code ~= 14 ) then
									curcontents.t = curcontents.t .. string.char(ch)
								end
								if ( code == 14 ) then
									curcontents.t = string.sub( curcontents.t, 1, #curcontents.t - 1 )
								end
								curcontents:draw( )
							until ( code == 28 )
						end
					end
					if ( curcontents.guitype == "button" ) then
						tp = point( ep2, ep3 )
						btl = curwindow.p + curcontents.p
						bbr = curwindow.p + curcontents.p + point( curcontents.w, curcontents.h )
						if ( pointInArea( tp, btl, bbr ) ) then -- Clicked button
							curcontents.cm( )
						end
					end
				end
			end
		end
	end
end