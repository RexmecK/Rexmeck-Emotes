include "vec2"
include "class"

local animatorWrapped = animator
local _animator = {}

function _animator.partPoint(...)
	return vec2(animatorWrapped.partPoint(...))
end

function _animator.transformPoint(...)
	return vec2(animatorWrapped.transformPoint(...))
end

function _animator:__index(key)
	return _animator[key] or animatorWrapped[key]
end

animator = class:new(_animator)