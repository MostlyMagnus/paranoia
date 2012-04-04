-- 32 lines of goodness - OO
assert(require('lib/32log'))

-- MenuObject class
assert(require('inc/menuobject'))

assert(require('inc/button'))

assert(require('inc/textfield'))

class "MenuHandler" {	
	mButtons = { };
	
	-- Should be host to a whole slew of asset ids
	mAssetID_Frame = nil;
		
	mMenuOpen = true;

	mWidth = 0;
	mHeight = 0;

	mOffsetX = 0;
	mOffsetY = 0;
	mX = 0;
	mY = 0;

	mVerticalSwoop = false;
	mHorizontalSwoop = false;

	mEdge = "";

	mMoves = {};	
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

function MenuHandler:update(dt)
	self.mOffsetX = self.mX - self.mWidth/2
	self.mOffsetY = self.mY - self.mHeight/2

	self:updateMoves(dt)

	if self.mButtons then
		for key, value in pairs (self.mButtons) do
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

	if self.mButtons then
		for key, value in pairs (self.mButtons) do
			if 	love.mouse.getX() > value.mX+self.mOffsetX - value:getHalfWidth()
		 	and love.mouse.getX() < value.mX+self.mOffsetX + value:getHalfWidth() 
			and	love.mouse.getY() > self.mOffsetY+value.mY - value:getHalfHeight()
			and love.mouse.getY() < self.mOffsetY+value.mY + value:getHalfHeight() then
				value:clicked()
				
				clicked = true
			end
		end	
	end

	return clicked
end

function MenuHandler:addButton(id, hover_id,  x, y, w, h, metadata, callback)
	table.insert(self.mButtons, Button:new(id, hover_id, x, y, w, h, metadata, callback))
end

function MenuHandler:getMenuAssets()
	local formattedAssets = { }
	
	table.insert(formattedAssets, ScreenObject:new(self.mX, self.mY, self.mAssetID_Frame))

	for key, value in pairs(self.mButtons) do
		table.insert(formattedAssets, ScreenObject:new(value.mX+self.mOffsetX, value.mY+self.mOffsetY, value:getAssetID()))
	end

	return formattedAssets
end

function MenuHandler:clear()
	self.mButtons = {}
	self.mTextfields = {}
end

function MenuHandler:swapState()	
	if(self.mMenuOpen) then
		self:addMove(-1, 0)
		self.mMenuOpen = false		
	elseif not (self.mMenuOpen) then
		self:addMove(1, 0)
		self.mMenuOpen = true		
	end
end

function MenuHandler:updateMoves(dt)
	local actionRemoved = false

	local mMoveSpeed = self.mWidth*8

	if(self.mMoves) then
		if (table.getn(self.mMoves)>0) then
			if not actionRemoved then
				if(self.mMoves[1].xMod > 0) then
					if(self.mMoves[1].xMovedSoFar < self.mWidth) then
						self.mX = self.mX + mMoveSpeed*dt
						self.mMoves[1].xMovedSoFar = self.mMoves[1].xMovedSoFar + mMoveSpeed*dt
					else
						table.remove(self.mMoves, 1)
						actionRemoved = true
					end
				end
			end
			if not actionRemoved then		 
				if(self.mMoves[1].xMod < 0) then
					if(self.mMoves[1].xMovedSoFar > -1*self.mWidth) then
						self.mX = self.mX + -mMoveSpeed*dt
						self.mMoves[1].xMovedSoFar = self.mMoves[1].xMovedSoFar + -mMoveSpeed*dt
					else
						table.remove(self.mMoves, 1)
						actionRemoved = true
					end
				end
			end
			if not actionRemoved then

				if(self.mMoves[1].yMod > 0) then
					if(self.mMoves[1].yMovedSoFar < self.mHeight) then
						self.mY = self.mY + mMoveSpeed*dt
						self.mMoves[1].yMovedSoFar = self.mMoves[1].yMovedSoFar + mMoveSpeed*dt
					else
						table.remove(self.mMoves, 1)
						actionRemoved = true
					end
				end
			end
			if not actionRemoved then
				if(self.mMoves[1].yMod < 0) then
					if(self.mMoves[1].yMovedSoFar > -1*self.mHeight) then
						self.mY = self.mY + -mMoveSpeed*dt
						self.mMoves[1].yMovedSoFar = self.mMoves[1].yMovedSoFar + -mMoveSpeed*dt
					else
						table.remove(self.mMoves, 1)
						actionRemoved = true
					end
				end
			end
		else
			-- no moves left, so we'll make sure the menu is at the proper place.
			if(self.mMenuOpen)then
				self.mX = self.mWidth/2
			else
				self.mX = -1*self.mWidth/2
			end			
		end
	else
		-- nil moves
	end
end

function MenuHandler:addMove(xMod, yMod)
	local move = {}

	move["xMod"] = xMod
	move["yMod"] = yMod
	move["xMovedSoFar"] = 0
	move["yMovedSoFar"] = 0

	table.insert(self.mMoves, move)
end