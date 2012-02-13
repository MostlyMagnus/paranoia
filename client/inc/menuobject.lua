class "MenuObject" {	
	mX = 0;
	mY = 0;
	mText = "";
	mActionType = 0;
	mParams = "";
}

function MenuObject:__init(text, x, y, actiontype, params)
	self.mX = x
	self.mY = y
	self.mText = text
	self.mActionType = actiontype
	self.mParams = params
end
