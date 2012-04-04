-- 32 lines of goodness - OO
assert(require('lib/32log'))

-- JSON encode/decode
print(require('../lib/json'))

-- curl for http reqs
print(require('curl'))

-- thread lib
print(require('task'))

SERVER_IDLE = 0
SERVER_WAITING = 1

class "ServerInterface" {
	mMainThreadId	= nil;

	mServer = "http://192.168.1.248/";
	--mServer = "http://83.191.71.93/";
	--mServer = "http://localhost:3000/";

	mSession = "";

	mMessages = {};
	mTasks = {};

	mWorker = -1;

	mState = 0;
}

function ServerInterface:__init(server)
end

function ServerInterface:start()
	print("Starting network thread...")
	self.mMainThreadId = task.id()
	self.mWorker = task.create("inc/thread.lua", {task.id(), self.mServer, "1"}) -- Parameter 1 is gamestate id
end




function ServerInterface:login(username, password)

	local userInfo = {}

	userInfo["username"] = username
	userInfo["password"] = password

	local task = {}

	task["type"] = "login"
	task["parameters"] = userInfo

	self:_addTask(task)
	--self:getGamestate()

end

function ServerInterface:addAction(action)
	local task = {}

	task["type"] = "add action"
	task["parameters"] = action

	self:_addTask(task)
	self:getGamestate()
end

function ServerInterface:getGamestate()
	local task = {}

	task["type"] = "get gamestate"

	self:_addTask(task)
end

function ServerInterface:getMessage(filter)
	for key, value in pairs(self.mMessages) do
		if(value["type"] == filter) then
			table.remove(self.mMessages, key)

			return value["data"]
		end
	end

	return nil
end

function ServerInterface:_addTask(task)
	-- behaviour:
	-- 	get gamestate should always be last in the task list, and there should only be one or none.

	if(# self.mTasks > 0) then
		if(self.mTasks[# self.mTasks]["type"] == "get gamestate") then				
			if(task["type"] == "get gamestate") then
				return 0		
			else
				table.insert(self.mTasks, # self.mTasks, task)

				return 1			
			end
		end	
	end

	table.insert(self.mTasks, task)
end

function ServerInterface:update()
--print (# self.mTasks)
	if(# self.mTasks > 0) then
		-- do we have a task running?
		if(self.mWorker == -1) then
		else
		--print("Have worker.")
			if(task.isrunning(self.mWorker)) then
				print ("Task running with "..# self.mTasks.." task(s) left to do.")

				if (self.mState == SERVER_IDLE) then
					-- we're idle, but there are tasks to be done.
					task.post(self.mWorker, json.encode(self.mTasks[1]), 1)
					
					print(json.encode(self.mTasks[1]))

					self.mState = SERVER_WAITING
				elseif (self.mState == SERVER_WAITING) then

					-- waiting to receive the result of the current task.
					local messageFromThread, flag, returnCode = task.receive(0)

					if not(messageFromThread == nil) then
						print("We got a message from the thread.")

						if(self.mTasks[1].type == "login") then
							if(flag == 1) then
								print("Login returned a message.")

								local message = {}

								message["type"] = "login"
								message["data"] = messageFromThread

								table.insert(self.mMessages, message)
							end
						end

						if(self.mTasks[1].type == "get gamestate") then
							if(flag == 1) then
								print("Received gamestate ok.")

								local message = {}

								message["type"] = "get gamestate"
								message["data"] = messageFromThread

								table.insert(self.mMessages, message)
							end
						end

						if(self.mTasks[1].type == "add action") then
							if(flag == 1) then
								print("Action added ok.")
							end							
						end						

						if (flag >= 0) then
							table.remove(self.mTasks, 1)
						end

						self.mState = SERVER_IDLE
					end
				end
			end
		end
	end
end
