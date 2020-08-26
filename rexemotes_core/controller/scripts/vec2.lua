include "class"

local vec2OP = {}

function vec2OP.angle(self)
	local angle = math.atan(self[1], self[2])
	if angle < 0 then angle = angle + 2 * math.pi end
	return angle
end

function vec2OP.clamp(self, min, max)
	local v = {0,0}
	if self[1] < min[1] then
		v[1] = min[1]
	elseif self[1] > max[1] then
		v[1] = max[1]
	else
		v[1] = self[1]
	end
	if self[2] < min[2] then
		v[2] = min[2]
	elseif self[2] > max[2] then
		v[2] = max[2]
	else
		v[2] = self[2]
	end
	return vec2(v)
end

function vec2OP.rotate(self, angle)
	local sinAngle = math.sin(angle)
	local cosAngle = math.cos(angle)

	return vec2(
		{
			self[1] * cosAngle - self[2] * sinAngle,
			self[1] * sinAngle + self[2] * cosAngle,
		}
	)
end

function vec2OP.lerp(self, b, ratio)
	if type(b) == "number" then b = vec2(b) end
	return self + (b - self) * ratio
end


local v2 = {}
v2[1] = 0
v2[2] = 0

function v2:__index(a)
	if type(a) == "string" then
		if a == "x" then 
			return self[1]
		elseif a == "y" then 
			return self[2]
		elseif vec2OP[a] then
			return function(...) return vec2OP[a](...) end 
		end
	end
end

function v2:__newindex(a, b)
	local t = type(a)
	if t == "number" then
		if a == 1 then 
			self[1] = b
		elseif a == 2 then 
			self[2] = b
		end
	elseif t == "string" then
		if a == "x" then 
			self[1] = b
		elseif a == "y" then 
			self[2] = b
		end
	end
	return self
end

--basic operators

function v2:__unm()
	return vec2(-self[1], -self[2])
end

function v2:__add(b)
	if type(b) == "number" then 
		return vec2(self[1] + b, self[2] + b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] + b[1], self[2] + b[2])
	end
end

function v2:__sub(b)
	if type(b) == "number" then 
		return vec2(self[1] - b, self[2] - b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] - b[1], self[2] - b[2])
	end
end

function v2:__mul(b)
	if type(b) == "number" then 
		return vec2(self[1] * b, self[2] * b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] * b[1], self[2] * b[2])
	end
end

function v2:__div(b)
	if type(b) == "number" then 
		return vec2(self[1] / b, self[2] / b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] / b[1], self[2] / b[2])
	end
end

function v2:__idiv(b)
	if type(b) == "number" then 
		return vec2(self[1] // b, self[2] // b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] // b[1], self[2] // b[2])
	end
end

function v2:__mod(b)
	if type(b) == "number" then 
		return vec2(self[1] % b, self[2] % b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] % b[1], self[2] % b[2])
	end
end

function v2:__pow(b)
	if type(b) == "number" then 
		return vec2(self[1] ^ b, self[2] ^ b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] ^ b[1], self[2] ^ b[2])
	end
end

function v2:__tostring(b)
	return "["..self[1]..","..self[2].."]"
end

function v2:__concat(b)
	return self:__tostring()..tostring(b)
end

--compare operator

function v2:__eq(b)
	if type(b) == "number" then 
		return self[1] == b and self[2] == b
	elseif type(b) == "table" and b[1] and b[2] then
		return self[1] == b[1] and self[2] == b[2]
	end
	return false
end

function v2:__lt(b)
	if type(b) == "number" then 
		return self[1] < b and self[2] < b
	elseif type(b) == "table" and b[1] and b[2] then
		return self[1] < b[1] and self[2] < b[2]
	end
	return false
end

function v2:__le(b)
	if type(b) == "number" then 
		return self[1] <= b and self[2] <= b
	elseif type(b) == "table" and b[1] and b[2] then
		return self[1] <= b[1] and self[2] <= b[2]
	end
	return false
end

function v2:__metatable(b)
	return nil
end

local vec2mt = class:methodsOnly(v2)

function vec2(x, y) -- constructor
	local n = {0,0}
	setmetatable(n, vec2mt)

	if type(x) == "table" then
		n[1] = x[1]
		n[2] = x[2] or x[1]
	elseif x then
		n[1] = x
		n[2] = y or x
	end

	return n
end