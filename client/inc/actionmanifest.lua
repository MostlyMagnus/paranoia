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
  
  table.insert(self.mManifest, {action_id = nil, 	action_name = "Nil"					})
  table.insert(self.mManifest, {action_id = 1, 		action_name = "Use"					})
  table.insert(self.mManifest, {action_id = 2, 		action_name = "Kill"				})
  table.insert(self.mManifest, {action_id = 3, 		action_name = "Tinker"				})
  table.insert(self.mManifest, {action_id = 4, 		action_name = "Move"				})
  table.insert(self.mManifest, {action_id = 5, 		action_name = "Initiate vote"		})
  table.insert(self.mManifest, {action_id = 6, 		action_name = "Cast vote"			})
  table.insert(self.mManifest, {action_id = 7, 		action_name = "Check ship status"	})
end

function ActionManifest:getString(actiontype)
	for key, value in pairs(self.mManifest) do
		if value.action_id == actiontype then
			return value.action_name
		end
	end

	return "Unknown action"
end