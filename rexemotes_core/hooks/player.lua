require "/scripts/vec2.lua"

local oldInit = init or function () end
local oldUpdate = update or function() end

local playerId = 1
local playerFacing = 1
local playerPosition = {0,0}
local emoteBindCooldown = 0

local function play() end
local toplay
local toplay2

bindTable = {
    ["happy.1"] = "up",
    ["annoyed.1"] = "left",
    ["sad.1"] = "down",
    ["neutral.1"] = "right"
}

bindEmotes = {
	up = "dab",
	left = "default",
	down = "wave",
	right = "facepalm",
}

function init(...)
    x, e = pcall(oldInit)
    if not x then
        sb.logError(e)
        oldInit = function() end
	end
	
	bindEmotes = player.getProperty("rexemotes_binds", bindEmotes)
	player.setProperty("rexemotes_binds", bindEmotes)

	message.setHandler("rexemotes.refresh", 
		function(_, loc) if not loc then return end 
			bindEmotes = player.getProperty("rexemotes_binds", bindEmotes)
		end
	)
end

function update(...)
    x, e = pcall(oldUpdate, ...)
    if not x then
        sb.logError(e)
        oldUpdate = function() end
    end

	playerId = player.id()

    --gets the player facing
	if playerId and world.entityExists(playerId) then
		playerPosition = world.entityPosition(playerId)
		local playerVel = world.entityVelocity(playerId) or {0,0}
		if playerVel[1] > 0.0 then
			playerFacing = 1
		elseif playerVel[1] < 0.0 then
			playerFacing = -1
		end
	end

	local args = {...}
	
	if toplay2 then
		play(toplay2)
		toplay2 = nil
	end

	checkBind()

	if emoteBindCooldown > 0 then
		emoteBindCooldown = math.max(emoteBindCooldown - args[1], 0)
		if toplay then
			toplay2 = toplay
			toplay = nil
		end
		if toplay or toplay2 or player.isLounging() then
			mcontroller.clearControls()
			mcontroller.controlModifiers({movementSuppressed = 1})
		end
	end
end

require "/rexemotes_core/utilS/faceEmote.lua"
function checkBind()
	local currentEmoteFrame = getFaceEmote(player.id())
	if currentEmoteFrame ~= "idle.1" and currentEmoteFrame:sub(1,5) ~= "blink" and emoteBindCooldown == 0 then
		emoteBindCooldown = 1
		if bindTable[currentEmoteFrame] and mcontroller.crouching() and not player.isLounging() then	
			mcontroller.clearControls()
			if player.swapSlotItem() then
			player.giveItem(player.swapSlotItem())
			end
			player.setSwapSlotItem(root.assetJson("/rexemotes_core/unemote/item.json"))
			toplay = bindEmotes[bindTable[currentEmoteFrame]]
		end
	end
end

require "/rexemotes_core/spawner/emotespawner.lua"
local function emote(index, facing)
	if not index then return false end
	if player.isLounging() then return false end

	local vehicleId = emoteVehicle(world.entityPosition(player.id()), index, facing)
	if world.entityExists(vehicleId) then
		world.callScriptedEntity(vehicleId, "mcontroller.setVelocity", world.entityVelocity(playerId) or {0,0})
		player.lounge(vehicleId)
		return true
	end
	
	return false
end

play = function(index)
	emote(index, mcontroller.facingDirection())
end