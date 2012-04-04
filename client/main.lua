-- LuaTask for threading the network traffic
assert(require('task'))

-- 32 lines of goodness - OO
assert(require('lib/32log'))

-- AnAl - Animations
assert(require('lib/anal'))

-- JSON encode/decode
assert(require('lib/json'))

-- Ship data symbols
assert(require('inc/symbols'))

-- Håkans helpers
assert(require('inc/helpers'))

-- GraphicsHandler
assert(require('inc/graphicshandler'))

-- ScreenObject Class
assert(require('inc/screenobject'))

-- TextObject Class
assert(require('inc/textobject'))

-- MenuObject class
--assert(require('inc/menuobject'))

assert(require('inc/tickmenu'))

assert(require('inc/serverinterface'))

-- QUICKIE UI.
GUI = require('inc/ui')

-- Testing Quickie UI.
local input = {text = "Hello, World!", cursor = 0}

lbuttonDown = { false, 0, 0 }

-- global stuff
OFFSET_X = 20
OFFSET_Y = 50
OFFSET_CHANGE = 10
GLOBAL_justLoaded = true

-- graphix
GFX_R_SZ = 160
GFX_D_SZ = 4

GFX_COL_BLACK = {0,0,0}
GFX_COL_BG = GFX_COL_BLACK

-- set up the handler to handle our graphics
graphicsHandler = GraphicsHandler:new()

server = ServerInterface:new()

-- set up the left menu function MenuHandler:__init(frameID, vertSwoop, HoriSwoop, x, y, w, h)
tickMenu = TickMenu:new(graphicsHandler:asset("tick_frame"), nil, nil, 96, 360,
						graphicsHandler:getWidth(graphicsHandler:asset("tick_frame")), 
						graphicsHandler:getHeight(graphicsHandler:asset("tick_frame")))

-- handles all the objects to be drawn to the screen
screenObjects = { }

-- add TextObject to this and itll be drawn
textObjects = { }

-- store, modify, update pawns in this
pawnObjects = { }

-- ui
uiObjects = { }
uiActionQueue = { }

-- radialMenu contains the current options for the radial select.
radialMenu = { }
radialGrid = { }

-- debugtext
gamestate = {}
stored_gamestate = nil

debugtext = ""
deb = ""

-- program state definitions
STATE_LOADING = 0
STATE_IDLE = 1
STATE_RADIAL = 2
STATE_PAN = 3
STATE_LOGGING_IN = 4
STATE_MOVING = 5
STATE_LOGIN_SCREEN = 6

-- we start in the logging in state
STATE = STATE_LOGGING_IN

-- we have no gamestate starting from scratch, so lets flag it as in need of update
GAMESTATE_NEEDS_UPDATING = true

-- VirtualPawn in pawnObjects list
PAWNOBJECTS_VIRTUALPAWN = 0

function love.load()

	--font setup
	defaultFont = love.graphics.newFont('fonts/coalition_v2.ttf', 16)
	love.graphics.setFont(defaultFont)
   
	love.graphics.setColor(255,255,255,190)

	love.graphics.setBackgroundColor(GFX_COL_BG)
	
	userInfo = {}
	
	userInfo["login"] = "foo@bar.com"
	userInfo["password"] = "foobar"

	-- Set up some bogus things to look at while we're logging in.
	table.insert(screenObjects, PawnObject:new((love.graphics.getWidth()/GFX_R_SZ)/2-1, (love.graphics.getHeight()/GFX_R_SZ)/2-3, graphicsHandler:asset("logo_big")))
	--table.insert(textObjects, TextObject:new("logging in", (love.graphics.getWidth()/GFX_R_SZ)/2-1, (love.graphics.getHeight()/GFX_R_SZ)/2-0.5, love.graphics.getFont():getWidth("logging in"), fontLogo))

	-- set up UI
	table.insert(uiObjects, ScreenObject:new(150, 20, graphicsHandler:asset("logo_small")))

	server:start()
	server:login("foo@bar.com", "foobar")

