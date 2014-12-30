-- Created by Sirdabalot - 30/12/2014
-- Don't reproduce with small modifications and call it your own etc...

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
		point = P,
		width = W-1,
		height = H,
		title = T,
		fgcol = FGCOL,
		bgcol = BGCOL,
		contents = { }
	}
	
	return setmetatable( w, windowMeta )
end

function windowMeta:draw( )
	-- Do shadow
	gpu.setBackground( 0x000000 )
	gpu.fill( self.point.x+1, self.point.y+1, self.width, self.height, " " )
	-- Do background
	gpu.setBackground( self.bgcol )
	gpu.fill( self.point.x, self.point.y, self.width, self.height, " " )
	-- Do label
	gpu.setForeground( self.fgcol )
	gpu.set( self.point.x, self.point.y, string.rep( "=", self.width ) )
	gpu.set( self.point.x, self.point.y, "#" )
	gpu.set( self.point.x + math.floor( self.width / 2 ) - math.ceil( #self.title / 2 ), self.point.y, self.title )
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
		window = Win,
		point = P,
		width = W,
		height = H,
		label = L,
		fgcol = FGCOL,
		bgcol = BGCOL,
		clickedMethod = CM
	}
	
	br = setmetatable( b, buttonMeta )
	table.insert( b.window.contents, br )
	return br
end

function buttonMeta:draw( )
	-- Do background
	gpu.setBackground( self.bgcol )
	gpu.fill( self.window.point.x + self.point.x-1, self.window.point.y + self.point.y, self.width, self.height, " " )
	-- Do label
	gpu.setForeground( self.fgcol )
	gpu.set( self.window.point.x + self.point.x + math.floor( self.width / 2 ) - math.floor( #self.label / 2 ) - 1, self.window.point.y + self.point.y + math.floor( self.height / 2 ), self.label )
end

-- textbox --

textBoxMeta = { }

textBoxMeta.__index = textBoxMeta

function textBox( Win, P, W, H, T, FGCOL, BGCOL )
	local tb = {
		window = Win,
		point = P,
		width = W,
		height = H,
		text = T,
		fgcol = FGCOL,
		bgcol = BGCOL
	}
	
	tbr = setmetatable( tb, textBoxMeta )
	table.insert( tb.window.contents, tbr )
	return tbr
end

function textBoxMeta:draw( )
	-- Do background
	gpu.setBackground( self.bgcol )
	gpu.fill( self.winow.point.x + self.point.x-1, self.window.point.y + self.point.y, self.width, self.height, " " )
	-- Do text
	gpu.setForeground( self.fgcol )
	linesNeeded = math.floor(#self.text/self.width)
	for i = 1, linesNeeded+1 do
		tbSubStr = string.sub( self.text, ( i ) * self.width - self.width+1, ( i ) * self.width )
		gpu.set( self.window.point.x + self.point.x-1, self.window.point.y + self.point.y-1 + i, tbSubStr )
	end
end

-- TextInput --

textInputMeta = { }

textInputMeta.__index = textInputMeta

function textInput( Win, P, W, FGCOL, BGCOL )
	local ti = {
		guitype = "textinput",
		window = Win,
		point = P,
		width = W,
		text = "",
		fgcol = FGCOL,
		bgcol = BGCOL
	}
	
	tir = setmetatable( ti, textInputMeta )
	table.insert( ti.window.contents, tir )
	return tir
end

function textInputMeta:draw( )
	gpu.setForeground( self.fgcol )
	gpu.setBackground( self.bgcol )
	gpu.set( self.window.point.x + self.point.x, self.window.point.y + self.point.y, string.rep( " ", self.width ) )
	gpu.set( self.window.point.x + self.point.x, self.window.point.y + self.point.y, self.text )
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
				if ( ep2 == curwindow.point.x and ep3 == curwindow.point.y ) then -- Clicked movement cross
					ev, addr, nx, ny = event.pull( "touch" )
					curwindow.point.x = nx
					curwindow.point.y = ny
				end
				for k2, curcontents in pairs( curwindow.contents ) do -- loop through components in looped window
					if ( curcontents.guitype == "textinput" ) then
						tilx = curwindow.point.x + curcontents.point.x
						tirx = curwindow.point.x + curcontents.point.x + curcontents.width 
						tiy = curwindow.point.y + curcontents.point.y 
						if ( ep2 >= tilx and ep2 < tirx and ep3 == tiy ) then -- clicked the text input
							term.setCursor( tilx, tiy )
							repeat
								ev, addr, ch, code = event.pull( "key_down" )
								if ( code ~= 28 and code ~= 42 and code ~= 14 ) then
									curcontents.text = curcontents.text .. string.char(ch)
								end
								if ( code == 14 ) then
									curcontents.text = string.sub( curcontents.text, 1, #curcontents.text - 1 )
								end
								curcontents:draw( )
							until ( code == 28 )
						end
					end
					if ( curcontents.guitype == "button" ) then
						tp = point( ep2, ep3 )
						btl = curwindow.point + curcontents.point
						bbr = curwindow.point + curcontents.point + point( curcontents.width, curcontents.height )
						if ( pointInArea( tp, btl, bbr ) ) then -- Clicked button
							curcontents.clickedMethod( )
						end
					end
				end
			end
		end
	end
end