-- 32 lines of goodness - OO
assert(require('lib/32log'))

-- MenuObject class
assert(require('inc/menuobject'))

assert(require('inc/button'))

class "MenuHandler" {	
	buttons = { };

	-- Should be host to a whole slew of asset ids
	mAssetID_Frame = nil;

	mMenuOpen = false;

	mX = 0;
	mY = 0;
	mXTop = 0;
	mYTop = 0;

	mOffsetX = 0;
	mOffsetY = 0;

	mVerticalSwoop = false;
	mHorizontalSwoop = false;

	mEdge = "";
}

function MenuHandler:__init(frameID, vertSwoop, HoriSwoop, x, y)
	self.mAssetID_Frame = frameID

	self.mVerticalSwoop = vertSwoop
	self.mHorizontalSwoop = HoriSwoop

	self.mX = x
	self.mY = y
end

function MenuHandler:update()
	if buttons then
		for key, value in pairs (buttons) do
			if love.mouse.getX() > value.x - value.getHalfWidth() and love.mouse.getX() < value.x + value.getHalfWidth() then
				if love.mouse.getX() > value.x - value.getHalfHeight() and love.mouse.getX() < value.x + value.getHalfHeight() then
					value.mHovering = true
				end
			else
				value.mHovering = false
			end
		end	
	end
end

function MenuHandler:addButton(id, hover_id,  x, y, metadata, callback)
	table.insert(self.buttons, Button:new(id, hover_id, x, y, metadata, callback))
end

function MenuHandler:getMenuAssets()
	local formattedAssets = { }
	
	table.insert(formattedAssets, ScreenObject:new(self.mX, self.mY, self.mAssetID_Frame))

	for key, value in pairs(self.buttons) do
		-- topX, topY instead of self.mx, self.my
		table.insert(formattedAssets, ScreenObject:new(self.mXTop+value.mX, self.mYTop+value.mY, value:getAssetID()))
	end

	print (self.mAssetID_Frame)

	return formattedAssets
end


