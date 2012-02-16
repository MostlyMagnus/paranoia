assert(require('inc/menuhandler'))

assert(require('inc/screenobject'))

class "TickMenu" : extends (MenuHandler) {
	
}

-- function TickMenu:__init(frameID, openID, openHoverID, vertSwoop, HoriSwoop)
-- 	self.super.__init(self)
-- end

function TickMenu:removeAction(id)
	-- body
end

-- overloaded function that'll return some special sort of setup for
-- the tickmenu. For now, just mimic the base one.
-- function TickMenu:getButtons()
-- 	local formattedButtons = { }

-- 	for key, value in pairs(self.buttons) do
-- 		table.insert(formattedButtons, ScreenObject:new(value.getAssetID(), value.mX, value.mY))
-- 	end

-- 	return formattedButtons
-- end

function TickMenu:swapState()
	print "state swapped"
end