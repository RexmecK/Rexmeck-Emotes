include "vec2"
include "transforms"
include "tableutil"

animation = {}
animation.key = 1
animation.keyTime = 0
animation.keyTimeTarget = 0
animation.playing = false
animation.keyFrames = {}
animation.defaultTransforms = {}

local function parseKeyFramesVec2(keyFrames)
	local newkeyframes = {}
	--each keys
	for i,key in ipairs(keyFrames or {}) do
		local newkey = key
		--each transforms
		for name, transform in pairs(key.transforms) do
			local newtransform = {}
			--each tranform property
			for name2, property in pairs(transform) do
				if type(property) == "table" then
					newtransform[name2] = vec2(property)
				else
					newtransform[name2] = property
				end
			end
			newkey.transforms[name] = newtransform
		end
		table.insert(newkeyframes, newkey)
	end

	return newkeyframes
end

--initial animation: keyFrames, Whole transforms of your item
function animation:new(keyFrames)
	local n = table.copy(self)
	n.keyFrames = parseKeyFramesVec2(keyFrames) -- vec2 from configs are not vec2 we use
	return n
end

--internal use
function animation:_reachkey(key)
	if not key then return end
	for i,v in pairs(key.playSounds or {}) do
		if type(v) == "string" and type(i) == "number" then
			if animator.hasSound(v) then
				animator.playSound(v)
			end
		end
	end
	for i,v in pairs(key.animationState or {}) do
		if type(v) == "string" and type(i) == "string" then
			animator.setAnimationState(i,v, true)
		end
	end
	for i,v in pairs(key.burstParticle or {}) do
		if type(v) == "string" and type(i) == "number" then
			animator.burstParticleEmitter(v)
		end
	end
	for i,v in pairs(key.lights or {}) do
		if type(v) == "bool" and type(i) == "string" then
			animator.setLightActive(i,v)
		end
	end
	for i,v in ipairs(key.fireEvents or {}) do
		self:fireEvent(v)
	end
end

--update animation time
function animation:update(dt)
	if self.playing then
		if self.keyTime == self.keyTimeTarget then
			self.key = self.key + 1
			if self.keyFrames[self.key] and self.keyFrames[self.key + 1] then
				self.keyTime = 0
				self:_reachkey(self.keyFrames[self.key])
				self.keyTimeTarget = self.keyFrames[self.key + 1].wait
			else
				self:_reachkey(self.keyFrames[self.key])
				self.playing = false
			end
		end
		if self.keyTime < self.keyTimeTarget then
			self.keyTime = math.min(self.keyTime + dt, self.keyTimeTarget)
		end
	end
end

--play animation from start
function animation:play()
	if #self.keyFrames == 0 then return end
	self.playing = true
	self.key = 1
	self.keyTime = 0
	self.keyTimeTarget = self.keyFrames[math.min(2, #self.keyFrames)].wait
	self:_reachkey(self.keyFrames[self.key])
end

-- to do
function animation:inProgress()
	return self.key ~= 1
end

--pause animation
function animation:pause()
	self.playing = false
end

--stop animation completely
function animation:stop()
	self:pause()
	self.keyTime = 0
	self.key = 1
end

--removes default (makes holes if default)
function animation:stripDefault(key)
	local nkey = {}
	for i,transform in pairs(transforms.default) do
		nkey[i] = {}
		for i2, property in pairs(transform) do
			if key[i][i2] ~= property then
				nkey[i][i2] = key[i][i2]
			end
		end
	end
	return nkey
end

--full transfroms keys (fill the gaps in the key tranforms)
function animation:ftk(key)
	local fkey = {}
	for i,transform in pairs(transforms.default) do
		fkey[i] = {}
		for i2, property in pairs(transform) do
			fkey[i][i2] = (key.transforms[i] or {})[i2] or property
		end
	end
	return fkey
end

--key to key interpolation
function animation:ktk(from, to, ratio)
	local fromT = self:ftk(from)
	local toT = self:ftk(to)
	local current = {}
	for i,transform in pairs(transforms.default) do
		local timeRatio = ratio
		if to.transforms[i] then
			timeRatio = ratio ^ (to.transforms[i].curve or 1)
		end
		current[i] = {}
		for i2, property in pairs(transform) do
			if i == "time" or i == "curve" then
				--dont give internal stuff
			elseif type(property) == "table" and #property == 2 then
				current[i][i2] = vec2(
					fromT[i][i2][1] + ((toT[i][i2][1] - fromT[i][i2][1]) * timeRatio), 
					fromT[i][i2][2] + ((toT[i][i2][2] - fromT[i][i2][2]) * timeRatio)
				)
			elseif type(property) == "number" then
				current[i][i2] = fromT[i][i2] + ((toT[i][i2] - fromT[i][i2]) * timeRatio)
			end
		end
	end
	return current
end

--current animation transforms interpolations
function animation:transforms()
	if self.key >= #self.keyFrames then
		return self:stripDefault(self:ftk(self.keyFrames[#self.keyFrames]))
	end
	return self:stripDefault(self:ktk(self.keyFrames[self.key], self.keyFrames[self.key+1], self.keyTime/self.keyTimeTarget))
end

function animation:bindFireEvent(func)
	self._fireEvent = func
end

animation._fireEvent = function() end

function animation:fireEvent(name)
	self._fireEvent(name)
end