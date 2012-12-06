-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

require("Backgammon")
require("MoveChecker")
require("MoveLogger")

--~ Rules:
--~ 0 = must use the dice values
--~ 1 = beating stones
--~ 2 = Origin point is empty
--~ 3 = Destination point occupied
--~ 4 = Syntax error
--~ 5 = Restarting
--~ 6 = try to use the same dice value again
--~ 7 = Moving beated stone back into the game (black and white)
--~ 8 = Moving stone out of the board (black and white)
--~ 9 = Winning the game (black)
--~ 10 = Winning the game (white)
--~ 11 = Destination Point is full (5 stones)
--~ 12 = cannot move opponent stones
--~ 13 = Big game with a restart in the middle and console in the end

rule = 13
logging = false

BGgame = Backgammon:new()

MoveChecker:enable()

if logging then
	MoveLogger:enable()
end

BGgame:start(false)
--~ BGgame:print()

if rule == 0 then
	BGgame:setDice(1,6)
	BGgame:moveStone("24 22") -- 4 ERROR
	BGgame:moveStone("13 10") -- 3 ERROR
	BGgame:moveStone("6 2")   -- 4 ERROR
	BGgame:moveStone("24 18") -- 6 OK
	BGgame:moveStone("18 17") -- 1 ERROR
	BGgame:print()
end
if rule == 1 then
	MoveChecker:disable()
	BGgame:moveStone("24 18")
	BGgame:moveStone("19 11")
	BGgame:moveStone("6 2")
	MoveChecker:enable()
	BGgame:print()
	BGgame:setDice(2, 1)
	BGgame:moveStone("13 11") 	-- OK - beat white stone on 11
	BGgame:moveStone("2 1")		-- ERROR - Cannot beat 2 stones
	BGgame:moveStone("6 5")		-- OK - normal movement
	BGgame:setDice(1, 2)
	BGgame:print()		-- White Plays with 1, 2
	BGgame:moveStone("0 2")	-- OK - put white stone back and beat black stone
	BGgame:moveStone("17 18")	-- OK - beat black stone
	BGgame:print()		-- Black Plays
	MoveChecker:disable()
	BGgame:moveStone("17 23")
	BGgame:moveStone("12 22")
	BGgame:moveStone("12 21")
	BGgame:moveStone("12 20")
	MoveChecker:enable()
	BGgame:setDice(2, 4)
	BGgame:moveStone("0 23")	-- OK - beat white stone
	BGgame:moveStone("0 21")	-- OK - beat white stone
	BGgame:print()		-- White Plays
	BGgame:setDice(1, 2)
	BGgame:moveStone("20 21")	-- ERROR
	BGgame:moveStone("22 24")	-- ERROR
	BGgame:changePlayer()	-- Black Plays
	BGgame:moveStone("21 20")	-- OK - beat white stone
	BGgame:moveStone("24 22")	-- OK - beat white stone
	BGgame:print()		-- White Plays
	BGgame:setDice(2, 5)
	BGgame:moveStone("0 2")		-- OK - put white stone back
	BGgame:moveStone("0 5")		-- OK - beat black stone
	BGgame:print()

end
if rule == 2 then
	BGgame:print()
	BGgame:moveStone("20 19")	-- ERROR
	BGgame:moveStone("0 22")	-- ERROR
	BGgame:moveStone("02 0")	-- ERROR
	BGgame:moveStone("05 01")	-- ERROR
	BGgame:moveStone("23 25")	-- ERROR
end
if rule == 3 then
	BGgame:setDice(5, 1)
	BGgame:moveStone("24 19")	-- ERROR
	BGgame:moveStone("13 12")	-- ERROR
	BGgame:moveStone("24 23")	-- OK
	BGgame:moveStone("6 1")		-- ERROR
	BGgame:moveStone("8 3")		-- OK
	BGgame:print()		-- White Plays
	BGgame:setDice(1, 5)
	BGgame:moveStone("1 6")		-- ERROR
	BGgame:moveStone("12 13")	-- ERROR
end
if rule == 4 then
	BGgame:moveStone("hehehehehe")	-- ERROR
	BGgame:moveStone("1243 222222j")-- ERROR
	BGgame:moveStone("12, 2")		-- ERROR
	BGgame:moveStone("12-2")		-- ERROR
	BGgame:moveStone("13 , 15")		-- ERROR
	BGgame:moveStone(",24 20,,")	-- Like "24 20"
	BGgame:moveStone("123 4")		-- ERROR
	BGgame:moveStone("0 292")		-- ERROR
	BGgame:moveStone("1 26")		-- ERROR
	BGgame:moveStone("-1 24")		-- Like "1 24"
	BGgame:moveStone("25 21")		-- ERROR
