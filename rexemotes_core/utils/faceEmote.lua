local function split(inputstr, sep) 
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

local function imageInfo(str)
    local data = {image=nil, frame=nil, directives=nil}
    local splitdirectives = split(str, "?")
    data.directives = tostring(splitdirectives[2])
    local splitframe = split(splitdirectives[1], ":")
    data.image = tostring(splitframe[1])
    data.frame = tostring(splitframe[2])
    return data
end

function getFaceEmote(playerId)
    if not playerId or not world.entityExists(playerId) then return end
    local portrait = world.entityPortrait(playerId, "full")
    for i,v in pairs(portrait) do
        local imgdata = imageInfo(v.image or "/assetmissing.png")
        if imgdata.image:find("emote.png") then
            return imgdata.frame
        end
    end
    return "idle.1"
end
