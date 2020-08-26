include "vec2"
include "animator"
include "config"

local function lerp(f,t,r)
	return f + (t - f) * r
end

transforms = {}
transforms.current = {}
transforms.override = {}
transforms.overriden = false
transforms.default = nil
transforms.custom = {}

function transforms:init()
	if not self.default then
		self:load()
	end
	message.setHandler("getTransforms", function(_, loc, ...) if loc then return self.default end end)
	message.setHandler("setTransforms", function(_, loc, transforms) if loc then self.override = table.vmerge(transforms or {}, {}) self.overriden = true end end)
	self:update(1/60)
end

local function eqmat(a,b)
	if #a ~= #b then return false end
	for i=1,#a do
		if a[i] ~= b[i] then
			return false 
		end
	end
	return true
end

local transformationsgroups = {}

function setTransformations(name, mat)
	if not transformationsgroups[name] or not eqmat(transformationsgroups[name], mat) then
		if animator.hasTransformationGroup(name) then
			animator.resetTransformationGroup(name) 
			animator.scaleTransformationGroup(name, {mat[1], mat[2]}, {mat[3], mat[4]})
			animator.rotateTransformationGroup(name, math.rad(mat[5]), {mat[6], mat[7]})
			animator.translateTransformationGroup(name,{mat[8], mat[9]})
		end
		transformationsgroups[name] = mat
	end
end

function transforms:update(dt)
	if not self.default then
		self:load()
	end
	for name,def in pairs(self.default or {}) do
		if self.custom[name] then
			local current = table.vmerge(table.copy(def), self.override[name] or self.current[name] or {})
			self.custom[name](current)
		else
			local current = self.override[name] or self.current[name] or {}
			local cal = {
				scale			= current.scale or def.scale or 1,
				scalePoint		= current.scalePoint or def.scalePoint or 0,
				position		= vec2(current.position or def.position or 0) * vec2(current.scale or def.scale or 1),
				rotation		= current.rotation or def.rotation or 0,
				rotationPoint	= vec2(current.scalePoint or def.scalePoint or 0):lerp( current.rotationPoint or def.rotationPoint or 0, current.scale or def.scale or 1)
			}
			--animator.resetTransformationGroup(name) 
			--animator.scaleTransformationGroup(name, cal.scale, cal.scalePoint)
			--animator.rotateTransformationGroup(name, math.rad(cal.rotation), cal.rotationPoint)
			--animator.translateTransformationGroup(name, cal.position)
			setTransformations(name,
				{
					cal.scale[1], cal.scale[2], cal.scalePoint[1], cal.scalePoint[2],
					cal.rotation, cal.rotationPoint[1], cal.rotationPoint[2],
					cal.position[1], cal.position[2]
				}
			)
		end
	end
	self.override = {}
	self.overriden = false
end

function transforms:uninit()

end

-- custom transform application.
function transforms:addCustom(name, default, f)
	self.custom[name] = f
	self:add(name, default)
end

-- apply over the current
function transforms:blend(transforms)
	for name,t in pairs(transforms) do
		self.current[name] = {}
		for name2, property in pairs(t) do
			if type(self.current[name][name2]) == "table" then
				self.current[name][name2] = vec2(property)
			else
				self.current[name][name2] = property
			end
		end
	end
end

-- reset and apply
transforms.applied = false

function transforms:apply(transforms)
	--self:reset()
	self.applied = true
	self:blend(transforms)
end

function transforms:reset()
	self.applied = false
	self.current = {}
end

function transforms:add(name, def)
	if not self.default then
		self:load()
	end
	for i2,v2 in pairs(def) do
		if type(v2) == "table" and #v2 == 2 then
			def[i2] = vec2(v2)
		end
	end
	self.default[name] = def
end

function transforms:load()
	self:reset()
	self.default = {}
	local animation = config:getAnimation()
	for i,v in pairs(animation.transformationGroups or {}) do
		if not v.ignore then -- check if we can use it
			local newtrans = {position = vec2(0,0), scale = vec2(1,1), scalePoint = vec2(0,0), rotation = 0, rotationPoint = vec2(0,0)}
			if v.transform then
				newtrans = sb.jsonMerge(newtrans, v.transform or {})
			end
			self:add(i, newtrans)
		end
	end
end

function transforms:getDefaultTransforms()
	if not self.default then
		self:load()
	end
	return self.default
end

