-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

-- Auxiliary functions
require("functions")

-- Aspect functions
function startAspect(...)
	if arg.n > 0 then
		local naspect = {}
		local t = arg[1]
		if type(t[1]) == String then
			_G[t[1]] = naspect
		else error("The first argument (Aspect name) must be a String",2)
		end
		newAspect(t)
	else
		error("No arguments to the function")
	end
end

-- Create a new aspect
function newAspect(t)
	local ref = _G[t[1]]
	ref._name = t[1]
	ref._adapts = {}
	ref._attributes = {}
	ref._before = {}
	ref._after = {}

	ref._methods = {}

	-- Enable/Disable switch
	ref._switch = { active = false }

	-- Enable function
	function ref:enable()
--~ 		printd("Enabling "..self._name)
		self._switch.active = true
	end
	-- Disable function
	function ref:disable()
--~ 		printd("Disabling "..self._name)
		self._switch.active = false
	end

	-- Parse the function parameter
	for key, value in pairs(t) do
		if key == "adapts" then
			-- ADAPTS
			if type(value) == "table" then
				-- Test to see if all are classes
				for k,class in pairs(value) do
					if type(class) == "table" then
						if class._name == nil then
							typeError("Class", type(class))
						end
					elseif class == "_invalid" then
						typeError("Class","nil")
					else
						typeError("Class",type(class))
					end
				end

				ref._adapts = value
			else typeError("table",type(value))
			end

		elseif key == "attributes" then
			-- ATTRIBUTES
			if type(value) == "table" then
				ref._attributes = value
			else typeError("table",type(value))
			end

		elseif key == "before" then
			-- BEFORE
			if type(value) == "table" then
				-- Validate the type
				for name, str in pairs(value) do
					if type(name) ~= String then
						error("ERROR: keys in Before table must be strings",3)
					end
					if str == "_invalid" or type(str) ~= String or str == Number or str == Boolean then
						error("ERROR: Values in Before table must be Strings",3)
					else
					end
				end

				ref._before = value
			else typeError("table",type(value))
			end

		elseif key == "after" then
			-- AFTER
			if type(value) == "table" then
				-- Validate the type
				for name, str in pairs(value) do
					if type(name) ~= String then
						error("ERROR: keys in After table must be strings",3)
					end
					if str == "_invalid" or type(str) ~= String or str == Number or str == Boolean then
						error("ERROR: Values in After table must be Strings",3)
					else
					end
				end

				ref._after = value
			else typeError("table",type(value))
			end

		elseif type(key) == "string" then
			error(key.." is not a valid element of an aspect.",3)
		end
	end

	for k,class in pairs(ref._adapts) do
		for att,typ in pairs(ref._attributes) do
			-- This function raises an error if there is already
			-- an attribute with same name but different type in the class searched
			checkSameAttName(att,typ,class)
		end
		-- If no error was raised, then everything is ok

		-- Create reference for this aspect in the classes it adapts
		-- the key is a reference to this aspect
		-- the value is the attributes of this aspect
		class._aspects[ref] = ref._attributes

		-- Modify the methods of the classes it adapts
		for classFuncName, classFuncRef in pairs(class._methods) do

			-- Insert the before methods where it matches
			for aspectMethod, nameMatch in pairs(ref._before) do
				local name = string.match(classFuncName,nameMatch)
--~ 				printd("matched: ",name)
				if classFuncName == name then
--~ 					printd("FOUND A MATCH")
					local oldFuncRef = classFuncRef
					classFuncRef = function(...)
											local beforeResult = true
											if ref._switch.active then
												beforeResult = ref[aspectMethod](...)
											end
											if beforeResult ~= false then
												return oldFuncRef(...)
											else return false
											end
										end
					class._methods[classFuncName] = classFuncRef
				end
			end

			-- Insert the after methods where it matches
			for aspectMethod, nameMatch in pairs(ref._after) do
				local name = string.match(classFuncName,nameMatch)
--~ 				printd("matched: ",name)
				if classFuncName == name then
--~ 					printd("FOUND A MATCH")
					local oldFuncRef = classFuncRef
					classFuncRef = function(...)
											local result = oldFuncRef(...)
											if result ~= false then
												if ref._switch.active then
													ref[aspectMethod](...)
												end
											end
											return result
										end
					class._methods[classFuncName] = classFuncRef
				end
			end
		end
	end

	local meta = { __index = function (self,key)
								if rawget(self._methods,key) ~= nil then
									-- Insert the before methods if they match
									for aspectMethod, nameMatch in pairs(ref._before) do
										local name = string.match(key,nameMatch)
--~ 										printd(aspectMethod,key,name)
										if aspectMethod == name then
											error("ERROR: Recursion detected",2)
										end
										if key == name then
--~ 						 					printd("FOUND A MATCH")
											local oldFuncRef = rawget(self._methods,key)
											self._methods[key] = function(...)
																	local result = true
																	if ref._switch.active then
																		if rawget(ref._methods,aspectMethod) then
																			result = ref._methods[aspectMethod](...)
																		else error("No such aspect method: "..aspectMethod)
																		end
																	end
																	if result ~= false then
																		return oldFuncRef(...)
																	else return result
																	end
																end
										end
									end

									-- Insert the after methods where they match
									for aspectMethod, nameMatch in pairs(ref._after) do
										local name = string.match(key,nameMatch)
--~ 						 				printd("matched: ",name)
										if key == name then
--~ 						 					printd("FOUND A MATCH")
											local oldFuncRef = rawget(self._methods,key)
											self._methods[key] = function(...)
																	local result = oldFuncRef(...)
																	if result ~= false then
																		if ref._switch.active then
																			if rawget(ref._methods,aspectMethod) then
																				ref._methods[aspectMethod](...)
																			else error("No such aspect method: "..aspectMethod)
																			end
																		end
																	end
																	return result
																end
										end
									end

									return rawget(self._methods,key)
								end
								if key then
										error("No such aspect method: "..key)
									else error("No such aspect method")
								end
							end,

					__newindex = function (self,key,value)
								-- All methods of an aspect are found in its '_methods' table
								if type(value) == "function" then
										-- Add new function to the aspect _methods table
										return rawset(self._methods,key,value)
								else
									error("Only methods can be added to an Aspect",2)
								end
						  end
					}
	setmetatable(ref,meta)

	_runAspect = false
end
