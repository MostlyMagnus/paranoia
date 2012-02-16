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
	mWidth = 0;
	mHeight = 0;

	mOffsetX = 0;
	mOffsetY = 0;

	mVerticalSwoop = false;
	mHorizontalSwoop = false;

	mEdge = "";
}

function MenuHandler:__init(frameID, vertSwoop, HoriSwoop, x, y, w, h)
	self.mAssetID_Frame = frameID

	self.mVerticalSwoop = vertSwoop
	self.mHorizontalSwoop = HoriSwoop

	self.mX = x
	self.mY = y

	self.mWidth = w
	self.mHeight = h
end

function MenuHandler:update()
	self.mOffsetX = self.mX - self.mWidth/2
	self.mOffsetY = self.mY - self.mHeight/2

	if self.buttons then
		for key, value in pairs (self.buttons) do
			if 	love.mouse.getX() > value.mX+self.mOffsetX - value:getHalfWidth()
		 	and love.mouse.getX() < value.mX+self.mOffsetX + value:getHalfWidth() 
			and	love.mouse.getY() > self.mOffsetY+value.mY - value:getHalfHeight()
			and love.mouse.getY() < self.mOffsetY+value.mY + value:getHalfHeight() then
				value.mHovering = true
			else
				value.mHovering = false
			end
		end	
	end
end

function MenuHandler:clickCheck( )
	local clicked = false
	if self.buttons then
		for key, value in pairs (self.buttons) do
			if 	love.mouse.getX() > value.mX+self.mOffsetX - value:getHalfWidth()
		 	and love.mouse.getX() < value.mX+self.mOffsetX + value:getHalfWidth() 
			and	love.mouse.getY() > self.mOffsetY+value.mY - value:getHalfHeight()
			and love.mouse.getY() < self.mOffsetY+value.mY + value:getHalfHeight() then
				print (value:clicked())

				clicked = true
			end
		end	
	end

	return clicked
end

function MenuHandler:addButton(id, hover_id,  x, y, metadata, callback)
	table.insert(self.buttons, Button:new(id, hover_id, x, y, metadata, callback))
end

function MenuHandler:getMenuAssets()
	local formattedAssets = { }
	
	table.insert(formattedAssets, ScreenObject:new(self.mX, self.mY, self.mAssetID_Frame))

	for key, value in pairs(self.buttons) do
		table.insert(formattedAssets, ScreenObject:new(value.mX+self.mOffsetX, value.mY+self.mOffsetY, value:getAssetID()))
	end

	return formattedAssets
end

function MenuHandler:clear()
	self.buttons = {}
end

