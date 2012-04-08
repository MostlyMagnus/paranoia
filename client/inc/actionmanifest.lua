-- 32 lines of goodness - OO
assert(require('lib/32log'))

class "ActionManifest" {	
	mManifest = {};
}

function ActionManifest:__init()
--[[
  A_NIL     = nil
  A_USE     = 1
  A_KILL    = 2
  A_REPAIR  = 3
  A_MOVE    = 4
  A_INITVOTE= 5
  A_VOTE    = 6
  A_STATUS  = 7
  ]]
  
  table.insert(self.mManifest, {action_id = nil, 	action_code = "A_NIL",       action_name = "Nil" })
  table.insert(self.mManifest, {action_id = 1, 		action_code = "A_USE",       action_name = "Use" })
  table.insert(self.mManifest, {action_id = 2, 		action_code = "A_KILL",      action_name = "Kill"	})
  table.insert(self.mManifest, {action_id = 3, 		action_code = "A_REPAIR",    action_name = "Tinker"	})
  table.insert(self.mManifest, {action_id = 4, 		action_code = "A_MOVE",      action_name = "Move"	})
  table.insert(self.mManifest, {action_id = 5, 		action_code = "A_INITVOTE",  action_name = "Initiate vote" })
  table.insert(self.mManifest, {action_id = 6, 		action_code = "A_VOTE",      action_name = "Cast vote" })
  table.insert(self.mManifest, {action_id = 7, 		action_code = "A_STATUS",    action_name = "Check ship status" })
end

function ActionManifest:getString(actiontype)
	for key, value in pairs(self.mManifest) do
		if value.action_id == actiontype then
			return value.action_name
		end
	end

	return "Unknown action"
end

function ActionManifest:getActionID(actioncode)
  for key, value in pairs(self.mManifest) do
    if(value.action_code == actioncode) then
      return value.action_id
    end
  end
end