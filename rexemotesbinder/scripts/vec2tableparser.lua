include "vec2"

function vec2tableparser(t)
	local newTable = {}
	
	for i,v in pairs(t) do
		local t = type(v)
		if t == "table" and #t == 2 and type(t[1]) == "number" and type(t[2]) == "number" then
			newTable[i] = vec2(v)
		elseif t == "table" then
			newTable[i] = vec2tableparser(v)
		else
			newTable[i] = v
		end
	end

	local mt = getmetatable(t)
	if mt then
		setmetatable(newTable, mt)
	end

	return newTable
end