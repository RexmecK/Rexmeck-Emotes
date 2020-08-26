include "config"
include "portrait"
include "animator"
include "animations"
include "vec2"

actorManager = {}
actorManager.actors = {}
actorManager.seats = {}
actorManager.ready = false

local function speciesFullbright(specie)
	if not specie then return false end
	local speciesConfig = root.assetJson("/species/"..specie..".species")
	if speciesConfig and speciesConfig.humanoidOverrides and speciesConfig.humanoidOverrides.bodyFullbright then
		return speciesConfig.humanoidOverrides.bodyFullbright
	end
	return false
end

function actorManager:init()
	self.loungePositions = config.loungePositions
	for i,v in pairs(self.loungePositions) do
		self.seats[i] = 0
	end
	self:setupEmotesAnimationEvent()
	self:update(1/16)
end

function actorManager:setupEmotesAnimationEvent()
	local emoteFrames = {
		"blabber.1",
		"blabber.2",
		"shout.1",
		"shout.2",
		"happy.1",
		"happy.2",
		"idle.1",
		"sad.1",
		"sad.2",
		"sad.3",
		"sad.4",
		"sad.5",
		"neutral.1",
		"neutral.2",
		"laugh.1",
		"laugh.2",
		"annoyed.1",
		"annoyed.2",
		"oh.1",
		"oh.2",
		"oooh.1",
		"oooh.2",
		"oooh.3",
		"blink.1",
		"blink.2",
		"blink.3",
		"wink.1",
		"wink.2",
		"wink.3",
		"wink.4",
		"wink.5",
		"eat.1",
		"eat.2",
		"sleep.1",
		"sleep.2",
	}
	for i,v in pairs(self.loungePositions) do
		for _, frame in pairs(emoteFrames) do
			animations:addEvent(i..".emote."..frame, function() animator.setGlobalTag(i.."_Emote", frame) end)
		end
		animator.setGlobalTag(i.."_Emote", "idle.1")
	end
end

function onInteraction(args)
	local index = 0
	for SeatId,v in pairs(actorManager.loungePositions) do
		if not vehicle.entityLoungingIn(SeatId) then
			return {"SitDown", index}
		end
		index = index + 1
	end
	return {"None", 0}
end

function actorManager:fullLounged()
	for SeatId,v in pairs(self.loungePositions) do
		if not vehicle.entityLoungingIn(SeatId) then
			return false
		end
	end
	return true
end

function actorManager:emptyLounged()
	for SeatId,v in pairs(self.loungePositions) do
		if vehicle.entityLoungingIn(SeatId) then
			return false
		end
	end
	return true
end

function actorManager:toggleLounges(b)
	for SeatId,v in pairs(self.loungePositions) do
		vehicle.setLoungeEnabled(SeatId, b)
	end
end

function actorManager:update(dt)
	local interactable = false
	local ready = true

	for SeatId,v in pairs(self.loungePositions) do
		local lounging = vehicle.entityLoungingIn(SeatId)
		if lounging then
			if not self.actors[SeatId] then
				self:setupActor(SeatId)
			end
		else
			interactable = true
			self.actors[SeatId] = nil
			ready = false
		end
	end

	for SeatId,v in pairs(self.loungePositions) do
		local lounging =  vehicle.entityLoungingIn(SeatId)
		if lounging and self.seats[SeatId] ~= 1 then
			self.seats[SeatId] = 1
			--vehicle.setLoungeStatusEffects(SeatId, {"invisible"})
			animator.setAnimationState(SeatId, "show")
		elseif not lounging and self.seats[SeatId] == 1 then
			self.seats[SeatId] = -1
			--vehicle.setLoungeStatusEffects(SeatId, {})
			animator.setAnimationState(SeatId, "hidden")
		end
	end

	self.ready = ready
	vehicle.setInteractive(interactable)
end

function actorManager:uninit()

end

