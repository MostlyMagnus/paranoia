class "TextObject" {	
	mX = 0;
	mY = 0;
	mText = "";
	mBaseWidth = 0;
}

function TextObject:__init(text, x, y, baseW)
	self.mX = x
	self.mY = y
	self.mText = text
	mBaseWidth = baseW
end

function TextObject:draw()
end
