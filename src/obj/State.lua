local State = {}

--当前空余位置
local empty = {}
local DataModle = {}
--4*4
local maxRow = 4
local maxCol = 4
local randTotalCount = 0

-- local randPos = function ()
-- 	local pos = -1
-- 	if #empty > 0 then
-- 		math.randomseed(tostring(os.time()):reverse():sub(1, 6))
-- 		-- math.randomseed(tostring(os.time()))
-- 		local index = math.random(#empty)
-- 		pos = empty[index]
-- 		empty[index] = nil
-- 		table.remove(empty, index)
-- 	end
-- 	return pos
-- end

function transform2Pos (index)
	local row = math.floor((index-1) / maxRow) + 1
	local col = (index-1) % maxCol + 1
	return row, col
end

function transform2Index(row, col)
	return (row-1) * maxCol + col
end

local updateEmptyArr = function ()
	local index = 0
	for i,v in ipairs(DataModle) do
		for i,v in ipairs(v) do
			index = index + 1
			if v == 0 then
				empty[index] = index
			else
				empty[index] = 0
			end
		end
	end
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

function State.randPos()
	print("\nstart rand pos")
	local pos = -1
	local validPos = {}
	local index = 0
	updateEmptyArr()
	dump(empty, "rand empty")
	for i,v in ipairs(empty) do
		if v ~= 0 then
			validPos[#validPos+1] = v
		end
	end
	local str = ""
	for i,v in ipairs(validPos) do
		str = str .. tostring(v) .. " "
	end
	print("validPos ", str)
	if #validPos > 0 then
		math.randomseed(tostring(os.time()):reverse():sub(1, 6))
		local index = math.random(#validPos)
		pos = validPos[index]
		empty[pos] = 0
		local row , col = transform2Pos(pos)
		DataModle[row][col] = 2
		randTotalCount = randTotalCount + 1
		print("rand pos =", pos, " randTotalCount ", randTotalCount)
	end
	updateEmptyArr()
	print("after rand pos")
	dump(empty, "empty ")
	printModel("model")
	return pos
end

function State.init()
	for i=1,maxRow do
		DataModle[i] = {}
		for j=1, maxCol do
			DataModle[i][j] = 0
			local index = (i-1)*maxRow+j
			empty[index] = index
		end
	end
	printModel("Data init...")
end

function State.get(dir)
	local vTable = {}
	if dir == "V" then
		for i=1,maxCol do
			vTable[i] = {}
			for j=1,maxRow do
				vTable[i][j]= DataModle[j][i]
			end
		end
	else
		vTable = DataModle
	end
	return vTable
end

-- local 



-- function State.Move(dir)
-- 	local t = nil
-- 	if dir == "up" or dir == "down" then
-- 		t = State.get("V")
-- 	else 
-- 		t = State.get("H")
-- 	end
-- 	if dir == "up" then

-- 	else if dir == "down" then
-- 		local stack = {}
-- 		--竖直方向4个数合并
-- 		for i,v in ipairs(t) do
-- 			--对当前4个数字进行比较
-- 			for i,v in ipairs(v) do
-- 				if v ~= 0 then
-- 					if stack[#stack] ~= v then
-- 						table.insert(stack, v)
-- 					else
-- 						stack[#stack] = 2*v
-- 					end
-- 				end
-- 			end
			
-- 		end

-- 	else if dir == "left" then

-- 	else if dir == "right" then

-- 	end
-- end

function State.move(dir, index)
	print("State move dir ", dir , " index ", index)
	local row, col = transform2Pos(index)
	local t = nil
	local moveTo = index
	local stack = {}
	if dir == "up" or dir == "down" then
		t = State.get("V")
		-- row, col = col, row
	else 
		t = State.get("H")
	end

	--值为0无需移
	if DataModle[row][col] == 0 then
		return moveTo
	end

	if dir == "left" then
		--第一列不用左移
		if col == 1 then return moveTo end
		for i=1,col do
			print("ooo ", i, "row ", row)
			local insertV = t[row][i]
			if t[row][i] ~= 0 then
				table.insert(stack, insertV)
			end
			if i == col and stack[#stack-1] == stack[#stack] then
				insertV = 2 * insertV
				table.remove(stack,#stack)
				table.remove(stack,#stack)
				table.insert(stack, insertV)
			end
		end
		moveTo = transform2Index(row, #stack)
		--发生移动，更新state
		if index ~= moveTo then
			for i=1,#stack do
				DataModle[row][i] = stack[i]
			end
			--置为空
			DataModle[row][col] = 0
		end
	elseif dir == "right" then
		--最后一列不用左移
		if col == maxCol then return moveTo end
		for i=maxCol,col, -1 do
			local insertV = t[row][i]
			if t[row][i] ~= 0 then
				table.insert(stack, insertV)
			end
			dump(stack, "stack 1 = ")
			if i == col and stack[#stack-1] == stack[#stack] then
				insertV = 2 * insertV
				table.remove(stack,#stack)
				table.remove(stack,#stack)
				table.insert(stack, insertV)
			end
		end
		dump(stack, "stack  2 = ")
		moveTo = transform2Index(row, maxCol+1-#stack)
		--发生移动，更新state
		if index ~= moveTo then
			for i=1,#stack do
				DataModle[row][maxCol+1-i] = stack[i]
			end
			--置为空
			DataModle[row][col] = 0
		end
	elseif dir == "up" then
		--第一行不用上移
		if row == 1 then return moveTo end
		for i=1,row do
			local insertV = t[col][i]
			if t[col][i] ~= 0 then
				table.insert(stack, insertV)
			end
			if i == row and stack[#stack-1] == stack[#stack] then
				insertV = 2 * insertV
				table.remove(stack,#stack)
				table.remove(stack,#stack)
				table.insert(stack, insertV)
			end
		end
		print("dump stack")
		for i,v in ipairs(stack) do
			print(i,v)
		end
		print("#stack ", #stack, " col ", col)
		moveTo = transform2Index(#stack, col)
		print("index ", index, " moveTo ", moveTo)
		--发生移动，更新state
		if index ~= moveTo then
			for i=1,#stack do
				DataModle[i][col] = stack[i]
			end
			--置为空
			DataModle[row][col] = 0
		end
	elseif dir == "down" then
		--第一行不用下移
		if row == maxRow then return moveTo end
		for i=maxRow, row, -1 do
			local insertV = t[col][i]
			if t[col][i] ~= 0 then
				table.insert(stack, insertV)
			end
			if i == row and stack[#stack-1] == stack[#stack] then
				insertV = 2 * insertV
				table.remove(stack,#stack)
				table.remove(stack,#stack)
				table.insert(stack, insertV)
			end
		end
		moveTo = transform2Index(maxRow+1-#stack, col)
		--发生移动，更新state
		if index ~= moveTo then
			for i=1, #stack do
				DataModle[maxRow+1-i][col] = stack[i]
			end
			--置为空
			DataModle[row][col] = 0
		end
	end

	printModel("after move " .. dir .. " index " .. index)
	return moveTo
end

function State.testMove(dir)
	for i=1,16 do
		State.move(dir, i)
	end
	State.randPos()
	printModel()
end

State.init()
for i=1,2 do
	local index = State.randPos()
	local row , col = transform2Pos(index)
	DataModle[row][col] = 2
end

-- State.testMove("left")
-- State.testMove("left")
-- State.testMove("left")

State.testMove("right")
-- State.testMove("right")
-- State.testMove("right")

-- State.testMove("down")
-- State.testMove("down")
-- State.testMove("down")
-- State.testMove("up")
-- State.testMove("up")
-- State.testMove("up")
-- State.testMove("up")
