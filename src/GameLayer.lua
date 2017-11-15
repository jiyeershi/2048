local GameLayer = class("GameLayer", cc.Layer)
local State = require "obj.State"
local cell = require "obj.cell"
local cellContainer = require "obj.cellContainer"

function GameLayer:ctor()
	self.beginPos, self.endPos = cc.p(0, 0), cc.p(0, 0)
	self.cellTable = {} --移动格子的生成器
	self.cellContainers = {} --格子容器数组，盛放移动格子
	self.operateCount = 0 --操作次数
	self:init()
end

function GameLayer:init()
	local touchCallBack = function ( event )
		print("touch -- >", event)
		local name = event.name
		print(name)
		if name == "began" then
			self.beginPos = cc.p(event.x, event.y)
		elseif name == "ended" then
			-- return true
			self.endPos = cc.p(event.x, event.y)
			self:Move()
		end
		return true
	end
	self:onTouch(touchCallBack, false)
	self:drawCoreControlUI()
	self:drawHelpSettingUI()
	self:startGame()
end

function GameLayer:drawHelpSettingUI( ... )
	--添加重新开始按钮
	if not self.restartBtn then
		self.restartBtn = ccui.Button:create("bg2.png", "bg2.png", "bg2.png", 0)
		self.restartBtn:addTo(self)
		local winSize = cc.Director:getInstance():getWinSize()
		self.restartBtn:setPosition(cc.p(winSize.width/2, 100))
		self.restartBtn:setScale9Enabled(true)
		self.restartBtn:setContentSize(cc.size(150, 60))
		local lab = cc.Label:createWithTTF("restart", "FZY4JW.TTF", 25)
		self.restartBtn:addChild(lab)
		local labSize = lab:getContentSize()
		lab:setPosition(cc.p(75, 30))
		self.restartBtn:addClickEventListener(function ( event )
			print("restart ..", event)
			self.restartBtn:setVisible(false)
			self:Restart()
		end)
		self.restartBtn:setVisible(false)
	end
end

function GameLayer:Restart()
	--将容器中的格子转移到格子生成器中
	for i=1,#self.cellContainers do
		local ct = self.cellContainers[i]
		local cell = ct:getCell()
		if cell then
			ct:setCell(nil)
			self:recycleCell(cell)
		end
	end
	--状态清空
	State.reset()
	self:startGame()
	self.restartBtn:setVisible(false)
	self.gameOverLab:setVisible(false)
	self.operateCount = 0
end

local actTime = 0.03
function GameLayer:Move()
	print("GameLayer:Move")
	--根据|beginPos.x - endPos.x| 与|beginPos.y - endPos.y|大小计算方向
	local dir = 0
	local diffX = (self.beginPos.x - self.endPos.x)
	local diffY = (self.beginPos.y - self.endPos.y)
	if math.abs(diffX) < 10 and  math.abs(diffY) < 10 then return end
	if math.abs(diffX) > math.abs(diffY) then
		if diffX < 0 then
			--向右
			dir = MOVERIGHT
		else
			--向左
			dir = MOVELEFT
		end
	else
		if diffY > 0 then
			--向下
			dir = MOVEDOWN
		else
			--向上
			dir = MOVEUP
		end
	end
	-- print(dir)
	local isSuccess = false
	--更新移动数据模型
	local ruleArr = State.MoveDir(dir)
	for i,v in ipairs(ruleArr) do
		-- print("v.cur ", v.cur, "v.to ", v.to)
		if v.cur ~= v.to then
			local isMerge = v.isMerge
			local mergeRet = v.mergeRet
			local curContainer = self.cellContainers[v.cur]
			-- curContainer:dump("curContainer")
			local curPos = curContainer:getBasePos()
			local cell = curContainer:getCell()
			--发生移动
			if cell then
				local toContainer = self.cellContainers[v.to]
				local toPos = toContainer:getBasePos()
				local oldCell = toContainer:getCell()
				local disAppearAct = cc.FadeOut:create(actTime)
				local appear = nil
				if isMerge then
					cell:setNo(mergeRet)
					-- cell:appear()
					-- oldCell:runAction(disAppearAct)
					-- oldCell:setVisible(false)
					self:recycleCell(oldCell)
					appear = cell:createAppearAction()
					if mergeRet == MAX_GAMESUCCESS_NUM then
						isSuccess = true
					end
				end
				--清空当前的
				curContainer:setCell(nil)
				toContainer:setCell(cell)--当目标container上有cell时，这里就被替换掉了
				-- local act1 = cc.MoveTo:create(actTime, cc.p(toPos.x, toPos.y))
				-- local act = transition.sequence({act1, appear})
				-- cell:runAction(act)
				cell:setPosition(toPos)
			end
		end
	end
	self:randGenerateCell(2)
	local canMove = self:canMove()
	if not canMove then 
		self:gameOver(isSuccess)
	else
		self.operateCount = self.operateCount + 1
		if isSuccess then self:gameOver(isSuccess) end
	end
	print("operateCount ... " .. self.operateCount)
	State.printModel("after rand...")
