class "TextField" {
	mCallback 		= nil;
	mMetadata 		= nil;
	mX 				= nil;
	mY 				= nil;
	mW 				= 0;
	mH 				= 0;

	mName 			= "";
	mText			= "";
}

function TextField:__init(name, x, y, w, h, callback)
	self.mName		= name
	self.mCallback 	= callback
	
	self.mX = x
	self.mY = y	
	self.mW = w
	self.mH = h
end

function TextField:clicked() 
	self.mCallback()
end

function TextField:getHalfWidth() 
	return self.mW/2
end

function TextField:getHalfHeight()	
	return self.mH/2
end