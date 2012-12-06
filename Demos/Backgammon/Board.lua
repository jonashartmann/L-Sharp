-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

require ('L#')

do
local _empty = "  "
local _maxStones = 15

-- Board class
Class{"Board", array = {}, white = String, black = String,
	beatedBlack=Number, beatedWhite=Number,
	whiteCount=Number, blackCount=Number}

function Board:init()
	self.white = "W "
	self.black = "B "

	local i = 1
	while i <= 24 do
		self.array[i] = {}
		i = i + 1
	end
	for i,j in ipairs(self.array) do
		j[1] = _empty
		j[2] = _empty
		j[3] = _empty
		j[4] = _empty
		j[5] = _empty
	end

	self:initCheckers()
end

function Board:moveStone(source, dest, player)
	-- Remove the top stone from the source point
	local stone = self:removeStone(source, player)
	-- Add it to the top of the dest point
	local added = self:addStone(dest, stone)

	if stone == added then
		-- Stone sucessfully added
		return added
	else
		-- Stone was not added
		-- Put it back in its original place
		self:addStone(source,stone)
		return added
	end

	return added
end
-- return the top stone found in point
-- or an _empty signalizing the point was empty
-- param: point [, player= "W "]
-- player is used only if the point is outside the board
function Board:removeStone(point, player)
	if point > 0 and point < 25 then
		local pointRef = self.array[point]
		if pointRef == nil then
			return _empty
		end
		local j = 5
		while j > 0 do
			if pointRef[j] == self.white or pointRef[j] == self.black then
				local stone = pointRef[j]
				pointRef[j] = _empty
				return stone
			end
			j = j - 1
		end
		return _empty
	elseif point == 0 then
		if player == "white" then
			if self.beatedWhite > 0 then
				self.beatedWhite = self.beatedWhite - 1
				return self.white
			else return _empty
			end
		elseif player == "black" then
			if self.beatedBlack > 0 then
				self.beatedBlack = self.beatedBlack - 1
				return self.black
			else return _empty
			end
		else
			return _empty
		end
	end
end

-- return the stone string or
-- _empty if something was wrong
function Board:addStone(point,stone)
	if stone == _empty then
		return _empty
	end
	-- Point is inside the board, normal move
	if point > 0 and point < 25 then
		local pointRef = self.array[point]
		if pointRef == nil then
			return _empty
		end
		local j = 1
		while j <= 5 do
			if pointRef[j] == _empty then
				-- If the point has only one stone and this one is different from the one being added
				-- then this one stone is beated.
				if j == 2 and stone ~= pointRef[j-1] then
					if pointRef[j-1] == self.white then
						self.beatedWhite = self.beatedWhite + 1
					else
						self.beatedBlack = self.beatedBlack + 1
					end
					pointRef[j-1] = stone
					return stone
				else
					pointRef[j] = stone
					return stone
				end
			end
			j = j + 1
		end
		return _empty
	else
		-- Point is outside the board
		-- The stone goes home :)
		if stone == self.white then
			if self.whiteCount > 0 then
				self.whiteCount = self.whiteCount - 1
			end
		else
			if self.blackCount > 0 then
				self.blackCount = self.blackCount - 1
			end
		end
		return stone
	end
end

function Board:initCheckers()
	self.array[1][1] = self.white
	self.array[1][2] = self.white

	self.array[8][1] = self.black
	self.array[8][2] = self.black
	self.array[8][3] = self.black

	self.array[17][1] = self.white
	self.array[17][2] = self.white
	self.array[17][3] = self.white

	self.array[24][1] = self.black
	self.array[24][2] = self.black

	for k,v in ipairs(self.array[6]) do
		self.array[6][k] = self.black
	end
	for k,v in ipairs(self.array[12]) do
		self.array[12][k] = self.white
	end
	for k,v in ipairs(self.array[13]) do
		self.array[13][k] = self.black
	end
	for k,v in ipairs(self.array[19]) do
		self.array[19][k] = self.white
	end

	self.whiteCount = 15
	self.blackCount = 15
	self.beatedWhite = 0
	self.beatedBlack = 0

