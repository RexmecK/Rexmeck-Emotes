modPath = "/rexemotesbinder/"
includePath = modPath.."scripts/"

_included = {}
function include(util)
	if not _included[includePath..util..".lua"] then
		require(includePath..util..".lua")
		_included[includePath..util..".lua"] = true
	end
end

function localinclude(util)
	local dir = directory(util, nil, ".lua")
	if not _included[dir] then
		require(dir)
		_included[dir] = true
	end
end

function system(name)
	require(directory(name, modPath.."systems/", ".lua"))
end

function init()
	include "config" --needed to load certain configs
	include "directory" 

	init = function()
		if main and main.init then
			main:init()
		end
		if itemScript and itemScript.init then
			itemScript:init()
		end
	end

	system(config.system or "default")
	
	if config.itemScript then
		require(directory(config.itemScript, nil, ".lua"))
	end

	init()
end

update_lastInfo = {}
update_info = {}
update_lateInited = false

function update(...)
	update_lastInfo = update_info
	update_info = {...}
	if not update_lateInited then
		update_lateInited = true
		if main and main.lateInit then
			main:lateInit(...)
		end
		if luaItem and luaItem.lateInit then
			luaItem:lateInit(...)
		end
	end

	if main and main.update then
		main:update(...)
	end
	if luaItem and luaItem.update then
		luaItem:update(...)
	end
end

function activate(...)
	if main and main.activate then
		main:activate(...)
	end
	if luaItem and luaItem.activate then
		luaItem:activate(...)
	end
end

function uninit()
	if main and main.uninit then
		main:uninit()
	end
	if luaItem and luaItem.uninit then
		luaItem:uninit()
	end
end

function createTooltip(...)
	if main and main.createTooltip then
		main:createTooltip(...)
	end
end

function callback(...)
	if main and main.callback then
		main:callback(...)
	end
end