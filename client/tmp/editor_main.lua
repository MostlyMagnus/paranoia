dofile("helpers.lua")
dofile("symbols.lua")

-- global stuff
ROOMS_MAX_X = 35
ROOMS_MAX_Y = 20
OFFSET_X = 20
OFFSET_Y = 50
OFFSET_CHANGE = 10

mt_rooms = nil
mt_doors = nil
mt_nodes = nil 
-- currently selected room
sx = 3 
sy = 4 

logger = {"test"}
type_mode = false
last = "nothing"

-- graphix
GFX_R_SZ = 24
GFX_D_SZ = 4

GFX_COL_ROOM_C = {80, 80, 80, 255}
GFX_COL_ROOM_1  = {120, 120, 220, 255}

GFX_COL_DOOR_WALL  = {255,255,255}
GFX_COL_DOOR  = {126,126,126}
GFX_COL_DOOR_SEC_BLUE  = {180,180,255}
GFX_COL_DOOR_SEC_RED  = {255,180,180}

GFX_COL_BLACK = {0,0,0}
GFX_COL_WHITE = {255,255,255}

GFX_COL_GRID = {80, 80, 80, 150}
GFX_COL_BG = GFX_COL_BLACK
GFX_COL_SEL = {60, 60, 200, 190}
GFX_COL_LOG = {200, 200, 200}
GFX_COL_TEXT = {255, 255, 255}
GFX_COL_NODE_1 = {255, 0, 0}


function love.load()
	build_map(ROOMS_MAX_X, ROOMS_MAX_Y)
	load_map("./editor_ship.map")
	
	--font setup
	local f = love.graphics.newFont(12)
	love.graphics.setFont(f)
   
	love.graphics.setColor(230,230,230,255)
	love.graphics.setBackgroundColor(GFX_COL_BG)
end

function love.draw()

	start_x = OFFSET_X - GFX_R_SZ
	start_y = OFFSET_Y - GFX_R_SZ
	love.graphics.setColor(GFX_COL_GRID)
	love.graphics.setLine( 1.0, "rough" )	
	
	-- draw grid
	x_max = start_x + GFX_R_SZ*(ROOMS_MAX_X + 1)
	y_max = start_y + GFX_R_SZ*(ROOMS_MAX_Y + 1)
	for x=1, ROOMS_MAX_X+1 do
		love.graphics.line(start_x+x*GFX_R_SZ, start_y+GFX_R_SZ, start_x+x*GFX_R_SZ, y_max)
	end
	for y = 1, ROOMS_MAX_Y+1 do
		love.graphics.line(start_x + GFX_R_SZ, start_y + y*GFX_R_SZ, x_max, start_y + y*GFX_R_SZ)
	end
	
	-- draw all rooms and nodes
	circle_offset = GFX_R_SZ/2.0 -- move to scale function
	circle_radius = GFX_R_SZ/4.0 -- move to scale fucntion
	for x=1, table.getn(mt_rooms) do
		for y = 1, table.getn(mt_rooms[1]) do
		
			if mt_rooms[x][y] > R_EMPTY then
				if mt_rooms[x][y] == R_CORR then
					love.graphics.setColor(GFX_COL_ROOM_C)
				elseif mt_rooms[x][y] > R_CORR then
					love.graphics.setColor(GFX_COL_ROOM_1)	
				end
				
				love.graphics.rectangle('fill', start_x + x*GFX_R_SZ, start_y + y*GFX_R_SZ, GFX_R_SZ, GFX_R_SZ)
				
				-- draw nodes
				if mt_nodes[x][y] > N_NA then
					love.graphics.setColor(GFX_COL_NODE_1)
					love.graphics.circle("fill", start_x + x*GFX_R_SZ + circle_offset, start_y + y*GFX_R_SZ + circle_offset, circle_radius, 50)
					love.graphics.setColor(GFX_COL_BLACK)
					love.graphics.circle("line", start_x + x*GFX_R_SZ + circle_offset, start_y + y*GFX_R_SZ + circle_offset, circle_radius, 50)
				end
			end
		end
	end
	
	-- draw all doors
	-- (n*, m*) (room)
	-- => (doors) north: (n*2, m), south: (n*2, m+1), west: (n*2-1, m), east: (n*2+1, m)
	
	door_offset = GFX_D_SZ / 2
	
	for x=1, table.getn(mt_doors)  do
		for y = 1, table.getn(mt_doors[1]) do
			if mt_doors[x][y] ~= D_WALL and mt_doors[x][y] ~= D_NA and mt_doors[x][y] ~= D_ROOM then
				if mt_doors[x][y] == D_DOOR then
					love.graphics.setColor(GFX_COL_DOOR)	
				elseif mt_doors[x][y] == D_DOOR_SEC_BLUE then
					love.graphics.setColor(GFX_COL_DOOR_SEC_BLUE)	
				elseif mt_doors[x][y] == D_DOOR_SEC_YELLOW then
					love.graphics.setColor(GFX_COL_DOOR_SEC_RED)
				end
				if x%2 == 0 then -- horizontal door
					love.graphics.rectangle('fill', start_x + x/2*GFX_R_SZ, start_y - door_offset + y*GFX_R_SZ, GFX_R_SZ, GFX_D_SZ)
				else -- vertical door
					love.graphics.rectangle('fill', start_x -door_offset + x/2*GFX_R_SZ+GFX_R_SZ/2, start_y + y*GFX_R_SZ, GFX_D_SZ, GFX_R_SZ)
				end
			end
		end
	end
	
	-- draw selected tile marking
	--if selected then 
	love.graphics.setColor(GFX_COL_SEL)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle('line', start_x + sx * GFX_R_SZ, start_y + sy * GFX_R_SZ, GFX_R_SZ, GFX_R_SZ)
	--end
	
	-- current room
	love.graphics.setColor(GFX_COL_TEXT)
	--local selected_status = "(" .. sx-1 .. "," .. sy-1 .. "): " .. mt_rooms[sx][sy]
	local selected_status = "(" .. sx-1 .. "," .. sy-1 .. "): " .. r_names[mt_rooms[sx][sy]]
	if mt_nodes[sx][sy] ~= R_EMPTY then
		selected_status =  selected_status .. " Node: " .. n_names[mt_nodes[sx][sy]]
	end
	
	--local selected_status = "(" .. sx-1 .. "," .. sy-1 .. "): " .. r_names[mt_rooms[sx][sy]] .. n

	love.graphics.print( selected_status, 50, 10, 0, 1, 1 )
	
	-- db logger
	if logger ~= nil then
		love.graphics.setColor(GFX_COL_LOG)
		love.graphics.print( "> " .. logger[1], 50, 26, 0, 1, 1 )
	end
	
	local x = love.mouse.getX()
    local y = love.mouse.getY()
    --love.graphics.print("> mpos (" .. x .. "," .. y .. ")", 150, 10)
	--love.graphics.print("Last mouse click: " .. last, 100, 100)
