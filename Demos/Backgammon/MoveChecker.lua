-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

require ('L#')
require("Backgammon")

_moveErrorDice = "	FORBIDDEN MOVE: Move must use the dice values"
_moveErrorHome = "	FORBIDDEN MOVE: Not all stones are at the homeboard"
_moveErrorBack = "	FORBIDDEN MOVE: Wrong movement direction"
_moveErrorStone = "	FORBIDDEN MOVE: Move your own stones!"
_moveErrorNoBeated = "	FORBIDDEN MOVE: No beated stone to put back in game"
_moveErrorEmpty = "	FORBIDDEN MOVE: There is no stone in the indicated position"
_moveErrorOccupied = "	FORBIDDEN MOVE: The goal point is already occupied by the other player"
_moveErrorFull = "	FORBIDDEN MOVE: The goal point is already full"
_moveErrorBeated = "	FORBIDDEN MOVE: There are beated stones to be moved first"

_diceError = "	FORBIDDEN: This dice value was already used"
_valuesError = "	FORBIDDEN: Values are outside the board [0,25]"

-- MoveChecker Aspekte
Aspect{"MoveChecker",adapts={Backgammon},attributes={},
before={checkMove="moveStone", initAspect="start", },after={initAspect="changePlayer"}}

-- Executed before start()
function MoveChecker:initAspect()
	self.d1 = true
	self.d2 = true

	return true
end

-- Executed before moveStone()
function MoveChecker:checkMove(input)
	if input == nil then
		print("	NO INPUT GIVEN")
		return false
	end
	if self.board == nil then
		print("	GAME IS NOT STARTED")
	end

--~ 	printd("Checking input for syntax error...")
	local num1 = 0
	local num2 = 0

	num1,num2 = splitNumericalString(input)
	if num1 == nil or num2 == nil then
		print("	SYNTAX ERROR IN INPUT: "..input)
		return false
	else
		-- The numbers are still represented as strings
		num1 = tonumber(num1)
		num2 = tonumber(num2)

		-- Check the values interval
		if num1 < 0 or num1 > 24 then
			print(_valuesError)
			return false
		elseif num2 < 0 or num2 > 25 then
			print(_valuesError)
			return false
		end

--~ 		printd("Checking the rules...")

		-------------------------
		-- Rule: all beated stones must get back before normal play
		-------------------------
		if self.playing == "white" then
			if self.board:getBeatedWhite() > 0 then
				if num1 ~= 0 then
					print(_moveErrorBeated)
					return false
				end
			end
		elseif self.playing == "black" then
			if self.board:getBeatedBlack() > 0 then
				if num1 ~= 0 then
					print(_moveErrorBeated)
					return false
				end
			end
		end

		-------------------------
		-- Rule: Moving beated stone back in the game
		-------------------------
		if num1 == 0 then
			if self.playing == "white" then
				if self.board:getBeatedWhite() <= 0 then
					print(_moveErrorNoBeated)
					return false
				end
			elseif self.playing == "black" then
				if self.board:getBeatedBlack() <= 0 then
					print(_moveErrorNoBeated)
					return false
				end
			end
		end

		-------------------------
		-- Rule: Sending stone home only when Home is full
		-------------------------
		if num2 == 25 or num2 == 0 then
			if self.playing == "white" then
				if self.board:isWhiteHomeFull() ~= true then
					print(_moveErrorHome)
					return false
				end
			elseif self.playing == "black" then
				if self.board:isBlackHomeFull() ~= true then
					print(_moveErrorHome)
					return false
				end
			end
		end

		-------------------------
		-- Rule: A Player cannot move his opponent's stones
		-------------------------
		if num1 ~= 0 and num1 ~= 25 then
			local color = self.board:getPlayerFromPosition(num1)
			if color == "empty" then
				print(_moveErrorEmpty)
				return false
			elseif color ~= self.playing then
				print(_moveErrorStone)
				return false
			end
		end

		-------------------------
		-- Rule: A player cannot move a stone to a point occupied by the opponent
		-------------------------
		if num2 ~= 0 and num2 ~= 25 then
			local color = self.board:isOccupied(num2)
			if color ~= self.playing then
				if color ~= "empty" then
					print(_moveErrorOccupied)
					return false
				end
			end
		end

		-------------------------
		-- Rule: No more than 5 stones per Point
		-------------------------
		if num2 ~= 0 and num2 ~= 25 then
			local stone = self.board:getTopStone(num2)
			if stone ~= "empty" then
				print(_moveErrorFull)
				return false
			end
		end

		-------------------------
		-- Rule: direction of playing
		-------------------------
		local diff = 0
		if self.playing == "white" then
			diff = num2-num1
			if diff < 0 and num1 ~= 0 then
				print(_moveErrorBack)
				return false
			end
		elseif self.playing == "black" then
			diff = num1-num2
			if diff < 0 and num1 ~= 0 then
				print(_moveErrorBack)
				return false
			elseif num1 == 0 then
				diff = 25 - num2
			end
		end

		-------------------------
		-- Rule: Using dice value
		-------------------------

		-- If they have the same value
		if self.dice1 == self.dice2 then
			if diff == self.dice1 then
				if self.d1 then
					self.d1 = false
					self.dice1 = 0
					return true
				elseif self.d2 then
					self.d2 = false
					self.dice2 = 0
					return true
				else
					print(_diceError)
					return false
				end
			end
		end

		if diff == self.dice1 then
			-- using first dice value
			if self.d1 then
				self.d1 = false
				self.dice1 = 0
				return true
			else
				print(_diceError)
				return false
			end
		elseif diff == self.dice2 then
			-- using second dice value
			if self.d2 then
				self.d2 = false
				self.dice2 = 0
				return true
			else
				print(_diceError)
				return false
			end
--~ 		elseif diff == self.dice1+self.dice2 then
--~ 			-- using both dice values
--~ 			if self.d1 and self.d2 then
--~ 				self.d1 = false
--~ 				self.d2 = false
--~ 				self.dice1 = 0
--~ 				self.dice2 = 0
--~ 			else
--~ 				print(_diceError)
--~ 				return false
--~ 			end
		elseif num2 == 25 or num2 == 0 then
			if diff < self.dice1 and diff < self.dice2 then
				-- use the smaller value first
				if self.dice1 <= self.dice2 then
					if self.d1 then
						self.d1 = false
						self.dice1 = 0
						return true
					elseif self.d2 then
						self.d2 = false
						self.dice2 = 0
						return true
					else
						print(_diceError)
						return false
					end
				else
					if self.d2 then
						self.d2 = false
						self.dice2 = 0
						return true
					elseif self.d1 then
						self.d1 = false
						self.dice1 = 0
						return true
					else
						print(_diceError)
						return false
					end
				end
			elseif diff < self.dice1 then
				if self.d1 then
					self.d1 = false
					self.dice1 = 0
					return true
				else
					print(_diceError)
					return false
				end
			elseif diff < self.dice2 then
				if self.d2 then
					self.d2 = false
					self.dice2 = 0
					return true
				else
					print(_diceError)
					return false
				end
			else
				print(_moveErrorDice)
				return false
			end
		else
			print(_moveErrorDice)
			return false
		end
	end

	return true
end
