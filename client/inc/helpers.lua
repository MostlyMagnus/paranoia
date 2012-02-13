function split(str, symbol)
	local result = {}
	local current = ""
	for c in str:gmatch"." do
		if c == symbol then
			table.insert(result, current)
			current = ""
		elseif c == " " or c == "\n" then
			--nop
		else
			current = current .. c
		end
	end
	table.insert(result, current)
	return result
end

function char_at(str, index)
	count = 1
	for c in str:gmatch"." do
		if  count == index then
			return c
		else 
			count = count + 1
		end
	end
	assert(false, "we should never reached this. " .. str .. " : " .. index)
end