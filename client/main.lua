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
GUI = require('inc/ui/')

-- Testing Quickie UI.
local login = {text = "", cursor = 0}
local password = {text = "", cursor = 0}

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

host = { text = "192.168.1.248" }

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
uiLoadingScreen = { }

-- chatbox
chatLog = { }
chatbox= { }
timeSinceLastChatUpdate = 0

-- login functions to finish
functionQueue = { }

-- radialMenu contains the current options for the radial select.
radialMenu = { }
radialGrid = { }

-- gamestate
gamestate = {}
stored_gamestate = nil
timeSinceLastGamestateUpdate = 0

-- program state definitions
STATE_LOADING = 0
STATE_IDLE = 1
STATE_RADIAL = 2
STATE_PAN = 3
STATE_LOGGING_IN = 4

STATE_LOGIN_SCREEN = 6

-- we start in the logging in state
STATE = STATE_LOGIN_SCREEN

--- thread symbols 
THREAD_LOGIN = 2
THREAD_GAMESTATE = 3
THREAD_ADD_ACTION = 4

-- we have no gamestate starting from scratch, so lets flag it as in need of update
GAMESTATE_NEEDS_UPDATING = false

-- VirtualPawn in pawnObjects list
PAWNOBJECTS_VIRTUALPAWN = 0

--[[
	-- PRE GAME STATES
	if(STATE == STATE_LOGIN_SCREEN) then
	end
	if(STATE == STATE_LOGGING_IN) then
	end
	if(STATE == STATE_LOADING) then
	end

	-- IN GAME STATES
	if(STATE == STATE_IDLE) then
	end
	if(STATE == STATE_RADIAL) then
	end
	if(STATE == STATE_PAN) then
	end

]]

