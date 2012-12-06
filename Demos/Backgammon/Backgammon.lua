-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

require ('L#')
require("Board")

-- Split a string with numbers using space as separator
-- Only return the first two numbers
function splitNumericalString(str)
	_, _, n1, n2 = string.find(str, "(%d+) (%d+)")
	return n1,n2
end

-- Read console input
function readLine()
	return io.stdin:read'*l'
end

-- return a new table with the values of t
function copyTableValues(t)
	local tableValues = {}
	for k,v in pairs(t) do
		if type(v) == "table" then
			tableValues[k] = copyTableValues(v)
		else
			tableValues[k] = v
		end
	end
	return tableValues
end

-- Backgammon class
--
-- board, save the current state of the game
-- playing, the player whose turn it is (black/white)
-- dice1, the value of the first dice
-- dice2, the value of the second dice
-- gameTime, the game time
-- startTime, the time the current game started
-- beated-, the beated stones
Class{"Backgammon", board = Board, playing = String,
	dice1 = Number, dice2 = Number, gameTime = Number,
	console = Boolean, startTime = Number,
	d1=Boolean, d2=Boolean}

-- This is the main game loop
function Backgammon:run()
	if self.console then
		local cmd = ""
		while cmd ~= "end" do
			self:draw()
			print("Waiting for command: ")
			cmd = readLine()
			print("Processing \""..cmd.."\"...")
			print()
			self:processCommand(cmd)
		end
		if cmd == "end" then
			self:endGame()
		end
	end
end

function Backgammon:processCommand(cmd)
	if cmd == "end" then
		return
	elseif cmd == "restart" then
--~ 		printd("Restarting...")
		self:restart()
	elseif cmd == "next" then
--~ 		printd("Next Player")
		self:changePlayer()
	elseif cmd == "check" then
--~ 		printd("checking")
		self:check()
	elseif cmd == "log" then
--~ 		printd("logging")
		self:log()
	else
		self:moveStone(cmd)
	end
end

-- Move the stone from "source" to "dest"
function Backgammon:move(source,dest)
	local source = tonumber(source)
	local dest = tonumber(dest)
	if self.board then
		return self.board:moveStone(source,dest,self.playing)
	else
		print("ERROR: Game is not started")
		return false
	end
end
function Backgammon:moveStone(str)
	local num1 = 0
	local num2 = 0
	num1,num2 = splitNumericalString(str)

--~ 	print("	MOVING FROM "..num1.." TO "..num2)
	if self:move(num1,num2) then
		if self:isGameOver() then
			-- show the Winner and restart the game
			self:endGame()
			return true
		end

		if self:checkDiceUse() then
			return true
		else
			self:changePlayer()
			return true
		end
	else
		return false
	end
end


function Backgammon:restart()
	print("	GAME IS RESTARTING")
	self:init()
end

function Backgammon:check()
	if MoveChecker._switch.active then
		MoveChecker:disable()
	else
		MoveChecker:enable()
	end
end
function Backgammon:log()
	if MoveLogger._switch.active then
		MoveLogger:disable()
	else
		MoveLogger:enable()
	end
end

function Backgammon:printLogo()
	print()
	print("##########################")
	print("    Backgammon in L#      ")
	print("##########################")
	print()
end

-- Start the game
-- console = true, start game with user console commands allowed
-- console = false, start game without user console
function Backgammon:start(console)
	self:printLogo()

	self.console = console
	if console then
		print("Starting the game with console")
	else print("Starting the game without console...")
	end
	print()

	self:init()
	self:run()

end

-- Initializate the game
function Backgammon:init()
	-- init the board putting the checkers in their places
	if self.board then
		self.board:init()
	else
		self.board = Board:new()
		self.board:init()
	end

	-- Black player allways start playing
	self.playing = "black"

	self:rollDices()

	self.gameTime = 0

	self.d1 = true

	self.d2 = true

	self.startTime = os.time()
end

-- Draw the board and informations
function Backgammon:draw()
	print()
	if self.board then
		self.board:draw()
	else
		print("ERROR: Game is not started")
		return
	end
	print()

	str = self:getBeated(playing)

	print("Geschlagene Steine:  "..str)

	local player = ""
	if self:getPlayer() == "black" then
		player = "Schwarz"
	else
		player = "Weiss"
	end
	print(player.." ist am Zug und hat nutzbare "..self:getDiceValues()..", "..self:getTime())
	print()
end

function Backgammon:print()
	self:draw()
end
-- change to the next player and also return it
function Backgammon:nextPlayer()
	if self.playing == "black" then
		self.playing = "white"
	elseif self.playing == "white" then
		self.playing = "black"
	else
		error("undefined player",2)
	end
	return self.playing
end

function Backgammon:getPlayer()
	return self.playing
end

function Backgammon:changePlayer()
	self:nextPlayer()
	self:rollDices()
--~ 	printd("ROUND FINISHED")
end

-- return the number of beated stones of the player
function Backgammon:getBeated(player)
	if self.board then
		local board = self.board
		return board:getBeatedTotal()

--~ 		if player == "white" then
--~ 			return board.beatedWhite
--~ 		else
--~ 			return board.beatedBlack
--~ 		end
	else
		print("ERROR: Game was not started")
		return
	end
end

-- return the game time
function Backgammon:getTime()
	self.gameTime = os.time() - self.startTime
	return "Spielzeit: "..self.gameTime.."s"
end

-- return the dice's values
function Backgammon:getDiceValues()
	return "Wuerfelwerte: "..self.dice1.." "..self.dice2.." "
end

-- Give new values to the dices
function Backgammon:rollDices()
	math.randomseed( os.time() )
	math.random(); math.random(); math.random()
	self.dice1 = math.random(6)
	self.dice2 = math.random(6)

	self.d1 = true
	self.d2 = true
end
function Backgammon:setDice(d1,d2)
	self.dice1 = d1
	self.dice2 = d2
	self.d1 = true
	self.d2 = true
end

-- Return true if the game is over
-- false otherwise
function Backgammon:isGameOver()
	if self.board then
		if self.board:getWhiteCount() == 0 then
			return true
		elseif self.board:getBlackCount() == 0 then
			return true
		else
			return false
		end
	else
		print("	GAME IS NOT STARTED")
		return false
	end
end

-- Say who won the game and restart
function Backgammon:endGame()
	self:printLogo()
	print("	THE GAME IS OVER")
	print("	**********************")

	if self.board:getWhiteCount() == 0 then
		print("	** White player won **")
	elseif self.board:getBlackCount() == 0 then
		print("	** Black player won **")
	end

	print("	**********************")

	if self.console == false then
		self:restart()
	end
end

-- return true if there is still a dice value to be used
function Backgammon:checkDiceUse()
	if self.d1 or self.d2 then
		return true
	else
		return false
	end
end
