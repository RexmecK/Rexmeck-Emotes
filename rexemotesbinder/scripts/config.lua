include "directory"
include "tableutil"

local _config = config
local _parameters = {}
config = {}

local inited = false
local function init()
	if item then
		_parameters = item.descriptor()
	else
		_parameters = _config.getParameter("", {})
	end
	inited = true
end

local function save(i)
	if activeItem then
		if not i then
			
			for i,v in pairs(_parameters) do
				activeItem.setInstanceValue(i, v)
			end
		end
	end
end

function config:getAnimation()
	if not inited then init() end

	local animation = _config.getParameter("animation", {})
	if type(animation) == "string" then
		animation = root.assetJson(directory(animation))
	end
	
	local animationCustom = _config.getParameter("animationCustom", {})
	return table.vmerge(animation or {}, animationCustom or {})
end


function config.getParameter(...)
	return _config.getParameter(...)
end

setmetatable(config,
	{
		__newindex = function(t, key, value)
			if not inited then init() end
			_parameters[key] = value
			if activeItem then
				activeItem.setInstanceValue(key, value)
			end
		end,
		__index = function(t, key)
			if not inited then init() end
			return _parameters[key] or _config.getParameter(key)
		end
	}
)