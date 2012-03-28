print(require('../inc/datainterface'))
-- JSON encode/decode
print(require('../lib/json'))

-- Ship data symbols
print(require('../inc/symbols'))

-- curl for http reqs
print(require('curl'))

print(require('task'))


-- thread symbols 
THREAD_LOGIN = 2
THREAD_GAMESTATE = 3
THREAD_ADD_ACTION = 4


global_server = "http://localhost:3000/"
global_gamestate_id = "1"
	
local main_id = arg[1]

while true do
	local messageFromMain, flags, returnCode = task.receive(-1)
	
	
	if(flags == THREAD_LOGIN) then
		userInfo = json.decode(messageFromMain)

		session = log_in(userInfo["login"], userInfo["password"])

		if(session) then
			-- post true back
			task.post(main_id, "login_ok", THREAD_LOGIN)
		end
	end

	-- if we're logged in
	if(flags == THREAD_GAMESTATE) then
		local gamestate = get(session, global_server..'gamestates/'..global_gamestate_id..'/json_gamestate')
		task.post(main_id, gamestate, THREAD_GAMESTATE)
	end

	if(flags == THREAD_ADD_ACTION) then
		add_action(session, json.decode(messageFromMain))

		task.post(main_id, '', THREAD_ADD_ACTION)
	end

end