end


function love.keypressed(key) 
	if key == "q" then
		love.event.push("q") 
	end
		
	if type_mode then 
		if key == "escape" then
			db_log("type mode disabled")
			type_mode = false
		end
		return 
	end
	
	if key == "e" then
		db_log("type mode inititated")
		type_mode = true
	elseif key == "n" then
		if mt_rooms[sx][sy] ~= R_EMPTY then
			mt_nodes[sx][sy] = N_GENERATOR
			db_log("node added")
		else
			db_log("Warning: stupid. Cannot place nodes in space")
		end
	elseif key == "s" then
		save_map("./editor_ship.map")
	
	end
	
		
	-- => (doors) north: (n*2, m), south: (n*2, m+1), west: (n*2-1, m), east: (n*2+1, m)
	
	-- shift offset
	if key == "kp8" then
		OFFSET_Y = OFFSET_Y - OFFSET_CHANGE
	elseif key == "kp2" then
		OFFSET_Y = OFFSET_Y + OFFSET_CHANGE
	elseif key == "kp4" then
		OFFSET_X = OFFSET_X - OFFSET_CHANGE
	elseif key == "kp6" then
		OFFSET_X = OFFSET_X + OFFSET_CHANGE
	end
	
	if love.keyboard.isDown("lctrl") then
		if key == "right" then
			mt_doors[sx*2+1][sy] = choose_door(sx*2+1, sy)
		elseif key == "left" then
			mt_doors[sx*2-1][sy] = choose_door(sx*2-1, sy)
		elseif key == "up" then
			mt_doors[sx*2][sy] = choose_door(sx*2, sy)
		elseif key == "down" then
			mt_doors[sx*2][sy+1] = choose_door(sx*2, sy+1)
		end
	else
		if key == "right" then
			if sx ~= ROOMS_MAX_X then
				sx = sx + 1
			end
		elseif key == "left" then
			if sx ~= 1 then
				sx = sx -1
			end
		elseif key == "up" then
			if sy ~= 1 then
				sy = sy -1
			end
		elseif key == "down" then
			if sy ~= ROOMS_MAX_Y then
				sy = sy + 1
			end
		end
	end
		
	if key == " " then
		if mt_nodes[sx][sy] > N_NA then
			mt_nodes[sx][sy] = N_NA
		else
			mt_rooms[sx][sy] = R_EMPTY
		end
	elseif key == "1" then
		mt_rooms[sx][sy] = R_CORR
	elseif key == "2" then
		mt_rooms[sx][sy] = R_GENERIC
	elseif key == "3" then
		mt_rooms[sx][sy] = R_BRIDGE
	
	
	elseif key == "kp+" then
		GFX_R_SZ = GFX_R_SZ + 6
		GFX_D_SZ = GFX_D_SZ + 2
		OFFSET_CHANGE = OFFSET_CHANGE + 6
	elseif key == "kp-" then
		GFX_R_SZ = GFX_R_SZ - 6
		GFX_D_SZ = GFX_D_SZ - 2
		OFFSET_CHANGE = OFFSET_CHANGE - 6
	end		
	