function actorManager:setupActor(SeatId)
	local lounging = vehicle.entityLoungingIn(SeatId)
	if not lounging then return end
	local newactor = {
		portrait = portrait:new(lounging)
	}

	local parts = newactor.portrait:parts()

	newactor.skinDirectives = newactor.portrait:skinDirectives()
	animator.setGlobalTag(SeatId.."_gender", world.entityGender(lounging))
	animator.setGlobalTag(SeatId.."_skinDirectives", newactor.skinDirectives)

	if speciesFullbright(world.entitySpecies(lounging)) then
		animator.setAnimationState(SeatId.."_fullbright", "true")
	else
		animator.setAnimationState(SeatId.."_fullbright", "false")
	end

	if parts.Head then
		animator.setGlobalTag(SeatId.."_Head", newactor.portrait:image("Head")..":normal"..newactor.skinDirectives)
	else
		animator.setGlobalTag(SeatId.."_Head", "/assetmissing.png")
	end

	if parts.Hair then
		animator.setGlobalTag(SeatId.."_Hair", newactor.portrait:image("Hair")..":normal"..newactor.portrait:directives("Hair"))
	else
		animator.setGlobalTag(SeatId.."_Hair", "/assetmissing.png")
	end

	if parts.Face then
		animator.setGlobalTag(SeatId.."_Face", newactor.portrait:image("Face"))
		animator.setGlobalTag(SeatId.."_FaceDirectives", newactor.portrait:directives("Face"))
	else
		animator.setGlobalTag(SeatId.."_Face", "/assetmissing.png")
		animator.setGlobalTag(SeatId.."_FaceDirectives", "")
	end

	if parts.HeadArmor then
		animator.setGlobalTag(SeatId.."_HeadArmor", newactor.portrait:image("HeadArmor")..":normal"..newactor.portrait:directives("HeadArmor"))
	else
		animator.setGlobalTag(SeatId.."_HeadArmor", "/assetmissing.png")
	end

	if parts.FacialHair then
		animator.setGlobalTag(SeatId.."_FacialHair", newactor.portrait:image("FacialHair")..":normal"..newactor.portrait:directives("FacialHair"))
	else
		animator.setGlobalTag(SeatId.."_FacialHair", "/assetmissing.png")
	end

	if parts.FacialMask then
		animator.setGlobalTag(SeatId.."_FacialMask", newactor.portrait:image("FacialMask")..":normal"..newactor.portrait:directives("FacialMask"))
	else
		animator.setGlobalTag(SeatId.."_FacialMask", "/assetmissing.png")
	end

	if parts.Body then
		animator.setGlobalTag(SeatId.."_Body", newactor.portrait:image("Body")..":idle.5"..newactor.skinDirectives)
	else
		animator.setGlobalTag(SeatId.."_Body", "/assetmissing.png")
	end

	if parts.BodyArmor then
		animator.setGlobalTag(SeatId.."_BodyArmor", newactor.portrait:image("BodyArmor")..":idle.5"..newactor.portrait:directives("BodyArmor"))
	else
		animator.setGlobalTag(SeatId.."_BodyArmor", "/assetmissing.png")
	end

	if parts.LegArmor then
		local legImage = newactor.portrait:image("LegArmor")..":idle.5"..newactor.portrait:directives("LegArmor")
		local legImageSize = vec2(root.imageSize(legImage)) or vec2({43,43})
		local scaleSize = legImageSize / vec2({43,43})
		animator.setGlobalTag(SeatId.."_LegArmor", legImage)
		animator.setGlobalTag(SeatId.."_UpLegArmor", legImage.."?crop;"..(16 * scaleSize[1])..";"..(5 * scaleSize[2])..";"..(22 * scaleSize[1])..";"..(10 * scaleSize[2]))
		animator.setGlobalTag(SeatId.."_LowerLegArmor", legImage.."?crop;"..(16 * scaleSize[1])..";"..(3 * scaleSize[2])..";"..(22 * scaleSize[1])..";"..(7 * scaleSize[2]))
		animator.setGlobalTag(SeatId.."_FootArmor", legImage.."?crop;"..(16 * scaleSize[1])..";"..(1 * scaleSize[2])..";"..(22 * scaleSize[1])..";"..(4 * scaleSize[2]))
	else
		animator.setGlobalTag(SeatId.."_UpLegArmor", "/assetmissing.png")
		animator.setGlobalTag(SeatId.."_LowerLegArmor", "/assetmissing.png")
		animator.setGlobalTag(SeatId.."_FootArmor", "/assetmissing.png")
	end

	if parts.BackArmor then
		animator.setGlobalTag(SeatId.."_BackArmor", newactor.portrait:image("BackArmor")..":idle.1"..newactor.portrait:directives("BackArmor"))
	else
		animator.setGlobalTag(SeatId.."_BackArmor", "/assetmissing.png")
	end

	if parts.BackArm then
		animator.setGlobalTag(SeatId.."_BackArm", newactor.portrait:image("BackArm")..":rotation"..newactor.skinDirectives)
	else
		animator.setGlobalTag(SeatId.."_BackArm", "/assetmissing.png")
	end

	if parts.BackArmArmor then
		animator.setGlobalTag(SeatId.."_BackArmArmor", newactor.portrait:image("BackArmArmor")..":rotation"..newactor.portrait:directives("BackArmArmor"))
	else
		animator.setGlobalTag(SeatId.."_BackArmArmor", "/assetmissing.png")
	end

	if parts.FrontArm then
		animator.setGlobalTag(SeatId.."_FrontArm", newactor.portrait:image("FrontArm")..":rotation"..newactor.skinDirectives)
	else
		animator.setGlobalTag(SeatId.."_FrontArm", "/assetmissing.png")
	end

	if parts.FrontArmArmor then
		animator.setGlobalTag(SeatId.."_FrontArmArmor", newactor.portrait:image("FrontArmArmor")..":rotation"..newactor.portrait:directives("FrontArmArmor"))
	else
		animator.setGlobalTag(SeatId.."_FrontArmArmor", "/assetmissing.png")
	end

	self.actors[SeatId] = newactor
end