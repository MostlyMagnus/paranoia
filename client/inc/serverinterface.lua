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

	mServer = "";
	--mServer = "http://192.168.1.248/";
	--mServer = "http://83.191.71.93/";
	--mServer = "http://localhost:3000/";

	mSession = "";

	mMessages = {};
	mTasks = {};

	mWorker = -1;

	mState = 0;
}

function ServerInterface:__init()
end

function ServerInterface:setHost(host)
	self.mServer = host
end

function ServerInterface:start()
	print("Starting network thread...")
	self.mMainThreadId = task.id()
	self.mWorker = task.create("inc/thread.lua", {task.id(), self.mServer, "1"}) -- Parameter 1 is gamestate id
end


function ServerInterface:tasksPendingAffectingGamestate()
	local tasksPending = false

	for key, value in pairs(self.mTasks) do
		if(value.type == "add action") then
			tasksPending = true
		end
	end

	return tasksPending	
end

function ServerInterface:login(username, password)

	local userInfo = {}

	userInfo["username"] = username
	userInfo["password"] = password

	local task = {}

	task["type"] = "login"
	task["parameters"] = userInfo

	self:_addTask(task)
end

function ServerInterface:getLogs(action)
	local task = {}

	task["type"] = "get logs"
	task["parameters"] = action

	self:_addTask(task)
end

function ServerInterface:addText(action)
	local task = {}

	task["type"] = "add text"
	task["parameters"] = action

	self:_addTask(task)
end

function ServerInterface:getText(action)
	local task = {}

	task["type"] = "get text"
	task["parameters"] = action

	self:_addTask(task)
end

function ServerInterface:addAction(action)
	local task = {}

	task["type"] = "add action"
	task["parameters"] = action

	self:_addTask(task)
end

function ServerInterface:removeAction()
	local task = {}

	task["type"] = "remove action"

	self:_addTask(task)
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
		if(self.mTasks[# self.mTasks]["type"] == "get gamestate") and not (self.mTasks[1]["type"] == "get gamestate") then				
			if(task["type"] == "get gamestate") then
				return 0		
			else

				table.insert(self.mTasks, # self.mTasks, task)

				print("["..task["type"].."] Task added at position "..(# self.mTasks-1).." in queue.")

				return 1			
			end
		end	
	end

	table.insert(self.mTasks, task)

	print("["..task["type"].."] Task added at position "..(# self.mTasks).." in queue.")
end

function ServerInterface:update()
--print (# self.mTasks)
	if(# self.mTasks > 0) then
		-- do we have a task running?
		if(self.mWorker == -1) then
		else
		--print("Have worker.")
			if(task.isrunning(self.mWorker)) then

				if (self.mState == SERVER_IDLE) then
					-- we're idle, but there are tasks to be done.
					task.post(self.mWorker, json.encode(self.mTasks[1]), 1)

					print("["..self.mTasks[1].type.."] Thread running with ".. # self.mTasks .." tasks in queue.")
					
					--print(json.encode(self.mTasks[1]))

					self.mState = SERVER_WAITING
				elseif (self.mState == SERVER_WAITING) then

					-- waiting to receive the result of the current task.
					local messageFromThread, flag, returnCode = task.receive(0)

					if not(messageFromThread == nil) then
						print("["..self.mTasks[1].type.."] Result received.")

						if(flag == 1) then
							local message = {}

							message["type"] = self.mTasks[1].type
							message["data"] = messageFromThread

							table.insert(self.mMessages, message)
						end

						if (flag >= 0) then
							print ("["..self.mTasks[1].type.."] Completed. "..(# self.mTasks -1).." task(s) left to do.")
							table.remove(self.mTasks, 1)
						end


						self.mState = SERVER_IDLE
					end
				end
			end
		end
	end
end
