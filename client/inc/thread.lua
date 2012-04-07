
print(require('../inc/datainterface'))

-- JSON encode/decode
print(require('../lib/json'))

-- Ship data symbols
print(require('../inc/symbols'))

-- curl for http reqs
print(require('curl'))

-- LuaTask for threading
print(require('task'))

	
local main_id = arg[1]

global_server = arg[2]
global_gamestate_id = arg[3]

while true do
	local messageFromMain, flags, returnCode = task.receive(-1)
	
	if not (messageFromMain == nil) then
		local fromMain = json.decode(messageFromMain)

		if(fromMain["type"] == "login") then
			session = log_in(fromMain["parameters"]["username"], fromMain["parameters"]["password"])

			if(session) then
				-- post true back
				task.post(main_id, "login_ok", 1)
			else 
				task.post(main_id, "login_failed", 1)
			end
		end

		if(fromMain["type"] == "add action") then
			if(session) then
				add_action(session, fromMain["parameters"]["mActionType"], fromMain["parameters"]["mParams"])

				task.post(main_id, '', THREAD_ADD_ACTION)
			end
		end

		if(fromMain["type"] == "remove action") then
			if(session) then
				remove_action(session)

				task.post(main_id, '', 1)
			end
		end


		if(fromMain["type"] == "get gamestate") then
			if(session) then
				local gamestate = get(session, global_server..'gamestates/'..global_gamestate_id..'/json_gamestate')
				task.post(main_id, gamestate, 1)
			end
		end

		if(fromMain["type"] == "add text") then
			if(session) then

				print(add_text(session, fromMain["parameters"]))

				task.post(main_id, "add text", 1)
			end
		end

		if(fromMain["type"] == "get text") then
			if(session) then

				local text = get_text(session, fromMain["parameters"])

				task.post(main_id, text, 1)
			end
		end

		if(fromMain["type"] == "get logs") then
			if(session) then

				local text = get_logs(session, fromMain["parameters"])

				task.post(main_id, text, 1)
			end
		end
		
	end
end