-- 32 lines of goodness - OO
assert(require('lib/32log'))

-- MenuObject class
assert(require('inc/menuobject'))

class "MenuHandler" {	
	menuObjects = { }

	-- Should be host to a whole slew of asset ids
	mAssetID_Frame = nil
	mAssetID_Open = nil
	mAssetID_Open_Hover = nil

	mMenuOpen = false

	mXTop = nil
	mYTop = nil

	mOffsetX = 0
	mOffsetY = 0

	mVerticalSwoop = false
	mHorizontalSwoop = false

	mEdge = ""
}

function MenuHandler:__init(frameID, openID, openHoverID, vertSwoop, HoriSwoop)
	self.mAssetID_Frame = frameID
	self.mAssetID_Open = openID
	self.mAssetID_Open_Hover = openHoverID

	mVerticalSwoop = vertSwoop
	mHorizontalSwoop = HoriSwoop
end

function addObject()
	-- body
end

class TickMenu : extends MenuHandler {
	
}

function TickMenu::__init(frameID, openID, openHoverID, vertSwoop, HoriSwoop)
	self.super.__init(self)
end