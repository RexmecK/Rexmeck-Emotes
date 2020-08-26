
main = {}
main.searchCooldown = -1

emotelist = {}

bindEmotes = {
	up = "dab",
	left = "default",
	down = "wave",
	right = "facepalm",
}

function main:init()
    emotelist = root.assetJson("/rexemotes/list.json", {})
    bindEmotes = player.getProperty("rexemotes_binds", bindEmotes)
    
    self:refresh()
    self:refreshbinds()
end

function main:refreshbinds()
    for i,v in pairs(bindEmotes) do
        if emotelist[v] then
            widget.setImage(i.."preview", emotelist[v].image or "/assetmissing.png")
        end
    end
end

function main:savebinds()
	player.setProperty("rexemotes_binds", bindEmotes)
end

function main:refresh(search)
    widget.clearListItems("scroll.list")
    for i,v in pairs(emotelist) do
        if (search and ((v.title and v.title:lower():match(search)) or i:lower():match(search)) ) or (not search) then
            local id = widget.addListItem("scroll.list")
            widget.setImage("scroll.list."..id..".preview", v.image or "/assetmissing.png")
            widget.setText("scroll.list."..id..".text", v.title or i)
            v.id = i
            widget.setData("scroll.list."..id, v)
        end
    end
end

function removePatterns(s)
	s = s:gsub("%%", "%%%%")
	for i,v in pairs({
		"%.",
		"%(",
		"%)",
		"%+",
		"%-",
		"%*",
		"%?",
		"%[",
		"%]",
		"%^",
		"%$",
	}) do
		s = s:gsub(v,"%"..v)
	end

	return s
end

function main:update(dt)
    if self.searchCooldown > 0 then
        self.searchCooldown = math.max(self.searchCooldown - dt, 0)
    elseif self.searchCooldown == 0 then
        self.searchCooldown = -1
        local text = widget.getText("itemid")
        text = removePatterns(text or ""):lower()
        if text ~= "" then
            self:refresh(text)
        else
            self:refresh()
        end
    end
end

function main:uninit()

end

buttons = {}

function main:callback(widgetname)
    if buttons[widgetname] then
        buttons[widgetname]()
    end
end


function buttons.itemid()
    main.searchCooldown = 1
end

for i,v in pairs(bindEmotes) do
    buttons[i] = function()
        local selected = widget.getListSelected("scroll.list")
        if selected then
            local data = widget.getData("scroll.list."..selected)
            bindEmotes[i] = data.id
            main:refreshbinds()
            main:savebinds()
            world.sendEntityMessage(player.id(), "rexemotes.refresh")
        end
    end
end
