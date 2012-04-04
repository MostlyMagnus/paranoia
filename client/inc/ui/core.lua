--[[
Copyright (c) 2012 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

-- state
local context = {maxid = 0}
local draw_items = {n = 0}
local NO_WIDGET = function()end

local function generateID()
	context.maxid = context.maxid + 1
	return context.maxid
end

local function setHot(id) context.hot = id end
local function isHot(id)  return context.hot == id end

local function setActive(id) context.active = id end
local function isActive(id)  return context.active == id end

local function setKeyFocus(id) context.keyfocus = id end
local function hasKeyFocus(id) return context.keyfocus == id end

local function disableKeyFocus() return setKeyFocus{} end
local function clearKeyFocus() return setKeyFocus(nil) end

-- input
local mouse = {x = 0, y = 0, down = false}
local keyboard = {key = nil, code = -1}
keyboard.cycle = {
	-- binding = {key = key, modifier1, modifier2, ...} XXX: modifiers are OR-ed!
	prev = {key = 'tab', 'lshift', 'rshift'},
	next = {key = 'tab'},
}

function mouse.updateState(id, widgetHit, ...)
	if widgetHit(mouse.x, mouse.y, ...) then
		setHot(id)
		if not context.active and mouse.down then
			setActive(id)
		end
	end
end

function mouse.releasedOn(id)
	return not mouse.down and isHot(id) and isActive(id)
end

function keyboard.pressed(key, code)
	keyboard.key = key
	keyboard.code = code
end

function keyboard.tryGrab(id)
	if not context.keyfocus then
		setKeyFocus(id)
	end
end

function keyboard.isBindingDown(bind)
	local modifiersDown = #bind == 0 or love.keyboard.isDown(unpack(bind))
	return keyboard.key == bind.key and modifiersDown
end

local function makeCyclable(id)
	keyboard.tryGrab(id)
	if hasKeyFocus(id) then
		if keyboard.isBindingDown(keyboard.cycle.prev) then
			setKeyFocus(context.lastwidget)
			keyboard.key = nil
		elseif keyboard.isBindingDown(keyboard.cycle.next) then
			setKeyFocus(nil)
			keyboard.key = nil
		end
	end
	context.lastwidget = id
end

-- helper functions
local function strictAnd(...)
	local n = select("#", ...)
	local ret = true
	for i = 1,n do ret = select(i, ...) and ret end
	return ret
end

local function strictOr(...)
	local n = select("#", ...)
	local ret = false
	for i = 1,n do ret = select(i, ...) or ret end
	return ret
end

-- allow packed nil
local function save_pack(...)
	return {n = select('#', ...), ...}
end

local function save_unpack(t, i)
	i = i or 1
	if i >= t.n then return t[i] end
	return t[i], save_unpack(t, i+1)
end

local function registerDraw(id, f, ...)
	assert(type(f) == 'function' or (getmetatable(f) or {}).__call,
	       'Drawing function is not a callable type!')

	local state = 'normal'
	if isHot(id) or hasKeyFocus(id) then
		state = isActive(id) and 'active' or 'hot'
	end
	local rest = save_pack(...)
	draw_items.n = draw_items.n + 1
	draw_items[draw_items.n] = function() f(state, save_unpack(rest)) end
end

-- actually update-and-draw
local function draw()
	-- close frame state
	if not mouse.down then -- released
		setActive(nil)
	elseif not context.active then -- clicked outside
		setActive(NO_WIDGET)
	end

	for i = 1,draw_items.n do draw_items[i]() end

	-- prepare for next frame
	draw_items.n = 0
	context.maxid = 0

	-- update mouse status
	setHot(nil)
	mouse.x, mouse.y = love.mouse.getPosition()
	mouse.down = love.mouse.isDown('l')

	keyboard.key, keyboard.code = nil, -1
end

return {
	mouse           = mouse,
	keyboard        = keyboard,

	generateID      = generateID,
	setHot          = setHot,
	setActive       = setActive,
	setKeyFocus     = setKeyFocus,
	isHot           = isHot,
	isActive        = isActive,
	hasKeyFocus     = hasKeyFocus,

	disableKeyFocus = disableKeyFocus,
	enableKeyFocus  = clearKeyFocus,
	clearKeyFocus   = clearKeyFocus,
	makeCyclable    = makeCyclable,

	style           = require((...):match("(.-)[^%.]+$") .. '.style-default'),
	color           = color,
	registerDraw    = registerDraw,
	draw            = draw,

	strictAnd       = strictAnd,
	strictOr        = strictOr,
	save_pack       = save_pack,
	save_unpack     = save_unpack,
}