end
if rule == 5 then
--~ 	BGgame:setDice(1, 2)
	BGgame:moveStone("6 5")
	BGgame:print()
	BGgame:restart()
	BGgame:restart()
	BGgame:restart()
	BGgame:print()
end
if rule == 6 then
	BGgame:setDice(3,5)
	BGgame:print()
	BGgame:moveStone("13 10")	-- OK, use the 3
	BGgame:moveStone("6 3")		-- ERROR, using again the 3
end
if rule == 7 then

end
if rule == 8 or rule == 9 or rule == 10 then
	BGgame:moveStone("6 0")		-- ERROR
	MoveChecker:disable()
	BGgame:moveStone("6 0") 	-- OK, checker disabled
	for i = 0, 5 do
		BGgame:moveStone("13 5")
		BGgame:moveStone("8 4")
		BGgame:moveStone("24 2")
	end
	BGgame:print()
	MoveChecker:enable()
	BGgame:setDice(4,2)
	BGgame:moveStone("2 0")		-- OK, goes out
	BGgame:moveStone("5 0")		-- ERROR
	BGgame:moveStone("2 0")		-- OK
	MoveChecker:disable()
	for i = 0, 5 do
		BGgame:moveStone("12 20")
		BGgame:moveStone("17 22")
		BGgame:moveStone("1 24")
	end
	BGgame:print()
	MoveChecker:enable()
	BGgame:setDice(6,6)
	BGgame:moveStone("24 25")	-- OK
	BGgame:moveStone("4 0")		-- ERROR, opponent stone
	BGgame:moveStone("22 25")	-- OK
	BGgame:print()
	MoveChecker:disable()
	BGgame:moveStone("19 1")
	MoveChecker:enable()
	BGgame:setDice(1, 2)
	BGgame:moveStone("1 0")		-- ERROR, opponent stone
	if rule == 9 then
		MoveChecker:disable()
		for i = 1, 5 do
			BGgame:moveStone("4 0")
			BGgame:moveStone("5 0")
		end
		for i = 1, 3 do
			BGgame:moveStone("6 0")
		end
		BGgame:moveStone("6 5")
		BGgame:print()	-- Before finishing the game
		MoveChecker:enable()
		BGgame:setDice(6, 5)
		BGgame:moveStone("5 0")		-- End the game, black wins
	end
	if rule == 10 then
		MoveChecker:disable()
		BGgame:moveStone("1 25")
		for i = 1, 5 do
			BGgame:moveStone("19 25")
			BGgame:moveStone("20 25")
		end
		for i = 1, 3 do
			BGgame:moveStone("22 25")
		end
		BGgame:print()	-- Before finishing the game
		MoveChecker:enable()
		BGgame:setDice(1, 3)
		BGgame:moveStone("5 4")
		BGgame:moveStone("4 1")
		BGgame:setDice(6, 5)
		BGgame:moveStone("24 25")		-- End the game, white wins
	end
end
if rule == 11 then
	BGgame:setDice(1, 2)
	BGgame:moveStone("8 6")
--~ 	BGgame:print()
end

if rule == 12 then
	BGgame:print()
	BGgame:moveStone("17 18")	-- ERROR
	BGgame:moveStone("17 16")	-- ERROR
	BGgame:moveStone("1 0")		-- ERROR
