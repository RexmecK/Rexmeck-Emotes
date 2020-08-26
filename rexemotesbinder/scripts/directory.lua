include "config"
include "itemConfig"

function directory(path, default, suffix)
	if path:sub(1,1) == "/" then return path end
	if not default then default = config.getParameter("directory") or (not item or itemDirectory(item.name())) or "/" end

	if suffix and path:sub(path:len() - suffix:len() + 1,path:len()):lower() ~= suffix then return default..path..suffix end
	return default..path
end