--~ 	printT(self.array,1)
end

function Board:draw()

	local line = ""
	local i = 13
	local bar = true
	while i <= 24 do
		if bar and i == 19 then
			line = line.."| "
			bar = false
		else
			line = line..i.." "
			i = i + 1
		end
	end
	-- Print the first row of numbers
	print(line)

	local j = 1
	while j <= 5 do
		line = ""
		i = 13
		bar = true
		while i <= 24 do
			if bar and i == 19 then
				line = line.."| "
				bar = false
			else
				line = line..self.array[i][j].." "
				i = i + 1
			end
		end
		-- Print the checkers
		print(line)
		j = j + 1
	end

	-- Print the empty line
	print("")

	local j = 5
	while j >= 1 do
		line = ""
		i = 12
		bar = true
		while i >= 1 do
			if bar and i == 6 then
				line = line.."| "
				bar = false
			else
				line = line..self.array[i][j].." "
				i = i - 1
			end
		end
		-- Print the checkers
		print(line)
		j = j - 1
	end

	line = ""
	i = 12
	bar = true
	while i >= 1 do
		if bar and i == 6 then
			line = line.."| "
			bar = false
		else
			if i < 10 then
				line = line.."0"..i.." "
			else
				line = line..i.." "
			end
			i = i - 1
		end
	end
	-- Print the last row of numbers
	print(line)
end


function Board:getBeatedWhite()
	return self.beatedWhite
end

function Board:getBeatedBlack()
	return self.beatedBlack
end

function Board:getBeatedTotal()
	local beatedTotal = ""
	local i = 0
	while i < self.beatedWhite do
		beatedTotal = beatedTotal..self.white
		i = i + 1
	end
	i = 0
	while i < self.beatedBlack do
		beatedTotal = beatedTotal..self.black
		i = i + 1
	end

	if beatedTotal == "" then
		beatedTotal = "keine"
	end

	return beatedTotal
end
function Board:getWhiteCount()
	return self.whiteCount
end

function Board:getBlackCount()
	return self.blackCount
end

-- returns true if all white stones are in the white homeboard
function Board:isWhiteHomeFull()
	local count = 0
	for point = 19, 24 do
		local pointRef = self.array[point]
		for j = 0, 5 do
			if pointRef[j] == self.white then
				count = count + 1
			end
		end
	end
--~ 	printd(count.."    "..self.whiteCount)
	--if count == _maxStones then
	if count == self.whiteCount then
		return true
	end

	return false
end

-- returns true if all black stones are in the black homeboard
function Board:isBlackHomeFull()
	local count = 0
	for point = 1, 6 do
		local pointRef = self.array[point]
		for j = 0, 5 do
			if pointRef[j] == self.black then
				count = count + 1
			end
		end
	end
	--if count == _maxStones then
	if count == self.blackCount then
		return true
	end

	return false
end



-- return "white" if the stone is white
-- "black" if it is black
-- or "empty" if there is no stone in this position
function Board:getPlayerFromPosition(pos)
	local col = self.array[pos]
	if col[1] == self.white then
		return "white"
	elseif col[1] == self.black then
		return "black"
	else
		return "empty"
	end
end

-- return "white" if the point is occupied by the white player
-- return "black" if the point is occupied by the black player
-- return "empty" if no player occupies the point
function Board:isOccupied(pos)
	local col = self.array[pos]
	if col[2] == self.white then
		return "white"
	elseif col[2] == self.black then
		return "black"
	else
		return "empty"
	end
end

function Board:getTopStone(point)
	local col = self.array[point]
	if col[5] == self.white then
		return "white"
	elseif col[5] == self.black then
		return "black"
	else
		return "empty"
	end
end
end
