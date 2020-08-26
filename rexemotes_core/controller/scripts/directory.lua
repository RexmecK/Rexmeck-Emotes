include "config"

function directory(path, default)
	if path:sub(1,1) == "/" then return path end
	if not default then default = config.getParameter("directory") or "/" end
	return default..path
end