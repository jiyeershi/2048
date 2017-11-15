local GameScene = class("GameScene", cc.Scene)
local State = require "obj.State"
local GameLayer = require "GameLayer"

function GameScene:ctor( ... )
	self:init()
end

function GameScene:init( ... )
	State.init()
	local layer = GameLayer:create()
	layer:addTo(self)
end

function GameScene:GameStart()
	-- body
end

function GameScene:GameOver()
	-- body
end

return GameScene