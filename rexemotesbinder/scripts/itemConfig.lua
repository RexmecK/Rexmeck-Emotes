

--nil if the item does not exist anymore
function itemConfig(itm, parameters)
	if not itm and not itm.name then return end

	local c
	if type(itm) == "table" then
		c = root.itemConfig({name = itm.name, count = itm.count or 1, parameters = itm.parameters})
	else
		c = root.itemConfig({name = itm, count = 1})
	end

	if c and c.config then
		return sb.jsonMerge(c.config, parameters or {})
	end

	return nil
end

function itemDirectory(itm, parameters)
	local c
	if type(itm) == "table" then
		c = root.itemConfig({name = itm.name, count = 1, parameters = itm.parameters})
	else
		c = root.itemConfig({name = itm, count = 1})
	end

	return c.directory
end