end

--绘制核心操作区域
function GameLayer:drawCoreControlUI( ... )
	--创建移动方格的大背景
	local delta = 20
	local winSize = cc.Director:getInstance():getWinSize()
	local bg = cc.Sprite:create("bg2.png")
	self:addChild(bg)
	print("winSize.width = ", winSize.width)
	print("winSize.height = ", winSize.height)
	local bgW = winSize.width - delta
	local bgH = bgW
	bg:setTextureRect(cc.size(bgW, bgH))
	bg:setPosition(cc.p(winSize.width / 2, winSize.height/2))

	local midPointArr = {}--每个固定单元格的中心点
	--创建背景单元格
	local elemBgW = (bgW - 5 * delta) / 4
	local elemBgH = elemBgW
	local drawnode = cc.DrawNode:create()
	drawnode:addTo(bg)
	for i=MAXROW,1, -1 do
		for j=1,MAXCOL do
			local p1 = cc.p(delta*(j)+elemBgW*(j-1), delta * i + elemBgH*(i-1))
			local p2 = cc.p(delta*(j)+elemBgW*(j), delta * i + elemBgH*(i-1))
			local p3 = cc.p(delta*(j)+elemBgW*(j), delta * i + elemBgH*(i))
			local p4 = cc.p(delta*(j)+elemBgW*(j-1), delta * i + elemBgH*(i))
			drawnode:drawRect(p1,p2,p3,p4,cc.c4b(1, 0, 0, 1))
			table.insert(midPointArr, cc.p(((delta*(j)+elemBgW*(j-1))+(delta*(j)+elemBgW*(j)))/2,
				((delta * i + elemBgH*(i-1))+(delta * i + elemBgH*(i)))/2))
			-- drawnode:drawDot(midPointArr[#midPointArr], 10, cc.c4b(1,0,0,1))
		end
	end

	--创建移动单元格,以及格子容器
	for i=1,MAXROW * MAXCOL do
		local cell = cell:create()
		table.insert(self.cellTable, cell)
		local row = math.floor((i-1) / 8)
		local col = (i-1) % 8
		cell:addTo(bg)
		cell:setPosition(cc.p(50+(col)*70, -70 * (row)-100))
		cell:setBornPoint(cc.p(50+(col)*70, -70 * (row)-100))
		-- cell:setVisible(false)
		cell:setNo(math.pow(2,i%12))
		local cellCT = cellContainer.new()
		cellCT:setIndex(i)
		cellCT:bindPosition(midPointArr[i])
		table.insert(self.cellContainers, cellCT)
	end
end

function GameLayer:startGame()
	--首次随机生成两个单元格
	for i=1,2 do
		self:randGenerateCell(2)
	end
end

function GameLayer:randGenerateCell(num)
	local result, row, col = State.Rand(num)
	if not result then 
		print("no more State cell...")
		return
	end
	local index = (row-1) * MAXCOL + col
	local cellCT = self.cellContainers[index]
	local cell = self:getACell()
	cellCT:setCell(cell)
	-- cellCT:dump("cellCT")
	local pos = cellCT:getBasePos()
	cell:setVisible(true)
	cell:setPosition(pos)
	cell:appear()
	cell:setNo(num)
end

function GameLayer:getACell()
	--从数组尾部取出cell
	local cell = self.cellTable[#self.cellTable]
	assert(cell)
	self.cellTable[#self.cellTable] = nil
	return cell
end

--[[
和getACell配合使用个，使用完的格子回收放在数组最前面
]]
function GameLayer:recycleCell(cell)
	table.insert(self.cellTable, 1, cell)
	cell:setPosition(cell:getBornPoint()) --回到原位
end

function GameLayer:canMove()
	local canMove = State.canMove()
	return canMove
end

function GameLayer:gameOver(isSuccess)
	print("Game Over...")
	if not self.gameOverLab then
		local winSize = cc.Director:getInstance():getWinSize()
		self.gameOverLab = cc.Label:createWithTTF("Game Over", "FZY4JW.TTF", 40)
		self.gameOverLab:addTo(self)
		self.gameOverLab:setPosition(cc.p(winSize.width / 2, winSize.height - 100))
	end
	local desc = isSuccess and "You Win" or "Game Over"
	self.gameOverLab:setString(desc)
	local zoomIn = cc.ScaleTo:create(0.05,0.8)
	local zoomOut = cc.ScaleTo:create(0.05,1.2)
	local zoomOut2 = cc.ScaleTo:create(0.05,1.0)
	local act = transition.sequence({zoomIn, zoomOut, zoomOut2})
	self.gameOverLab:runAction(act)
	self.gameOverLab:setVisible(true)
	self.restartBtn:setVisible(true)
	if isSuccess then
		--Todo:放点彩蛋，分享啥的
	end
end

function GameLayer:onEnter( )
	self.super:onEnter()
end

function GameLayer:onExit( )
	self.super:onExit()
end

return GameLayer