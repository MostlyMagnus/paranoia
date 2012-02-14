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
}

function MenuHandler:__init(xTop, yTop)
	self.mXTop = xTop
	self.mYTop = yTop
end

function addObject()
	-- body
end