end

function choose_door(x, y)
	local new_door = D_NA
	local current = mt_doors[x][y]
	
	if current == D_NA then
		new_door = D_DOOR
	elseif current == D_DOOR then
		new_door = D_DOOR_SEC_BLUE
	elseif current == D_DOOR_SEC_BLUE then
		new_door = D_NA
	end
	return new_door
end

-- logs debug messages. should be extended to show the 5 latest messages and remove everything older
function db_log(text)
	logger[1] = text
end

function build_map(x_max, y_max)

mt_rooms = {}
mt_nodes = {}
	for x=1,x_max do
		mt_rooms[x] = {}
		mt_nodes[x] = {}
		for y=1,y_max do
			mt_rooms[x][y] = R_EMPTY
			mt_nodes[x][y] = N_NA
		end
	end
	
mt_doors  = {}
	for x=1, x_max*2+1 do
		mt_doors[x] = {}
		for y=1, y_max+1 do
			mt_doors[x][y] = D_NA
		end
	end
end

function save_map(filename)
	local file = io.open(filename,"w")
	if not file then 
		assert(0, "could not save file")
	end
	
	s = ""
	for x=1, table.getn(mt_rooms) do
		for y=1, table.getn(mt_rooms[1]) do
			if mt_rooms[x][y] > R_EMPTY then 
				s = s .. x-1 .. "," .. y-1 .. ";" -- coords
				s = s .. mt_doors[x*2][y] .. mt_doors[x*2+1][y] .. mt_doors[x*2][y+1] .. mt_doors[x*2-1][y] .. ";"-- doors
				s = s .. mt_rooms[x][y] -- rooms
				if mt_nodes[x][y] ~= N_NA then
					s = s .. ";" .. mt_nodes[x][y] -- node
				end
				s = s .. "$"
			end
		end
	end
	
	
	file:write(s)
	file:close()
	db_log("saved map")
	
end

function load_map(filename)
	-- ADD SANITY CHECKS!
	
	local file = io.open(filename,"r")
	if not file then 
		assert(io.open(filename, "w"))
		print("could not find '" .. filename .. "', creating it!")
		return false
	end
	
	local str = ""
	for line in file:lines() do
		str = str .. line
	end
	file:close()

	local rooms = split(str, "$")
	local coords = 0
	local x_coord = 0
	local y_coord = 0
	-- x, y;nesw;roomtype;node(s)
	for x=1, table.getn(rooms) do
		if rooms[x] == "" then
			break
		end
		tokens = split(rooms[x], ";")
		
		-- coords
		coords = split(tokens[1], ",")
		x_coord = tonumber(coords[1]) + 1 --remember to offset with one
		y_coord = tonumber(coords[2]) + 1
	
		-- doors
		-- => (doors) north: (n*2, m), south: (n*2, m+1), west: (n*2-1, m), east: (n*2+1, m)
		mt_doors[x_coord*2][y_coord] = char_at(tokens[2],1) -- north
		mt_doors[x_coord*2+1][y_coord] = char_at(tokens[2],2) -- east
		mt_doors[x_coord*2][y_coord+1] = char_at(tokens[2],3) -- south
		mt_doors[x_coord*2-1][y_coord] = char_at(tokens[2],4) -- west
	
		-- rooms
		mt_rooms[x_coord][y_coord] = tokens[3]
		
		-- nodes
		if table.getn(tokens) == 4 then
			mt_nodes[x_coord][y_coord] = tokens[4]
		else
			mt_nodes[x_coord][y_coord] = N_NA
		end
			
	end
	
	return true
end



-- incorporate mouse usage :)

-- Mousepressed: Called whenever a mouse button was pressed,
-- passing the button and the x and y coordiante it was pressed at.
function love.mousepressed(x, y, button)
	-- Checks which button was pressed.
	if button == "l" then
		last = "left pressed"
	elseif button == "r" then
		last = "right pressed"
	elseif button == "m" then
		last = "middle pressed"
	elseif button == "wu" then
		-- Won't show up because scrollwheels are instantly "released",
		-- but the event is legitimate.
		last = "scrollwheel up pressed"
	elseif button == "wd" then
		-- Won't show up because scrollwheels are instantly "released",
		-- but the event is legitimate.
		last = "scrollwheel down pressed"
	end
	
	last = last .. " @ (" .. x .. "x" .. y .. ")"
end

-- Mousereleased: Called whenever a mouse button was released,
-- passing the button and the x and y coordiante it was released at.
function love.mousereleased(x, y, button)
	-- Checks which button was released.
	if button == "l" then
		last = "left released"
	elseif button == "r" then
		last = "right released"
	elseif button == "m" then
		last = "middle released"
	elseif button == "wu" then
		last = "scrollwheel up released"
	elseif button == "wd" then
		last = "scrollwheel down released"
	end
	
	last = last .. " @ (" .. x .. "x" .. y .. ")"
end


