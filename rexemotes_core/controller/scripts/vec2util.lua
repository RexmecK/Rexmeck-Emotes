include "vec2"

vec2util = {}

function vec2util.angle(vector)
	local angle = math.atan(vector.x, vector.y)
	if angle < 0 then angle = angle + 2 * math.pi end
	return angle
end

function vec2util.rotate(vector, angle)
	local sinAngle = math.sin(angle)
	local cosAngle = math.cos(angle)

	return vec2(
		{
			vector.x * cosAngle - vector.y * sinAngle,
			vector.x * sinAngle + vector.y * cosAngle,
		}
	)
end

function vec2util.lerp()
	
end