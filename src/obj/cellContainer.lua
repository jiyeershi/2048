--[[
1、绑定固定方格和移动方格的关系容器
2、记录固定方格的在界面中的轴心坐标以及在整个移动表盘的逻辑序数
]]
local cellContainer = class("cellContainer")

function cellContainer:ctor( ... )
 	self.cell = nil
 	self.index = nil
 	self.midPos = nil
end 

function cellContainer:setIndex( index )
 	self.index = index
end 

function cellContainer:setCell( cell )
 	self.cell = cell
end 

function cellContainer:getCell( ... )
	return self.cell
end

function cellContainer:bindPosition( pos )
	self.midPos = pos
end

function cellContainer:getBasePos( ... )
	return self.midPos
end

function cellContainer:dump( param )
	print(param .. "cellContainer ", self.index)
	print(param .. "cellContainer ", self.cell)
end

-- function cellContainer:dump( param )
-- 	print(param .. "cellContainer ", self.index)
-- 	print(param .. "cellContainer ", self.cell)
-- end


return cellContainer