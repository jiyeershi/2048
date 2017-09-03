local GameScene = class("GameScene", cc.Scene)
local GameLayer = require "GameLayer"

function GameScene:ctor( ... )
	self:init()
end

function GameScene:init( ... )
	local layer = GameLayer:create()
	layer:addTo(self)
end