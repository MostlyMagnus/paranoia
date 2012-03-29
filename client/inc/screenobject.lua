-- base class for objects to  be rendered to the screen
-- mx, my
-- asset_id

class "ScreenObject" {	
	mX = 0;
	mY = 0;
	mAssetID = 0;
}

function ScreenObject:__init(x, y, assetID)
	self.mX = x
	self.mY = y
	self.mAssetID = assetID
end

class "PawnObject" {
	mX = 0;
	mY = 0;
	mAssetID = 0;
	mText = "";
	mMoves = {};
	mPawnID = 0;	
}

function PawnObject:__init( x, y, assetID, pawnID, hoverText )
	self.mPawnID = pawnID	
	self.mX = x
	self.mY = y
	self.mAssetID = assetID
	if (hoverText) then 
		self.mText = hoverText
	else
		self.mText = "default"	
	end
	--self.mText = hoverText
end

function PawnObject:addMove(xMod, yMod)
	local move = {}

	move["xMod"] = xMod
	move["yMod"] = yMod
	move["xMovedSoFar"] = 0
	move["yMovedSoFar"] = 0

	table.insert(self.mMoves, move)
end

function PawnObject:update(dt)
	local actionRemoved = false

	local mMoveSpeed = 2

	if(self.mMoves) then
		if (table.getn(self.mMoves)>0) then
			if not actionRemoved then
				if(self.mMoves[1].xMod > 0) then
					if(self.mMoves[1].xMovedSoFar < 1) then
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
					if(self.mMoves[1].xMovedSoFar > -1) then
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
					if(self.mMoves[1].yMovedSoFar < 1) then
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
					if(self.mMoves[1].yMovedSoFar > -1) then
						self.mY = self.mY + -mMoveSpeed*dt
						self.mMoves[1].yMovedSoFar = self.mMoves[1].yMovedSoFar + -mMoveSpeed*dt
					else
						table.remove(self.mMoves, 1)
						actionRemoved = true
					end
				end
			end
			
		end
	else
		-- no moves left
	end

end