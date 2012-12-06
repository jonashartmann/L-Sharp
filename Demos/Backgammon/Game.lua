-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

require("Backgammon")
require("MoveChecker")
require("MoveLogger")

local testBG = Backgammon:new()

MoveChecker:enable()
MoveLogger:enable()
testBG:start(false)

testBG:setDice(5, 1)
--~ testBG:moveStone("24 19")
testBG:moveStone("24 23")
testBG:moveStone("13 8")
--~ testBG:print()
printd("WHITE PLAYER NOW")
testBG:setDice(1, 4)
--~ testBG:print()
testBG:moveStone("12 13")
testBG:moveStone("19 23")
testBG:moveStone("17 18")
printd("BLACK PLAYER NOW")
--~ testBG:print()
printd("DISABLING MOVECHECKER")
MoveChecker:disable()

for i = 1, 5 do
	testBG:moveStone("13 2")
end

for i = 1, 4 do
	testBG:moveStone("8 3")
end

for i = 1, 2 do
	testBG:moveStone("24 3")
end

--~ testBG:print()

printd("ENABLING MOVECHECKER")
MoveChecker:enable()
printd("BLACK MUST CONTINUE")
testBG:setDice(2,1)
--~ testBG:print()

testBG:moveStone("3 0")
testBG:moveStone("0 23")
testBG:moveStone("3 0")
--~ testBG:print()

printd("DISABLING MOVECHECKER")
MoveChecker:disable()
testBG:moveStone("23 4")
--~ testBG:print()
printd("ENABLING MOVECHECKER")
MoveChecker:enable()
testBG:setDice(3, 6)
--~ testBG:print()
testBG:moveStone("6 0")
testBG:moveStone("2 0")
printd("WHITE PLAYER NOW")
--~ testBG:print()

printd("DISABLING MOVECHECKER")
MoveChecker:disable()

for i = 1, 5 do
	testBG:moveStone("12 24")
end

for i = 1, 4 do
	testBG:moveStone("1 22")
end

for i = 1, 2 do
	testBG:moveStone("17 23")
end

--~ testBG:print()
testBG:moveStone("18 20")
testBG:moveStone("0 21")
--~ testBG:print()
printd("ENABLING MOVECHECKER")
MoveChecker:enable()
testBG:setDice(1,5)
--~ testBG:print()
testBG:moveStone("23 25") -- Normal move, using 5 value
testBG:moveStone("17 205") -- Syntax error
testBG:moveStone("blablabla") -- Syntax error
testBG:moveStone("19 0") -- error: wrong movement
testBG:moveStone("19 25") -- error: no dice value to use
testBG:moveStone("20 26") -- error: Syntax error
testBG:moveStone("24 25")
printd("BLACK PLAYER NOW")
testBG:setDice(6,6)
testBG:moveStone("2 0")
testBG:moveStone("2 0")
--~ testBG:print()
printd("WHITE PLAYER NOW")

printd("DISABLING MOVECHECKER")
MoveChecker:disable()
for i = 1, 5 do
	testBG:moveStone("3 0")
	testBG:moveStone("6 0")
end

for i = 1, 4 do
	testBG:moveStone("4 0")
end
--~ testBG:print()

printd("ENABLING MOVECHECKER")
MoveChecker:enable()
testBG:moveStone("24 25")
testBG:moveStone("24 25")
printd("BLACK PLAYER NOW")
--~ testBG:print()
testBG:setDice(2, 4)
testBG:moveStone("2 0")
printd("THE GAME SHOULD END NOW")
--~ testBG:print()

printd("DISABLING MOVECHECKER")
MoveChecker:disable()

printd("Moving all White stones to Home Board")
for i = 1, 5 do
	testBG:moveStone("17 20")
	testBG:moveStone("12 21")
	testBG:moveStone("1 23")
end
printd("DONE")
printd("Moving one white out of the homeboard")
testBG:moveStone("19 18")
printd("ENABLING MOVECHECKER")
MoveChecker:enable()
printd("setting dices(2, 5)")
testBG:setDice(2, 5)
--~ testBG:print()
printd("Moving Black Stone, 24 22")
testBG:moveStone("24 22")
printd("Moving Black Stone, 22 17")
testBG:moveStone("22 17")
--~ testBG:print()
printd("WHITE PLAYER NOW")
printd("setting dices(1, 6)")
testBG:setDice(1, 6)
printd("Moving White Stone, 23 24")
testBG:moveStone("23 24")
printd("Trying to go out but not all stones are home yet")
testBG:moveStone("21 25")
printd("Moving White Stone, 18 24")
testBG:moveStone("18 24")
printd("BLACK PLAYER NOW")
printd("Needs to put stones back to the game before everything else")
testBG:moveStone("21 25")
--~ testBG:print()

printd("DISABLING MOVECHECKER")
MoveChecker:disable()

printd("Moving all white stones out")
for i = 1, 5 do
	testBG:moveStone("19 25")
	testBG:moveStone("20 25")
	testBG:moveStone("21 25")
	testBG:moveStone("24 25")
end

printd("Setting dices(3, 1)")
testBG:setDice(3,1)
printd("ENABLING MOVECHECKER")
MoveChecker:enable()
printd("BLACK PLAYER NOW")
printd("Moving Black Stone, 0 22")
testBG:moveStone("0 22")
printd("Moving Black Stone, 8 7")
testBG:moveStone("8 7")
printd("WHITE PLAYER NOW")
printd("Setting Dices(1, 1)")
testBG:setDice(1,1)
--~ testBG:print()
printd("Trying to move 23 25, but cannot")
testBG:moveStone("23 25")
printd("Moving White Stone, 23 24")
testBG:moveStone("23 24")
--~ testBG:print()
printd("Moving White Stone, 24 25")
testBG:moveStone("24 25")
printd("THE GAME SHOULD END NOW AND THE WHITE WON")
testBG:start(true)


