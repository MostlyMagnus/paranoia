-- 32 lines of goodness - OO
assert(require('lib/32log'))

print(require('task'))

THREAD_ADD_ACTION = 4

class "ActionQueue" {	
	mThreads = {};
	mMainThreadID = nil;
	mNetworkThread = nil;
}

function ActionQueue:__init(mainThreadID, networkThread)
	self.mMainThreadID		= mainThreadID
	self.mNetworkThread 	= networkThread	
end

function ActionQueue:add(message)
	_thread_post = {}

	_thread_post["message"] 	= message	
	_thread_post["sent"] 		= false
	_thread_post["received"] 	= false

	table.insert(self.mThreads, _thread_post)

	--return _unique_id	
end

function ActionQueue:update(messageFromThread, flags, returnCode)
	if(# self.mThreads > 0) then
		
		if not (self.mThreads[1]["received"]) then
			
			if not (self.mThreads[1]["sent"]) then
				task.post(self.networkThread,self.mThreads[1]["message"], THREAD_ADD_ACTION)

				--self.mThreads[1]["sent"] = true
			else
				if not(self.mThreads[1]["received"]) then
					--local messageFromThread, flags, returnCode = task.receive(0)

					if(flags == THREAD_ADD_ACTION) then
						self.mThreads[1]["message"] = messageFromThread						
						self.mThreads[1]["received"] = true
					end
				end			
			end


		else
			table.remove(self.mThreads, 1)
		end
	end	
	
end

function ActionQueue:empty()
	if (#self.mThreads > 0) then return false else return true end
end