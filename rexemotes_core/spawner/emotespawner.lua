--vehicle spawner returns entityId
function emoteVehicle(position, path, facing)
	local baseConfig = root.assetJson("/rexemotes_core/controller/main.customvehicle")
	
	if path:sub(1,1) ~= "/" then
		path = "/rexemotes/"..path.."/"
	end

	local result, actionConfig = pcall(root.assetJson, path.."action.config")

	if result then
		local customvehicleConfig = sb.jsonMerge(baseConfig, actionConfig)
		
		customvehicleConfig.directory = path or "/"
		customvehicleConfig.facing = facing or 1
		
		return world.spawnVehicle(customvehicleConfig.name, position, customvehicleConfig)
	else -- error output
		sb.logError(tostring(actionConfig))
	end
	return 0
end