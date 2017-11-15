--[[
核心状态类:
实体为MAXROW*MAXCOL的二维数组，每次移动或合并后
更新状态数组
]]
local State = {}

--当前空余位置
local empty = {}
local DataModle = {}
--4*4
local maxRow = MAXROW
local maxCol = MAXCOL

function transform2Pos (index)
	local row = math.floor((index-1) / maxRow) + 1
	local col = (index-1) % maxCol + 1
	return row, col
end

function transform2Index(row, col)
	return (row-1) * maxCol + col
end

local dump = function( table , desc)
	assert(type(table) == "table" and type(desc) == "string")
	local str = desc
	for k,v in pairs(table) do
		str = str .. tostring(v) .. " "
	end
	print(str)
end


local printModel = function (title)
	print(title or "")
	-- print("model data ... ")
	for k,v in pairs(DataModle) do
		if type(v) == "table" then
			print(v[1], v[2], v[3], v[4])
		end
	end
	-- print("model data reverse ... ")
	-- for k,v in pairs(State.get("V")) do
	-- 	if type(v) == "table" then
	-- 		print(v[1], v[2], v[3], v[4])
	-- 	end
	-- end
	-- print("empty arr ... ")
	-- local str = ""
	-- for k,v in pairs(empty) do
	-- 	str = str .. tostring(v) .. " "
	-- end
	-- print(str)
end

State.printModel = printModel

function State.reset()
	empty = {}
	for i=1,maxRow do
		DataModle[i] = DataModle[i] or {}
		for j=1, maxCol do
			DataModle[i][j] = 0
			-- local index = (i-1)*maxRow+j
			-- empty[index] = index
		end
	end
end

function State.init()
	State.reset()
	printModel("Data init...")
end

function State.GetEmpty( ... )
	local empty = {}
	for i=1,maxRow do
		for j=1,maxCol do
			if DataModle[i][j] == 0 then
				table.insert(empty, (i-1)*maxRow+j)
			end
		end
	end
	return empty
end