end
if rule == 13 then
	BGgame:setDice(5, 1)
	--~ BGgame:moveStone("24 19")
	BGgame:moveStone("24 23")
	BGgame:moveStone("13 8")
	--~ BGgame:print()
	printd("WHITE PLAYER NOW")
	BGgame:setDice(1, 4)
	--~ BGgame:print()
	BGgame:moveStone("12 13")
	BGgame:moveStone("19 23")
	BGgame:moveStone("17 18")
	printd("BLACK PLAYER NOW")
	--~ BGgame:print()
	printd("DISABLING MOVECHECKER")
	MoveChecker:disable()

	for i = 1, 5 do
		BGgame:moveStone("13 2")
	end

	for i = 1, 4 do
		BGgame:moveStone("8 3")
	end

	for i = 1, 2 do
		BGgame:moveStone("24 3")
	end

	--~ BGgame:print()

	printd("ENABLING MOVECHECKER")
	MoveChecker:enable()
	printd("BLACK MUST CONTINUE")
	BGgame:setDice(2,1)
	--~ BGgame:print()

	BGgame:moveStone("3 0")
	BGgame:moveStone("0 23")
	BGgame:moveStone("3 0")
	--~ BGgame:print()

	printd("DISABLING MOVECHECKER")
	MoveChecker:disable()
	BGgame:moveStone("23 4")
	--~ BGgame:print()
	printd("ENABLING MOVECHECKER")
	MoveChecker:enable()
	BGgame:setDice(3, 6)
	--~ BGgame:print()
	BGgame:moveStone("6 0")
	BGgame:moveStone("2 0")
	printd("WHITE PLAYER NOW")
	--~ BGgame:print()

	printd("DISABLING MOVECHECKER")
	MoveChecker:disable()

	for i = 1, 5 do
		BGgame:moveStone("12 24")
	end

	for i = 1, 4 do
		BGgame:moveStone("1 22")
	end

	for i = 1, 2 do
		BGgame:moveStone("17 23")
	end

	--~ BGgame:print()
	BGgame:moveStone("18 20")
	BGgame:moveStone("0 21")
	--~ BGgame:print()
	printd("ENABLING MOVECHECKER")
	MoveChecker:enable()
	BGgame:setDice(1,5)
	--~ BGgame:print()
	BGgame:moveStone("23 25") -- Normal move, using 5 value
	BGgame:moveStone("17 205") -- Syntax error
	BGgame:moveStone("blablabla") -- Syntax error
	BGgame:moveStone("19 0") -- error: wrong movement
	BGgame:moveStone("19 25") -- error: no dice value to use
	BGgame:moveStone("20 26") -- error: Syntax error
	BGgame:moveStone("24 25")
	printd("BLACK PLAYER NOW")
	BGgame:setDice(6,6)
	BGgame:moveStone("2 0")
	BGgame:moveStone("2 0")
	--~ BGgame:print()
	printd("WHITE PLAYER NOW")

	printd("DISABLING MOVECHECKER")
	MoveChecker:disable()
	for i = 1, 5 do
		BGgame:moveStone("3 0")
		BGgame:moveStone("6 0")
	end

	for i = 1, 4 do
		BGgame:moveStone("4 0")
	end
	--~ BGgame:print()

	printd("ENABLING MOVECHECKER")
	MoveChecker:enable()
	BGgame:moveStone("24 25")
	BGgame:moveStone("24 25")
	printd("BLACK PLAYER NOW")
	--~ BGgame:print()
	BGgame:setDice(2, 4)
	BGgame:moveStone("2 0")
	printd("THE GAME SHOULD END NOW")
	--~ BGgame:print()

	printd("DISABLING MOVECHECKER")
	MoveChecker:disable()

	printd("Moving all White stones to Home Board")
	for i = 1, 5 do
		BGgame:moveStone("17 20")
		BGgame:moveStone("12 21")
		BGgame:moveStone("1 23")
	end
	printd("DONE")
	printd("Moving one white out of the homeboard")
	BGgame:moveStone("19 18")
	printd("ENABLING MOVECHECKER")
	MoveChecker:enable()
	printd("setting dices(2, 5)")
	BGgame:setDice(2, 5)
	--~ BGgame:print()
	printd("Moving Black Stone, 24 22")
	BGgame:moveStone("24 22")
	printd("Moving Black Stone, 22 17")
	BGgame:moveStone("22 17")
	--~ BGgame:print()
	printd("WHITE PLAYER NOW")
	printd("setting dices(1, 6)")
	BGgame:setDice(1, 6)
	printd("Moving White Stone, 23 24")
	BGgame:moveStone("23 24")
	printd("Trying to go out but not all stones are home yet")
	BGgame:moveStone("21 25")
	printd("Moving White Stone, 18 24")
	BGgame:moveStone("18 24")
	printd("BLACK PLAYER NOW")
	printd("Needs to put stones back to the game before everything else")
	BGgame:moveStone("21 25")
	--~ BGgame:print()

	printd("DISABLING MOVECHECKER")
	MoveChecker:disable()

	printd("Moving all white stones out")
	for i = 1, 5 do
		BGgame:moveStone("19 25")
		BGgame:moveStone("20 25")
		BGgame:moveStone("21 25")
		BGgame:moveStone("24 25")
	end

	printd("Setting dices(3, 1)")
	BGgame:setDice(3,1)
	printd("ENABLING MOVECHECKER")
	MoveChecker:enable()
	printd("BLACK PLAYER NOW")
	printd("Moving Black Stone, 0 22")
	BGgame:moveStone("0 22")
	printd("Moving Black Stone, 8 7")
	BGgame:moveStone("8 7")
	printd("WHITE PLAYER NOW")
	printd("Setting Dices(1, 1)")
	BGgame:setDice(1,1)
	--~ BGgame:print()
	printd("Trying to move 23 25, but cannot")
	BGgame:moveStone("23 25")
	printd("Moving White Stone, 23 24")
	BGgame:moveStone("23 24")
	--~ BGgame:print()
	printd("Moving White Stone, 24 25")
	BGgame:moveStone("24 25")
	printd("THE GAME SHOULD END NOW AND THE WHITE WON")
	BGgame:start(true)
end
