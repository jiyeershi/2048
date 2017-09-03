
local cell = class("cell", cc.Sprite)
local State = require "State"

function ctor(dataSource, index)
	self.index = 0
	self.moveToIndex = 0
	self.num = 0
	self.dataSource = dataSource
end

--添加背景图
function cell:init( ... )
	
end

function cell:checkMove(dir)
	return State.move(dir, index)
end

return cell