end


function love.update(dt)	
	server:update()

	-- get incoming messages

	if(STATE == STATE_LOGIN_SCREEN) then
		if GUI.Input(input, 10, 10, 300, 20) then
			print('Text changed:', input.text)
		end
	end

	-- If we're in the logging in state, see if the network thread has returned
	-- the message that the login was successful.
	if(STATE == STATE_LOGGING_IN) then		
		if(server:getMessage("login") == "login_ok") then
			print("Got login_ok!")
			STATE = STATE_IDLE
		end
	end


	if(STATE == STATE_IDLE) then
		-- if we're in idle, and we need to update the gamestate
		-- post an action to the network thread to fetch a new gamestate
		if (GAMESTATE_NEEDS_UPDATING) then
			server:getGamestate()
			GAMESTATE_NEEDS_UPDATING = false	
		end

		if (stored_gamestate) then
			local okToUpdate = true

			for key, value in pairs(pawnObjects) do
				
				if(# value.mMoves > 0) then okToUpdate = false end
			end

			if(okToUpdate) then 
				gamestate = stored_gamestate
				stored_gamestate = nil
				refreshSession() 
			end 
		end
	end

	-- Thread has returned a new gamestate for us. Lets decode it,
	-- and refresh the session.
	local temp_stored_state = server:getMessage("get gamestate")

	if not (temp_stored_state == nil) then
		stored_gamestate = json.decode(temp_stored_state)
	end

	--  Thread has just returned the info that an action has been added.
	-- Lets flag the gamestate for update.
	if(flags == THREAD_ADD_ACTION) then
		GAMESTATE_NEEDS_UPDATING = true
	end


	if(STATE == STATE_PAN) then
		OFFSET_X = lbuttonDown[4] + love.mouse.getX() - lbuttonDown[2]
		OFFSET_Y = lbuttonDown[5] + love.mouse.getY() - lbuttonDown[3]
	end
	
	if(STATE == STATE_MOVING) then
		local stillMoving = false

		for key, value in pairs(pawnObjects) do
			value:update(dt)

			if(# value.mMoves > 0) then
				stillMoving = true
			end
		end

		if not (stillMoving) then STATE = STATE_IDLE end
	end

	-- update the relative mouse positions
	start_x = OFFSET_X + GFX_R_SZ/2
	start_y = OFFSET_Y + GFX_R_SZ/2

	mouse_x_relative = -1*OFFSET_X + love.mouse.getX()
	mouse_y_relative = -1*OFFSET_Y + love.mouse.getY()
	
   	
	-- call the graphicshandler to update any animations we currently
	-- have running.
	graphicsHandler:update(dt)

	-- update menus
	tickMenu:update(dt)
end

function love.draw()
	-- Lets draw!
	love.graphics.setColor(255,255,255,190)
	love.graphics.setFont(defaultFont)

   	graphicsHandler:draw(graphicsHandler:asset("background"), love.graphics.getWidth()/2, love.graphics.getHeight()/2)

	-- draw sprites	
	for _key, _value in pairs(screenObjects) do
		graphicsHandler:draw(_value.mAssetID, start_x+_value.mX*GFX_R_SZ, start_y+_value.mY*GFX_R_SZ, nil, GFX_R_SZ/graphicsHandler:getWidth(_value.mAssetID))
	end

	-- draw pawns
	for _key, _value in pairs(pawnObjects) do
		love.graphics.print(_value.mText, start_x+_value.mX*GFX_R_SZ-love.graphics.getFont():getWidth(_value.mText)/2, start_y+_value.mY*GFX_R_SZ - GFX_R_SZ*0.6)
		graphicsHandler:draw(_value.mAssetID, start_x+_value.mX*GFX_R_SZ, start_y+_value.mY*GFX_R_SZ, nil, GFX_R_SZ/graphicsHandler:getWidth(_value.mAssetID))
	end

	
	-- draw textObjects
	for key, value in pairs(textObjects) do
		love.graphics.print(value.mText, start_x+value.mX*GFX_R_SZ-love.graphics.getFont():getWidth(value.mText)/2, start_y+value.mY*GFX_R_SZ - GFX_R_SZ*0.6)
	end
	
	
	if(STATE == STATE_RADIAL) then
		-- draw radialMenu
		for key, value in pairs(radialMenu) do
			love.graphics.rectangle("fill",(value.mX+0.5)*GFX_R_SZ - love.graphics.getFont():getWidth(value.mText)/2, (value.mY+0.5)*GFX_R_SZ, (value.mX+0.5)*GFX_R_SZ + love.graphics.getFont():getWidth(value.mText)/2-(value.mX+0.5)*GFX_R_SZ - love.graphics.getFont():getWidth(value.mText)/2, (value.mY+0.5)*GFX_R_SZ + love.graphics.getFont():getHeight(value.mText) - (value.mY+0.5)*GFX_R_SZ)
			love.graphics.print(value.mText, start_x+value.mX*GFX_R_SZ-love.graphics.getFont():getWidth(value.mText)/2, start_y+value.mY*GFX_R_SZ)			
		end
	
	end

	if not (STATE == STATE_LOGGING_IN) and not (STATE == STATE_LOADING) then
		-- draw ui overlay objects
		for _key, _value in pairs(uiObjects) do
			graphicsHandler:draw(_value.mAssetID, _value.mX, _value.mY, nil, 1)
		end	

		local ui = tickMenu:getMenuAssets()

		for _key, _value in pairs(ui) do
			graphicsHandler:draw(_value.mAssetID, _value.mX, _value.mY, nil, 1)
		end
	end

	-- draw the widgets which were "created" in love.update
	GUI.core.draw()
end


-- Mousepressed: Called whenever a mouse button was pressed,
-- passing the button and the x and y coordiante it was pressed at.
function love.mousepressed(x, y, button)
	if not (STATE == STATE_LOGGING_IN) and not (STATE == STATE_LOADING) then

		-- Checks which button was pressed.
		if button == "l" then
			local state_changed = false
			

			--last = "left pressed"		
			if(STATE == STATE_IDLE and not state_changed) then								
				local clicked_x = math.floor(mouse_x_relative / GFX_R_SZ)
				local clicked_y = math.floor(mouse_y_relative / GFX_R_SZ)
				
				grid = buildRadial(clicked_x, clicked_y)
				
				if grid then
					radialMenu = grid
					--	if we did, set state to radial with ego radial
					STATE = STATE_RADIAL
									
					state_changed = true
				else
					-- check if we clicked a different square
					--	if we did, set state to radial with room radial
					-- go into pan mode	
					if not (tickMenu:clickCheck()) then	
						STATE = STATE_PAN				
						lbuttonDown = { true, x, y, OFFSET_X, OFFSET_Y }
					else
						state_changed = true
					end
				end
			end
			
			if(STATE == STATE_RADIAL and not state_changed) then
				for key, value in pairs(radialMenu) do				
					if	mouse_x_relative > (value.mX+0.5)*GFX_R_SZ - love.graphics.getFont():getWidth(value.mText)/2 and
						mouse_x_relative < (value.mX+0.5)*GFX_R_SZ + love.graphics.getFont():getWidth(value.mText)/2 and
						mouse_y_relative > (value.mY+0.5)*GFX_R_SZ and
						mouse_y_relative < (value.mY+0.5)*GFX_R_SZ + love.graphics.getFont():getHeight(value.mText)  then				
						server:addAction(value)						
					end
				end
				
				STATE = STATE_IDLE
			end	
		elseif button == "r" then
			--last = "right pressed"
			if(STATE == STATE_RADIAL) then 
				STATE = STATE_IDLE
			else		
				--STATE = STATE_RADIAL
			end

		elseif button == "m" then
			--last = "middle pressed"
		elseif button == "wu" then
			-- Won't show up because scrollwheels are instantly "released",
			-- but the event is legitimate.
			--last = "scrollwheel up pressed"
		elseif button == "wd" then
			-- Won't show up because scrollwheels are instantly "released",
			-- but the event is legitimate.
			--last = "scrollwheel down pressed"
		end
	end
end

-- Mousereleased: Called whenever a mouse button was released,
-- passing the button and the x and y coordiante it was released at.
function love.mousereleased(x, y, button)
	if not (STATE == STATE_LOGGING_IN) and not (STATE == STATE_LOADING) then

		-- Checks which button was released.
		if button == "l" then
			--last = "left released"
			if(STATE == STATE_PAN) then
				STATE = STATE_IDLE
				
				lbuttonDown = { false, x, y }
			end
		elseif button == "r" then
			--last = "right released"
			--STATE = STATE_IDLE
		elseif button == "m" then
			--last = "middle released"
		elseif button == "wu" then
			--last = "scrollwheel up released"
			GFX_R_SZ = GFX_R_SZ + 6
			GFX_D_SZ = GFX_D_SZ + 2
			OFFSET_CHANGE = OFFSET_CHANGE + 6
		
		elseif button == "wd" then
			--last = "scrollwheel down released"
			GFX_R_SZ = GFX_R_SZ - 6
			GFX_D_SZ = GFX_D_SZ - 2
			OFFSET_CHANGE = OFFSET_CHANGE - 6

		end
	end
end

function love.keypressed(key, code) 

	-- For specific game states, should be filtered based on that.
	if key == "kp+" then
		GFX_R_SZ = GFX_R_SZ + 6
		GFX_D_SZ = GFX_D_SZ + 2
		OFFSET_CHANGE = OFFSET_CHANGE + 6
	elseif key == "kp-" then
		GFX_R_SZ = GFX_R_SZ - 6
		GFX_D_SZ = GFX_D_SZ - 2
		OFFSET_CHANGE = OFFSET_CHANGE - 6
	end		
	
	-- For specific game states, should be filtered based on that.
	if key == "up" then
		addMove(0,-1)
	elseif key == "down" then		
		addMove(0,1)
	elseif key == "right" then
		addMove(1,0)
	elseif key == "left" then
		addMove(-1,0)
	end			

	-- forward keyboard events to the gui. 
	GUI.core.keyboard.pressed(key, code)	
end

function addMove( xMod, yMod )
	--if not (STATE == STATE_MOVING) then
		pawnObjects[PAWNOBJECTS_VIRTUALPAWN]:addMove(xMod, yMod)
	
		server:addAction(MenuObject:new(nil, nil, nil, "4", gamestate.virtualPawn.x+xMod ..","..gamestate.virtualPawn.y+yMod))

		gamestate.virtualPawn.x = gamestate.virtualPawn.x+xMod 
		gamestate.virtualPawn.y = gamestate.virtualPawn.y+yMod 

		STATE = STATE_MOVING
	--end
end

function refreshSession()
	-- clear out earlier

	-- handles all the objects to be drawn to the screen
	screenObjects = { }
	pawnObjects = {}
	textObjects = { }

	-- radialMenu contains the current options for the radial select.
	radialMenu = { }
	radialGrid = { }

	buildscreenObjects()
	buildTickmenu()

	if GLOBAL_justLoaded then 
		centerOffsetOnVirtualPawn() 
		GLOBAL_justLoaded = false
	end
end

function buildRadial(passed_x, passed_y)
	local egogrid = {}
	local cireturnCodele_radius = 1
	local options = 0	
	
	for key_x, value_x in pairs(gamestate.ship.map) do
		for key_y, value_y in pairs(value_x) do
			if tonumber(key_x)+1 == passed_x and tonumber(key_y)+1 == passed_y then			
				if(value_y.possibleactions) then
					if(# value_y.possibleactions > 0) then
						if(# value_y.possibleactions % 2) > 0 then
							options = # value_y.possibleactions+1
						else
							options = # value_y.possibleactions
						end
						
						for key_action, value_action in pairs (value_y.possibleactions) do
							angle = key_action * (math.rad(360) / options)- (math.rad(360) / options)/2
							
							local new_x = passed_x + math.cos(angle)*cireturnCodele_radius
							local new_y = passed_y + math.sin(angle)*cireturnCodele_radius
							
							table.insert(egogrid, MenuObject:new(value_action.verbose, new_x, new_y, value_action.action_type, value_action.params))
						end
						
						return egogrid
					end
				end			
			end
		end
	end	
	
	return nil
	
end

function buildscreenObjects()
	for key_x, value_x in pairs(gamestate.ship.map) do
		for key_y, value_y in pairs(value_x) do
			if(value_y.room_type) then
				table.insert(screenObjects, ScreenObject:new(key_x+1, key_y+1, graphicsHandler:asset(value_y.room_type)))

				if value_y.node then
					if value_y.node.node_type > N_NA then
						table.insert(screenObjects, ScreenObject:new(key_x+1, key_y+1, graphicsHandler:asset(value_y.node.node_type)))
					end
				end
				
				if not value_y.seen then
					table.insert(screenObjects, ScreenObject:new(key_x+1, key_y+1, graphicsHandler:asset("fog")))
				end
			end
		end
	end
	
	for key, value in pairs(gamestate.gamestatePawns) do
		if (value.x) then
			table.insert(screenObjects, PawnObject:new(value.x+1, value.y+1, graphicsHandler:asset("player"), value.pawn_id))
			table.insert(textObjects, TextObject:new(value.persona.persona.name, value.x+1, value.y+1, love.graphics.getFont():getWidth(value.persona.persona.name)))
		end
	end
	
	-- add the virtual pawn
	table.insert(pawnObjects, PawnObject:new(gamestate.virtualPawn.x+1, gamestate.virtualPawn.y+1, graphicsHandler:asset("player"), "Your virtual pawn!"))


	PAWNOBJECTS_VIRTUALPAWN = # pawnObjects 	
end

function buildTickmenu()
	tickMenu:clear()

	tickMenu:addButton(graphicsHandler:asset("open"), graphicsHandler:asset("open"),						
					tickMenu.mWidth, tickMenu.mHeight/2, 
					graphicsHandler:getWidth(graphicsHandler:asset("open")), 
					graphicsHandler:getHeight(graphicsHandler:asset("open")),
					"", 
					function () 
						tickMenu:swapState()
					end)						

	-- rebuild the actionqueue menu
	for key, tick in pairs(gamestate.actionQueue) do
		for key, action in pairs (tick) do
			-- function Button:__init( id, hover_id,  x, y, w, h, metadata, callback )
			tickMenu:addButton(graphicsHandler:asset("tick"), 
								graphicsHandler:asset("tick_hovering"),						
								92, 
								graphicsHandler:getHeight(graphicsHandler:asset("tick"))/2 + graphicsHandler:getHeight(graphicsHandler:asset("tick"))*(action["queue_number"]), 
								graphicsHandler:getWidth(graphicsHandler:asset("tick")), 
								graphicsHandler:getHeight(graphicsHandler:asset("tick")),
								"", 
								function () 
									tickMenu:swapState()
								end)
		end
	end

	
end

function centerOffsetOnVirtualPawn()
	OFFSET_X = -1*((1.5+gamestate.virtualPawn.x) * GFX_R_SZ)+love.graphics.getWidth()/2
	OFFSET_Y = -1*((1.5+gamestate.virtualPawn.y) * GFX_R_SZ)+love.graphics.getHeight()/2
end
