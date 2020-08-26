local function cc(t)
	local cloned = {}
	for i,v in pairs(t) do
		if type(v) == "table" then
			cloned[i] = cc(v)
		else
			cloned[i] = v
		end
	end
	setmetatable(cloned, getmetatable(self))
	return cloned
end

class = {}

function class:new(tab)
	local newClass = {}
	local inheritClass = cc(tab)
	local inheritMetatable = {}
	for i,v in pairs(inheritClass) do
		if tostring(i):sub(1,2) == "__" then
			inheritMetatable[i] = v
		else
			newClass[i] = v
		end
	end
	setmetatable(newClass, inheritMetatable)
	return newClass
end


function class:methodsOnly(t)
	local mt = {}
	for i,v in pairs(t) do
		if tostring(i):sub(1,2) == "__" then
			mt[i] = v
		end
	end

	return mt
end
