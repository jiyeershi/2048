--[[
移动方格类
]]
local cell = class("cell", cc.Sprite)
local State = require "obj.State"

function cell:ctor()
	self.num = 0
	self.bornPoint = nil
	self:init()
end

--添加背景图
function cell:init()
	self:setTexture("bg2.png")
	self.lab = cc.Label:createWithTTF("", "FZY4JW.TTF", 20)
	self:addChild(self.lab)
	local rect = self:getContentSize()
	self.lab:setPosition(rect.width/2, rect.height/2)
end

function cell:setNo(num)
	self.num = num
	local color = "COLOR_" .. num
	assert(COLOR_T[color] )
	self:setColor(COLOR_T[color])
	self.lab:setString(num)
end

--cell出现的自带动作
function cell:appear()
	-- self:setScale(0.8)
	local scaleTo1 = cc.ScaleTo:create(0.02, 0.8, 0.8)
	local scaleTo2 = cc.ScaleTo:create(0.05, 1, 1)
	local act = transition.sequence({scaleTo1, scaleTo2})
	self:runAction(act)
end

function cell:createAppearAction( ... )
	local scaleTo1 = cc.ScaleTo:create(0.02, 0.8, 0.8)
	local scaleTo2 = cc.ScaleTo:create(0.05, 1, 1)
	local act = transition.sequence({scaleTo1, scaleTo2})
	return act
end

function cell:setBornPoint( point )
	self.bornPoint = point
end

function cell:getBornPoint( point )
	return self.bornPoint
end

function cell:gotoBornPoint()
	self:setPosition(self.bornPoint)
end

return cell
