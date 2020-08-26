modPath = "/rexemotes_core/"
corePath = modPath.."controller/"

_included = {}
function include(name)
	if _included[corePath.."scripts/"..name..".lua"] then return end
	_SBLOADED = {}
	_included[corePath.."scripts/"..name..".lua"] = true
	require(corePath.."scripts/"..name..".lua")
end

function init()
	include "config" --needed to load certain configs

	if config.mode then
		require(corePath.."systems/"..config.mode..".lua")
	else
		require(corePath.."systems/edit.lua")
	end

	if main and main.init then
		main:init()
	end
end

update_lastInfo = {}
update_info = {}
update_lateInited = false
function update(...)
	update_lastInfo = update_info
	update_info = {...}
	if not update_lateInited and main and main.lateInit then
		update_lateInited = true
		main:lateInit(...)
	end
	if main and main.update then
		main:update(...)
	end
end

function activate(...)
	if main and main.activate then
		main:activate(...)
	end
end

function uninit()
	if main and main.uninit then
		main:uninit()
	end
end