--[[
  _                  _                 _ 
 | | _____   _____  | | ___   __ _  __| |
 | |/ _ \ \ / / _ \ | |/ _ \ / _` |/ _` |
 | | (_) \ V /  __/_| | (_) | (_| | (_| |
 |_|\___/ \_/ \___(_)_|\___/ \__,_|\__,_|
                                         
]]
function love.load()

	--font setup
	defaultFont = love.graphics.newFont('fonts/coalition_v2.ttf', 16)
	love.graphics.setFont(defaultFont)
   
	love.graphics.setColor(255,255,255,190)

	love.graphics.setBackgroundColor(GFX_COL_BG)
	
	-- Set up some bogus things to look at while we're logging in.
	--table.insert(screenObjects, ScreenObject:new(love.graphics.getWidth()/2, love.graphics.getHeight()/2, graphicsHandler:asset("logo_big")))
	--table.insert(textObjects, TextObject:new("logging in", (love.graphics.getWidth()/GFX_R_SZ)/2-1, (love.graphics.getHeight()/GFX_R_SZ)/2-0.5, love.graphics.getFont():getWidth("logging in"), fontLogo))

	-- set up UI
	table.insert(uiObjects, ScreenObject:new(love.graphics.getWidth()/2, 20, graphicsHandler:asset("logo_small")))

	-- set up loading screen
	table.insert(uiLoadingScreen, ScreenObject:new((love.graphics.getWidth()/2), (love.graphics.getHeight()/2), graphicsHandler:asset("loading_circle")))

end

--[[
  _                                  _       _        
 | | _____   _____   _   _ _ __   __| | __ _| |_  ___ 
 | |/ _ \ \ / / _ \ | | | | '_ \ / _` |/ _` | __|/ _ \
 | | (_) \ V /  __/_| |_| | |_) | (_| | (_| | |_|  __/
 |_|\___/ \_/ \___(_)\__,_| .__/ \__,_|\__,_|\__|\___|
                          |_|                         
]]
function love.update(dt)	
	-- get incoming messages
	server:update()
	updateRelativeMousePosition()	
	-- update menus
	tickMenu:update(dt)

	-- PRE GAME STATES
	if(STATE == STATE_LOGIN_SCREEN) then
		inputGetLoginInfo()
	end

	if(STATE == STATE_LOGGING_IN) then		
		-- If we're in the logging in state, see if the network thread has returned
		-- the message that the login was successful.
		local loginCheck = threadcheckLoggingIn()

		if(loginCheck == true) then

			STATE_SUBSTATE = 0

			STATE = STATE_LOADING
		elseif(loginCheck == false) then
			STATE = STATE_LOGIN_SCREEN
		end
	end

	if(STATE == STATE_LOADING) then
		if(STATE_SUBSTATE == 0) then
			server:getText(0)	
			server:getGamestate()	

			STATE_SUBSTATE = 1
		end
		if(STATE_SUBSTATE == 1) then
			if(threadcheckLookForChatlog()) then
				STATE_SUBSTATE = 2
			end
		end
		if(STATE_SUBSTATE == 2) then
			if(threadcheckLookForGamestate()) then
				STATE = STATE_IDLE	
			end
		end
	end

	-- IN GAME STATES
	if(STATE == STATE_IDLE) then
		updateMoves(dt)
		updateChatLog(dt)

 		updateGamestateIfNeeded(dt)

 		inputGameGetChatbox()

		threadcheckLookForChatlog()
		threadcheckLookForGamestate()
	end

	if(STATE == STATE_RADIAL) then
		updateMoves(dt)
		updateChatLog(dt)

 		inputGameGetChatbox()

		threadcheckLookForChatlog()
		threadcheckLookForGamestate()
	end

	if(STATE == STATE_PAN) then
		updateMoves(dt)
		updateChatLog(dt)

 		inputGameGetChatbox()

		updateMousePanOffset()

		threadcheckLookForChatlog()
		threadcheckLookForGamestate()
	end	

	-- call the graphicshandler to update any animations we currently
	-- have running.
	graphicsHandler:update(dt)
end

--[[
  _                      _                    
 | | _____   _____    __| |_ __ __ ___      __
 | |/ _ \ \ / / _ \  / _` | '__/ _` \ \ /\ / /
 | | (_) \ V /  __/_| (_| | | | (_| |\ V  V / 
 |_|\___/ \_/ \___(_)\__,_|_|  \__,_| \_/\_/  
                                              
 ]]
function love.draw()
	-- Lets draw!
	love.graphics.setColor(255,255,255,190)
	love.graphics.setFont(defaultFont)

	if(STATE == STATE_LOGIN_SCREEN) then
	end

	if(STATE == STATE_LOGGING_IN) then
		drawLoadingScreen()
	end

	if(STATE == STATE_LOADING) then
		drawLoadingScreen()
	end

	if(STATE == STATE_IDLE) then
		drawGameBackground()
		drawGameObjects()	

		drawGameUI()
	end

	if(STATE == STATE_RADIAL) then
		drawGameBackground()
		drawGameObjects()	

		drawGameRadialMenu()

		drawGameUI()
	end

	if(STATE == STATE_PAN) then
		drawGameBackground()
		drawGameObjects()	

		drawGameUI()
	end

	-- draw the widgets which were "created" in love.update
	GUI.core.draw()
end

--[[
  _                                                                                 _ 
 | | _____   _____   _ __ ___   ___  _   _ ___  ___ _ __  _ __ ___ ___ ___  ___  __| |
 | |/ _ \ \ / / _ \ | '_ ` _ \ / _ \| | | / __|/ _ \ '_ \| '__/ _ | __/ __|/ _ \/ _` |
 | | (_) \ V /  __/_| | | | | | (_) | |_| \__ \  __/ |_) | | |  __|__ \__ \  __/ (_| |
 |_|\___/ \_/ \___(_)_| |_| |_|\___/ \__,_|___/\___| .__/|_|  \___|___/___/\___|\__,_|
                                                   |_|                                
]]
function love.mousepressed(x, y, button)
	-- PRE GAME STATES
	if(STATE == STATE_LOGIN_SCREEN) then
	end
	if(STATE == STATE_LOGGING_IN) then
	end
	if(STATE == STATE_LOADING) then
	end

	-- IN GAME STATES
	if(STATE == STATE_RADIAL) then
		mousePressedGame(x, y, button)
	end
	if(STATE == STATE_PAN) then
		mousePressedGame(x, y, button)
	end
	if(STATE == STATE_IDLE) then
		mousePressedGame(x, y, button)
	end

end

--[[
  _                                                          _                         _ 
 | | _____   _____   _ __ ___   ___  _   _ ___  ___ _ __ ___| | ___  __ _ ___  ___  __| |
 | |/ _ \ \ / / _ \ | '_ ` _ \ / _ \| | | / __|/ _ \ '__/ _ \ |/ _ \/ _` / __|/ _ \/ _` |
 | | (_) \ V /  __/_| | | | | | (_) | |_| \__ \  __/ | |  __/ |  __/ (_| \__ \  __/ (_| |
 |_|\___/ \_/ \___(_)_| |_| |_|\___/ \__,_|___/\___|_|  \___|_|\___|\__,_|___/\___|\__,_|
                                                                                         
]]
function love.mousereleased(x, y, button)

	-- PRE GAME STATES
	if(STATE == STATE_LOGIN_SCREEN) then
	end
	if(STATE == STATE_LOGGING_IN) then
	end
	if(STATE == STATE_LOADING) then
	end

	-- IN GAME STATES

	if(STATE == STATE_IDLE) then
		mouseReleasedGame(x, y, button)
	end

	if(STATE == STATE_RADIAL) then
		mouseReleasedGame(x, y, button)
	end

	if(STATE == STATE_PAN) then
		mouseReleasedGame(x, y, button)
	end
end


--[[
  _                  _                                               _ 
 | | _____   _____  | | __ ___ _   _ _ __  _ __ ___ ___ ___  ___  __| |
 | |/ _ \ \ / / _ \ | |/ // _ \ | | | '_ \| '__/ _ | __/ __|/ _ \/ _` |
 | | (_) \ V /  __/_|   <|  __/ |_| | |_) | | |  __|__ \__ \  __/ (_| |
 |_|\___/ \_/ \___(_)_|\_\\___|\__, | .__/|_|  \___|___/___/\___|\__,_|
                               |___/|_|                                
]]
function love.keypressed(key, code) 

	-- PRE GAME STATES
	if(STATE == STATE_LOGIN_SCREEN) then
	end
	if(STATE == STATE_LOGGING_IN) then
	end
	if(STATE == STATE_LOADING) then
	end

	-- IN GAME STATES
	if(STATE == STATE_RADIAL) then
		gameKeyPressed(key, code)
	end

	if(STATE == STATE_PAN) then
		gameKeyPressed(key, code)
	end

	if(STATE == STATE_IDLE) then
		gameKeyPressed(key, code)		
	end

	-- forward keyboard events to the gui. 
	GUI.core.keyboard.pressed(key, code)	
end


--[[
            _                  _       
  ___ _ __ (_)_ __  _ __   ___| |_ ___ 
 / __| '_ \| | '_ \| '_ \ / _ \ __/ __|
 \__ \ | | | | |_) | |_) |  __/ |_\__ \
 |___/_| |_|_| .__/| .__/ \___|\__|___/
             |_|   |_|                 
]]

--[[
  _                   _   
 (_)_ __  _ __  _   _| |_ 
 | | '_ \| '_ \| | | | __|
 | | | | | |_) | |_| | |_ 
 |_|_| |_| .__/ \__,_|\__|
         |_|              
]]
function inputGetLoginInfo() 
	if GUI.Input(host, love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2-45, 300, 20) then
			print('Text changed:', host.text)
	end	
	if GUI.Input(login, love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2-20, 300, 20) then
			print('Text changed:', login.text)
	end
	if GUI.Password(password, love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2+5, 300, 20) then
		print('Text changed:', password.text)
	end
	if GUI.Button('Login', love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2+40,300,20) then
		server:setHost("http://"..host.text.."/")
		server:start()
		server:login(login.text, password.text)

		STATE = STATE_LOGGING_IN
	end
end

function inputGameGetChatbox()
	if GUI.Input(chatbox, 220, love.graphics.getHeight()-20, 400, 20) then
		print('Text changed:', chatbox.text)
	end
	if GUI.Button('Send', 640, love.graphics.getHeight() - 20, 100,20) then
		gameSendChatBox()
	end
end

--[[
  _   _                        _        _               _    
 | |_| |__  _ __ ___  __ _  __| |   ___| |__   ___  ___| | __
 | __| '_ \| '__/ _ \/ _` |/ _` |  / __| '_ \ / _ \/ __| |/ /
 | |_| | | | | |  __/ (_| | (_| | | (__| | | |  __/ (__|   < 
  \__|_| |_|_|  \___|\__,_|\__,_|  \___|_| |_|\___|\___|_|\_\
                                                             
]]
function threadcheckLoggingIn()
	local serverMessage = server:getMessage("login")

	if(serverMessage == "login_ok") then
		print("Got login_ok!")

		return true
	elseif (serverMessage == "login_failed" ) then
		print("Login failed!")

		return false
	end

	return nil
end

function threadcheckLookForGamestate()
	-- Thread has returned a new gamestate for us. Lets decode it,
	-- and tell the session there's a new gamestate waiting to be 
	-- put to use.
	local temp_stored_state = server:getMessage("get gamestate")

	if not (temp_stored_state == nil) then
		stored_gamestate = json.decode(temp_stored_state)

		return true
	end

	return false
end

function threadcheckLookForChatlog()

	local temp_stored_chatlog = server:getMessage("get text")

	if not (temp_stored_chatlog == nil) then
		timeSinceLastChatUpdate = 0

		if not (temp_stored_chatlog == "[]") then

			local decoded_log = json.decode(temp_stored_chatlog)

			for key, value in pairs(decoded_log) do
				table.insert(chatLog, value)
			end

			return true
		end
	end

	return false
end

--[[
                  _       _        
  _   _ _ __   __| | __ _| |_  ___ 
 | | | | '_ \ / _` |/ _` | __|/ _ \
 | |_| | |_) | (_| | (_| | |_|  __/
  \__,_| .__/ \__,_|\__,_|\__|\___|
       |_|                         
]]
function updateGamestateIfNeeded(dt)
	-- If we need to update the gamestate
	-- post an action to the network thread to fetch a new gamestate

	timeSinceLastGamestateUpdate = timeSinceLastGamestateUpdate + dt

	if (stored_gamestate) then
		local okToUpdate = true

		if (server:tasksPendingAffectingGamestate()) then 
			-- user has modified his local gamestate since this data was fetched, discard it
			stored_gamestate = nil

			-- its not ok to update
			okToUpdate = false 

			-- we need to get a new state
			GAMESTATE_NEEDS_UPDATING = true
		end

		if(okToUpdate) then 
			if not (gamestate.turn == stored_gamestate.turn) then
				print("This gamestate is for the next turn.")
			end

			gamestate = stored_gamestate
			stored_gamestate = nil
			refreshSession() 
		end 
	end

	if(timeSinceLastGamestateUpdate > 45) then
		GAMESTATE_NEEDS_UPDATING = true
		timeSinceLastGamestateUpdate = 0
	end

	if (GAMESTATE_NEEDS_UPDATING) then
		if not server:tasksPendingAffectingGamestate() then
			server:getGamestate()

			GAMESTATE_NEEDS_UPDATING = false	
		end
	end
end

function checkTurnTimer()
	
end

function updateMousePanOffset()
	OFFSET_X = lbuttonDown[4] + love.mouse.getX() - lbuttonDown[2]
	OFFSET_Y = lbuttonDown[5] + love.mouse.getY() - lbuttonDown[3]
end

function updateMoves(dt)
	local stillMoving = false

	for key, value in pairs(pawnObjects) do
		value:update(dt)

		if(# value.mMoves > 0) then
			stillMoving = true
		end
	end

	--if not (stillMoving) then STATE = STATE_IDLE end
end

function updateRelativeMousePosition()
	-- update the relative mouse positions
	start_x = OFFSET_X + GFX_R_SZ/2
	start_y = OFFSET_Y + GFX_R_SZ/2

	mouse_x_relative = -1*OFFSET_X + love.mouse.getX()
	mouse_y_relative = -1*OFFSET_Y + love.mouse.getY()
end

function updateChatLog(dt)
	timeSinceLastChatUpdate = timeSinceLastChatUpdate + dt
	
	if timeSinceLastChatUpdate > 5 then
		timeSinceLastChatUpdate = 0

		server:getText(chatLog[# chatLog].line_id)
	end 
end

--[[
      _                    
   __| |_ __ __ ___      __
  / _` | '__/ _` \ \ /\ / /
 | (_| | | | (_| |\ V  V / 
  \__,_|_|  \__,_| \_/\_/  
                           
]]

function drawLoadingScreen()
	for _key, _value in pairs(uiLoadingScreen) do
		graphicsHandler:draw(_value.mAssetID, _value.mX, _value.mY, nil, 1)
	end			
end

function drawGameBackground()
   	graphicsHandler:draw(graphicsHandler:asset("background"), love.graphics.getWidth()/2, love.graphics.getHeight()/2)
end

function drawGameObjects()
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
end

function drawGameRadialMenu()
	-- draw radialMenu
	for key, value in pairs(radialMenu) do
		love.graphics.rectangle("fill",(value.mX+0.5)*GFX_R_SZ - love.graphics.getFont():getWidth(value.mText)/2, (value.mY+0.5)*GFX_R_SZ, (value.mX+0.5)*GFX_R_SZ + love.graphics.getFont():getWidth(value.mText)/2-(value.mX+0.5)*GFX_R_SZ - love.graphics.getFont():getWidth(value.mText)/2, (value.mY+0.5)*GFX_R_SZ + love.graphics.getFont():getHeight(value.mText) - (value.mY+0.5)*GFX_R_SZ)
		love.graphics.print(value.mText, start_x+value.mX*GFX_R_SZ-love.graphics.getFont():getWidth(value.mText)/2, start_y+value.mY*GFX_R_SZ)			
	end
end

function drawGameUI()
	-- draw ui overlay objects
	for _key, _value in pairs(uiObjects) do
		graphicsHandler:draw(_value.mAssetID, _value.mX, _value.mY, nil, 1)
	end	

	local ui = tickMenu:getMenuAssets()

	for _key, _value in pairs(ui) do
		graphicsHandler:draw(_value.mAssetID, _value.mX, _value.mY, nil, 1)
	end

	-- temporary code to only display X lines of chat
	local linesToDraw = 8
	local logOffset = # chatLog - linesToDraw

	for _key, _value in pairs(chatLog) do
		if(_key > logOffset) then
			if (_value.pawn) and (_value.text) then
				love.graphics.print(_value.pawn.." : ".._value.text, 230, (-40-linesToDraw*20)  +love.graphics.getHeight()+(_key-logOffset)*20)
			end
		end
	end

	love.graphics.print("Turn ".. gamestate.turn .." ends in "..math.ceil(gamestate.updateIn/60).." minutes.", 5, 5)

end

--[[                      
  _ __ ___   ___  _   _ ___  ___ 
 | '_ ` _ \ / _ \| | | / __|/ _ \
 | | | | | | (_) | |_| \__ \  __/
 |_| |_| |_|\___/ \__,_|___/\___|
                                 
]]
function mousePressedGame(x, y, button)
	-- Checks which button was pressed.
	if button == "l" then
		local state_changed = false
		
		--last = "left pressed"		
		if(STATE == STATE_IDLE and not state_changed) then								
			local clicked_x = math.floor(mouse_x_relative / GFX_R_SZ)
			local clicked_y = math.floor(mouse_y_relative / GFX_R_SZ)
			
			grid = buildRadial(clicked_x, clicked_y)

			if grid then

				print("Switching to radial")
				radialMenu = grid

				--	if we did, set state to radial with ego radial
				STATE = STATE_RADIAL
								
				state_changed = true
			else
				-- check if we clicked a different square
				-- if we did, set state to radial with room radial
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
			
			print("(STATE == STATE_RADIAL and not state_changed)")
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

function mouseReleasedGame(x, y, button)
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

		--[[
		GFX_R_SZ = GFX_R_SZ + 6
		GFX_D_SZ = GFX_D_SZ + 2
		OFFSET_CHANGE = OFFSET_CHANGE + 6
		]]
	
	elseif button == "wd" then
		--last = "scrollwheel down released"
		--[[
		GFX_R_SZ = GFX_R_SZ - 6
		GFX_D_SZ = GFX_D_SZ - 2
		OFFSET_CHANGE = OFFSET_CHANGE - 6
		]]
	end
end


--[[
  _               _                         _ 
 | | __ ___ _   _| |__   ___   __ _ _ __ __| |
 | |/ // _ \ | | | '_ \ / _ \ / _` | '__/ _` |
 |   <|  __/ |_| | |_) | (_) | (_| | | | (_| |
 |_|\_\\___|\__, |_.__/ \___/ \__,_|_|  \__,_|
            |___/                             
]]
function gameKeyPressed(key, code)

	-- For specific game states, should be filtered based on that.

	--[[
	if key == "kp+" then
				GFX_R_SZ = GFX_R_SZ + 6
				GFX_D_SZ = GFX_D_SZ + 2
				OFFSET_CHANGE = OFFSET_CHANGE + 6
			elseif key == "kp-" then
				GFX_R_SZ = GFX_R_SZ - 6
				GFX_D_SZ = GFX_D_SZ - 2
				OFFSET_CHANGE = OFFSET_CHANGE - 6
			end		
	]]
	if key == "return" then
		gameSendChatBox()
	end

	if key == "a" then
		print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
		print ("n"..json.encode(gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[1]))
		print ("w"..json.encode(gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[2]))
		print ("s"..json.encode(gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[3]))
		print ("e"..json.encode(gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[4]))
		print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
	end

	-- For specific game states, should be filtered based on that.
	if key == "up" and canIMoveThisWay(0, -1) then
		addMove(0,-1)
	elseif key == "down" and canIMoveThisWay(0, 1) then		
		addMove(0,1)
	elseif key == "right" and canIMoveThisWay(1, 0) then
		addMove(1,0)
	elseif key == "left" and canIMoveThisWay(-1, 0) then
		addMove(-1,0)
	end			


end



--[[
   __ _  __ _ _ __ ___   ___ 
  / _` |/ _` | '_ ` _ \ / _ \
 | (_| | (_| | | | | | |  __/
  \__, |\__,_|_| |_| |_|\___|
  |___/                        

]]

function canIMoveThisWay(xMod, yMod)

	-- not 120
--1 north
--2 west
--3 south
--4 east

	if(xMod < 0) and not (gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[2] == "120") then
		return true
	end

	if(xMod > 0) and not (gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[4] == "120") then
		return true
	end


	if(yMod < 0) and not (gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[1] == "120") then
		return true
	end

	if(yMod > 0) and not (gamestate.ship.map[tostring(gamestate.virtualPawn.x)][tostring(gamestate.virtualPawn.y)].access[3] == "120") then
		return true
	end

	return false

end

function gameSendChatBox()
	if not (chatbox.text == "") then
		server:addText(chatbox.text)
		server:getText(chatLog[# chatLog].line_id)

		chatbox.text = ""	
	end
end

function addMove( xMod, yMod )
	GAMESTATE_NEEDS_UPDATING = true

	pawnObjects[PAWNOBJECTS_VIRTUALPAWN]:addMove(xMod, yMod)

	server:addAction(MenuObject:new(nil, nil, nil, "4", gamestate.virtualPawn.x+xMod ..","..gamestate.virtualPawn.y+yMod))

	gamestate.virtualPawn.x = gamestate.virtualPawn.x+xMod 
	gamestate.virtualPawn.y = gamestate.virtualPawn.y+yMod 
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
