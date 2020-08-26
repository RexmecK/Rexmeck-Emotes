function init()
	if config and config.getParameter("loadscript") then
		init = nil
		pcall(require, config.getParameter("loadscript"))
		if init then
			init()
		end
	else
		message.setHandler("kill", projectile.die)
	end
end
