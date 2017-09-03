local GameLayer = class("GameLayer", cc.Layer)

function GameLayer:ctor()
	self:init()
end


function GameLayer:init()
	local touchCallBack = function ( event )
		print("touch -- >", event)
	end
	self:onTouch(touchCallBack, false)
end

function GameLayer:onEnter( )
	self.super:onEnter()
	local 
end


function GameLayer:onExit( )
	self.super:onExit()
	
end