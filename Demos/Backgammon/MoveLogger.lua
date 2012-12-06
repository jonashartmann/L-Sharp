-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

require ('L#')
require("Backgammon")

-- MoveLogger Aspekte
Aspect{"MoveLogger", adapts={Backgammon},attributes={file=table, player=String},
before={openFile = "start", getPlayerBeforeMove = "move", getPlayerBeforeChanging = "changePlayer"},
after={closeFile = "endGame", logMove = "move", logChangePlayer = "changePlayer", logStart = "init"}}

function MoveLogger:openFile()
	if io.type(file) ~= "file" then
--~ 		printd("opening file")
		file,e = io.open("BGLog.txt",'a+')
		if file == nil then
			error("ERROR Opening the log file! -> "..e)
			return false
		end
--~ 		file:write("FILE OPENED")
--~ 		file:flush()
	end

	return true
end

function MoveLogger:closeFile()
	if self.console then
--~ 		printd("Closing File")
		if io.type(file) ~= "file" then
			file:flush()
			file:close()
		end
	end
end

function MoveLogger:getPlayerBeforeMove()
	self.player = self:getPlayer()
	if io.type(file) ~= "file" then
		MoveLogger:openFile()
	end
end

function MoveLogger:getPlayerBeforeChanging()
	self.player = self:getPlayer()
	if io.type(file) ~= "file" then
		self:openFile()
	end
end

function MoveLogger:logMove(num1, num2)
	local p = ""
	if self:getPlayer() == "black" then
		p = "Schwarz"
	else
		p = "Weiss"
	end
	MoveLogger:logString(p.." setzt einen Stein von Point "..num1.." nach "..num2..", "..self:getTime().."\n")
end

function MoveLogger:logChangePlayer()
	local p = ""
	if self:getPlayer() == "black" then
		p = "Schwarz"
	else
		p = "Weiss"
	end

	MoveLogger:logString(p.." würfelt eine "..self.dice1.." und "..self.dice2..", "..self:getTime().."\n")
end
function MoveLogger:logStart()
	MoveLogger:logString("\n")
	MoveLogger:logString("Ein neues Spiel wird gestartet\n")
	MoveLogger:logString("\n")
end

function MoveLogger:logString(str)
--~ 	printd("LOG: "..str)
	file:write(str)
end

