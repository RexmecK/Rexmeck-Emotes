include "vec2"

function table.merge(a, b)
	if type(a) ~= "table" then return b end

		for i,v in pairs(b) do
			if type(v) == "table" then
				a[i] = table.merge(a[i], v)
			else
				a[i] = b[i]
			end
		end

		local mt = getmetatable(b)
		if type(mt) == "table" then
			setmetatable(a, mt)
		end

	return a
end

function table.vmerge(a, b)
	if type(a) ~= "table" then return b end
		for i,v in pairs(b) do
			if type(v) == "table" then
				a[i] = table.vmerge(a[i], v)
				if type(a[i]) == "table" and #a[i] == 2 then
					a[i] = vec2(a[i])
				end
			else
				a[i] = b[i]
			end
		end
	return a
end

function table.copy(t)
	if type(t) ~= "table" then return t end
	local nt = {}
	for i,v in pairs(t) do
		if type(v) == "table" then
			nt[i] = table.copy(v)
		else
			nt[i] = v
		end
	end
	local mt = getmetatable(t)
	if type(mt) == "table" then
		setmetatable(nt, mt)
	end
	return nt
end