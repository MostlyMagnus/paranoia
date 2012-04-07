-- curl for http reqs
assert(require('curl'))
	
-- This function will take a username and password and return a finished 
-- and logged in session for the rest of the client to use. If the login fails
-- it returns nil.
function log_in(username, password)
	session = curl.easy_init()
	
	session:setopt(curl.OPT_COOKIEFILE, "cookie.txt")
	session:setopt(curl.OPT_USERAGENT, "ParanoiaClient")
	session:setopt(curl.OPT_POSTFIELDS, "session[email]="..username.."&session[password]="..password)
	session:setopt(curl.OPT_URL, global_server..'sessions')
	
	local t = {}
	
	session:setopt(curl.OPT_WRITEFUNCTION, function (a, b)
		local s
		-- luacurl and Lua-cURL friendly
		if type(a) == "string" then s = a else s = b end
		table.insert(t, s)
		return #s
	end)
	
	assert(session:perform())
	
	local result = table.concat(t)
	
	-- if 0 was returned, login failed.
	if result == "0" then
		return nil
	else
		-- return the session so we can used it for the rest of this login
		return session
	end	
end

-- based on https://github.com/mkottman/wdm
-- always pass a session to the get function, since the server needs to make sure that
-- this user has the right to view this data.
function get(session, url)
	-- since we use the same session throughout the app, and we know that this function
	-- should only be GETs, set OPT_POST to false. 
	session:setopt(curl.OPT_POST, 0)
	
	-- set OPT_URL to the passed parameter url
	session:setopt(curl.OPT_URL,url)
	
	-- create a local table to store read data in
	local t = {}
	
	-- define the callback function
	-- WRITEFUNCTION is whats called when the app tries to write data to the
	-- app/os, ie, what it reads from the server. Counter intuitive.
	session:setopt(curl.OPT_WRITEFUNCTION, function (a, b)
		local s
		-- luacurl and Lua-cURL friendly
		if type(a) == "string" then s = a else s = b end
		table.insert(t, s)
		return #s
	end)
	
	-- perform the GET request
	assert(session:perform())
	
	return table.concat(t)	
end

function add_action(session, actionType, params)
	-- since we use the same session throughout the app, and we know that this function
	-- should only be GETs, set OPT_POST to false. 
	session:setopt(curl.OPT_POST, 0)
	
	local t = {}
	
	session:setopt(curl.OPT_WRITEFUNCTION, function (a, b)
		local s
		-- luacurl and Lua-cURL friendly
		if type(a) == "string" then s = a else s = b end
		table.insert(t, s)
		return #s
	end)
	
	local url = global_server.."gamestates/"..global_gamestate_id.."/add_action?type="..actionType.."&details="..params
	
	-- set OPT_URL to the passed parameter url
	session:setopt(curl.OPT_URL,url)
	assert(session:perform())
	
	if table.concat(t) == 1 then return true else return false end
end

function remove_action(session)
	-- since we use the same session throughout the app, and we know that this function
	-- should only be GETs, set OPT_POST to false. 
	session:setopt(curl.OPT_POST, 0)
	
	local t = {}
	
	session:setopt(curl.OPT_WRITEFUNCTION, function (a, b)
		local s
		-- luacurl and Lua-cURL friendly
		if type(a) == "string" then s = a else s = b end
		table.insert(t, s)
		return #s
	end)
	
	local url = global_server.."gamestates/"..global_gamestate_id.."/remove_action"
	
	-- set OPT_URL to the passed parameter url
	session:setopt(curl.OPT_URL,url)
	assert(session:perform())
	
	return 1
end

function add_text(session, params)
	-- since we use the same session throughout the app, and we know that this function
	-- should only be GETs, set OPT_POST to false. 
	session:setopt(curl.OPT_POST, 0)
	
	local t = {}
	
	session:setopt(curl.OPT_WRITEFUNCTION, function (a, b)
		local s
		-- luacurl and Lua-cURL friendly
		if type(a) == "string" then s = a else s = b end
		table.insert(t, s)
		return #s
	end)
	
	local url = global_server.."gamestates/"..global_gamestate_id.."/add_text?text="..curl.escape(params)
	
	-- set OPT_URL to the passed parameter url
	session:setopt(curl.OPT_URL,url)
	assert(session:perform())
	
	return table.concat(t) 
end

function get_text(session, params)
	-- since we use the same session throughout the app, and we know that this function
	-- should only be GETs, set OPT_POST to false. 
	session:setopt(curl.OPT_POST, 0)
	
	local t = {}
	
	session:setopt(curl.OPT_WRITEFUNCTION, function (a, b)
		local s
		-- luacurl and Lua-cURL friendly
		if type(a) == "string" then s = a else s = b end
		table.insert(t, s)
		return #s
	end)
	
	local url = global_server.."gamestates/"..global_gamestate_id.."/get_text?id_greater_than="..params
	
	-- set OPT_URL to the passed parameter url
	session:setopt(curl.OPT_URL,url)
	assert(session:perform())
	
	return table.concat(t) 
end

function get_logs(session, params)
	-- since we use the same session throughout the app, and we know that this function
	-- should only be GETs, set OPT_POST to false. 
	session:setopt(curl.OPT_POST, 0)
	
	local t = {}
	
	session:setopt(curl.OPT_WRITEFUNCTION, function (a, b)
		local s
		-- luacurl and Lua-cURL friendly
		if type(a) == "string" then s = a else s = b end
		table.insert(t, s)
		return #s
	end)
	
	local url = global_server.."gamestates/"..global_gamestate_id.."/get_logs?id_greater_than="..params
	
	-- set OPT_URL to the passed parameter url
	session:setopt(curl.OPT_URL,url)
	assert(session:perform())
	
	return table.concat(t) 
end