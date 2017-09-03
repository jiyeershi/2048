for i=1, 1, -1 do
	print(i)
end

-- if dir == "aa" then
-- 	local mmm = 0
-- else if dir == "up" then
-- 	--第一行不用上移
-- 	if row == 1 then return moveTo end
-- 	for i=1,row do
-- 		if t[col][i] ~= 0 then
-- 			local insertV = t[col][i]
-- 			table.insert(stack, insertV)
-- 		end
-- 		if i == row and stack[#stack] == t[col][i] then
-- 			insertV = 2 * insertV
-- 			table.remove(#stack)
-- 			table.insert(stack, insertV)
-- 		end
-- 	end
-- 	moveTo = transform2Index(#stack, col)
-- 	--发生移动，更新state
-- 	if index ~= moveTo then
-- 		for i=1,#stack do
-- 			DataModle[i][col] = stack[i]
-- 		end
-- 	end
-- else if dir == "down" then
-- 	--第一行不用下移
-- 	if row == maxRow then return moveTo end
-- 	for i=maxRow, row, -1 do
-- 		if t[col][i] ~= 0 then
-- 			local insertV = t[col][i]
-- 			table.insert(stack, insertV)
-- 		end
-- 		if i == row and stack[#stack] == t[col][i] then
-- 			insertV = 2 * insertV
-- 			table.remove(#stack)
-- 			table.insert(stack, insertV)
-- 		end
-- 	end
-- 	moveTo = transform2Index(maxRow+1-#stack, col)
-- 	--发生移动，更新state
-- 	if index ~= moveTo then
-- 		for i=1, #stack do
-- 			DataModle[maxRow+1-i][col] = stack[i]
-- 		end
-- 	end
-- end

m = 1
if m == 0 then
	print("m == 0")
else if m == 1 then
	print("m == 1")
else if m == 2 then
	print("m == 2")
end