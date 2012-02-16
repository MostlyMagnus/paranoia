class "Button" {
	mButtonID 		= nil;
	mButtonID_Hover = nil;
	mCallback 		= nil;
	mMetadata 		= nil;
	mX 				= nil;
	mY 				= nil;
	mW 				= 0;
	mH 				= 0;
	mHovering 		= false;
}

function Button:__init( id, hover_id,  x, y, w, h, metadata, callback )
	self.mButtonID = id
	self.mButtonID_Hover = hover_id	
	self.mCallback = callback
	self.mMetadata = metadata

	self.mX = x
	self.mY = y	
	self.mW = w
	self.mH = h
end

function Button:getAssetID()
	if self.mHovering then
		return self.mButtonID_Hover
	else
		return self.mButtonID
	end	
end

function Button:clicked()
	self.mCallback()
end

function Button:getHalfWidth() 
end

function Button:getHalfHeight()	
end