function State.Rand(num)
	print("State.Rand")
	local empty = State.GetEmpty()
	if #empty == 0 then return false end --结束标记
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local index = math.random(#empty)
	-- print("State.Rand = ", index)
	local row, col = transform2Pos(empty[index])
	DataModle[row][col] = num or 2
	return true, row, col
end

--[[
算法：
移动方向上的所有单行或单列的所有格子进行移动合并的逻辑：
1、每个数组进行arr.length 轮比较，每一轮最多比较 i - mergePos 次(i为当前需要操作的元素的位置，mergePos为上一次合并元素的下一位置)
2、依次比较i号位元素与其前一个元素，
如果相等则两者合并到他们的靠前位置，查找结束，进行下一轮元素查找
如果不相等则区分前一位元素是否为0，为0，则两元素进行交换，然后继续向前查找
如果不相等且前一位置不为0，则进行下一轮查找
新增：0不移动
]]
local move = function(arr)
	local moveEleRule = {}
	local cur = 1
	local to = 1
	local lastMergePos = 1
	for i=1,maxCol do
		cur = i
		to = 1
		local isMerge = false
		local mergeRet = 0
		for j=i,lastMergePos,-1 do
			if j == 1 then break end
			if arr[j] == arr[j-1] and arr[j] ~= 0 then
				arr[j-1] = arr[j] * 2
				arr[j] = 0
				to = j-1
				lastMergePos = j+1 --更新mergePos 的位置，保证合并点及合并点之前的所有位置不再参与比较
				isMerge = true
				mergeRet = arr[j-1]
				break
			elseif arr[j-1] == 0 and arr[j] ~= 0 then
				local temp = arr[j]
				arr[j] = 0
				arr[j-1] = temp
				to = j-1
			-- elseif arr[j] == 0 then
			-- 	to = j
			else --不等于0
				to = j
				break
			end
		end
		--每个元素查找结束，记录移动的规则
		-- print(cur, to)
		table.insert(moveEleRule, {["cur"]=cur, ["to"]=to, ["isMerge"] = isMerge, ["mergeRet"]=mergeRet})
	end
	return moveEleRule
end

local printArr = function(arr)
	print("printArr---->begin")
	for k, v in pairs(arr) do
		print(k, v)
	end
	print("printArr---->end")
end

local printMatrix = function(arr)
	print("printMatrix---->begin")
	for k, v in pairs(arr) do
		for k,v in pairs(v) do
			print(k,v)
		end
	end
	print("printMatrix---->end")
end

function State.MoveDir(dir)
--按行进方向取出单行 或单列 数组
--[[
	1, 2, 3, 4,
	5, 6, 7, 8,
	9, 10, 11, 12,
	13, 14, 15, 16
 ]]
 	printModel("Move begin state:")
 	local ruleArr = {}
	if dir == MOVEUP then
		--向下取每一列，得到数组{1， 5， 9， 13}，{2， 6， 10， 14} ...
		local arr = {}
		for i=1,MAXCOL do
			arr[i] = {}
			for j=1,MAXROW do
				arr[i][j] = DataModle[j][i]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			--将rule 中的cur, 和 to 转换为绝对位置
			-- for k,v in ipairs(rule) do
			-- 	-- print(k,v)
			-- 	for k,v in pairs(v) do
			-- 		print(k,v)
			-- 	end
			-- end
			for k=1,#rule do
				rule[k].cur = i + (rule[k].cur-1)*MAXCOL
				rule[k].to =  i + (rule[k].to -1)*MAXCOL
				table.insert(ruleArr, rule[k])
				--更新DataModle数组
				DataModle[k][i] = arr[i][k]
			end
		end
	elseif dir == MOVEDOWN then
		--向上取每一列，得到数组{13, 9, 5, 1}, {14, 10, 6, 2}
		local arr = {}
		for i=1,MAXCOL do
			arr[i] = {}
			for j=MAXROW,1,-1 do
				arr[i][MAXROW-j+1] = DataModle[j][i]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			--将rule 中的cur, 和 to 转换为绝对位置
			-- for k,v in ipairs(rule) do
			-- 	-- print(k,v)
			-- 	for k,v in pairs(v) do
			-- 		print(k,v)
			-- 	end
			-- end
			for k=1,#rule do
				rule[k].cur = i + (MAXROW-rule[k].cur)*MAXCOL
				rule[k].to =  i + (MAXROW-rule[k].to )*MAXCOL
				table.insert(ruleArr, rule[k])
				--更新DataModle数组
				DataModle[k][i] = arr[i][MAXROW-k+1]
			end
		end

	elseif dir == MOVELEFT then
		--向左取每一列，得到数组{1, 2, 3, 4}, {5，6, 7, 8}
		local arr = {}
		for i=1,MAXROW do
			arr[i] = {}
			for j=1,MAXCOL do
				arr[i][j] = DataModle[i][j]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			--将rule 中的cur, 和 to 转换为绝对位置
			-- for k,v in ipairs(rule) do
			-- 	-- print(k,v)
			-- 	for k,v in pairs(v) do
			-- 		print(k,v)
			-- 	end
			-- end
			for k=1,#rule do
				rule[k].cur = (i-1)*MAXCOL + rule[k].cur
				rule[k].to =  (i-1)*MAXCOL + rule[k].to
				table.insert(ruleArr, rule[k])
				--更新DataModle数组
				DataModle[i][k] = arr[i][k]
			end
		end

	elseif dir == MOVERIGHT then
		--向取每一列，得到数组{4, 3, 2, 1}, {8, 7, 6, 5}
		local arr = {}
		for i=1,MAXROW do
			arr[i] = {}
			for j=MAXCOL,1,-1 do
				arr[i][MAXCOL-j+1] = DataModle[i][j]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			--将rule 中的cur, 和 to 转换为绝对位置
			-- for k,v in ipairs(rule) do
			-- 	-- print(k,v)
			-- 	for k,v in pairs(v) do
			-- 		print(k,v)
			-- 	end
			-- end
			for k=1,#rule do
				rule[k].cur = (i-1)*MAXCOL + (MAXCOL - rule[k].cur + 1)
				rule[k].to =  (i-1)*MAXCOL + (MAXCOL - rule[k].to + 1)
				table.insert(ruleArr, rule[k])
				--更新DataModle数组
				DataModle[i][k] = arr[i][MAXROW-k+1]
			end
		end
	end

	printModel("Move end  state:")
	return ruleArr
end

--仿照move函数 写一个判断是否还能移动的函数
function State.canMove()
	local empty = State.GetEmpty()
	if #empty ~= 0 then return true end --还有空位置，可以继续进行游戏
	--当前所有格子都有非0数据，如果不能有合并的项，则不能进行游戏
	local ruleArr = {}
	--监测向上移动 dir == MOVEUP
	--向下取每一列，得到数组{1， 5， 9， 13}，{2， 6， 10， 14} ...
		local arr = {}
		for i=1,MAXCOL do
			arr[i] = {}
			for j=1,MAXROW do
				arr[i][j] = DataModle[j][i]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			for k=1,#rule do
				if rule[k].isMerge then
					return true
				end
			end
		end
	--监测向下移动 dir == MOVEDOWN
	--向上取每一列，得到数组{13, 9, 5, 1}, {14, 10, 6, 2}
		local arr = {}
		for i=1,MAXCOL do
			arr[i] = {}
			for j=MAXROW,1,-1 do
				arr[i][MAXROW-j+1] = DataModle[j][i]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			for k=1,#rule do
				if rule[k].isMerge then
					return true
				end
			end
		end
	--监测向左移动 dir == MOVELEFT
	--向右取每一列，得到数组{1, 2, 3, 4}, {5，6, 7, 8}
		local arr = {}
		for i=1,MAXROW do
			arr[i] = {}
			for j=1,MAXCOL do
				arr[i][j] = DataModle[i][j]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			for k=1,#rule do
				if rule[k].isMerge then
					return true
				end
			end
		end
	--监测向右边移动 dir == MOVELEFT
	--向左取每一列，得到数组{4, 3, 2, 1}, {8, 7, 6, 5}
		local arr = {}
		for i=1,MAXROW do
			arr[i] = {}
			for j=MAXCOL,1,-1 do
				arr[i][MAXCOL-j+1] = DataModle[i][j]
			end
			--单列移动
			-- printArr(arr[i])
			local rule = move(arr[i])
			for k=1,#rule do
				if rule[k].isMerge then
					return true
				end
			end
		end
	return false
end

--[[
单独测试该类的运转
测试用例
]]
local testArr = {2,2,4,4}

local moveRule = move(testArr)
for i,v in ipairs(testArr) do
	print(i,v)
end

for i,v in pairs(moveRule) do
	for key,vl in pairs(v) do
		print(key,vl)
	end
end

return State
