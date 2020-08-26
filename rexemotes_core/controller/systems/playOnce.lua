include "config"
include "vec2"
include "vec2util"
include "mcontroller"
include "transforms"
include "animations"
include "actorManager"

main = {}
main.played = false
main.destroyTick = -1

function main:init()
	actorManager:init()
	transforms:init()
	animations:init()
	self.targetFacing = config.facing or 1
	self.canMove = config.canMove or false
	self.movementSpeed = config.movementSpeed or 14
	actorManager:toggleLounges(true)
end

main.targetFacing = 1
main.facing = 1
main.control = 0
main.movementSpeed = 14

function main:updateSeatControls()
	if not self.canMove then return end
	self.control = 0
	for i,v in pairs(config.loungePositions or {}) do
		if vehicle.entityLoungingIn(i) then
			if vehicle.controlHeld(i, "left") then
				self.control = -1
				self.targetFacing = -1
			elseif vehicle.controlHeld(i, "right") then
				self.control = 1
				self.targetFacing = 1
			end
			return
		end
	end
end

function main:updateMovement()
	if self.targetFacing ~= self.facing then
		self.facing = self.targetFacing
		animator.resetTransformationGroup("facing")
		animator.scaleTransformationGroup("facing", {self.facing, 1})
	end
	if self.control ~= 0 then
		mcontroller.approachXVelocity(self.movementSpeed * self.control, 1000)
	end
end

function main:update(dt)
	self:updateSeatControls()
	self:updateMovement()
	actorManager:update(dt)
	animations:update(dt)
	if animations:isAnyPlaying() then
		transforms:apply(animations:transforms())
	end
	transforms:update(dt)

	local full = actorManager:fullLounged()
	local empty = actorManager:emptyLounged()

	if full and not self.played then
		if animations:isPlaying("idle") then
			animations:stop("idle")
		end
		if animations:isPlaying("idleLoop") then
			animations:stop("idleLoop")
		end
		self.played = true
		animations:play("play")
	elseif not full and not self.played and not self.playedIdle and not animations:isAnyPlaying() then
		self.playedIdle = true
		animations:play("idle")
	elseif not full and not self.played and self.playedIdle and not animations:isAnyPlaying() then
		self.playedIdle = true
		animations:play("idleLoop")
	elseif ((self.played and (not full or not animations:isAnyPlaying())) or empty) and not self.kicked then
		self.kicked = true
		actorManager:toggleLounges(false)
		self.destroyTick = 5
	end

	if self.destroyTick > 0 then
		self.destroyTick = self.destroyTick - 1
	elseif self.destroyTick == 0 then
		vehicle.destroy()
	end
end

function main:uninit()
	actorManager:uninit(dt)
	transforms:uninit()
end