-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

-- Auxiliary functions
require("functions")
-- Aspect functions
require("aspekt")

-- Primitive types
String = "string"
Number = "number"
Boolean = "boolean"
ObjectRef = "reference"
Table = "table"

_runClass = false
_runAspect = false

globalMT = {
	__index = function (self,key)
				if key == "Class" then
					_runClass = true
					return start
				elseif key == "Aspect" then
					_runAspect = true
					return startAspect
				elseif key == "super" then
					if rawget(self,"_super") then
						return rawget(self,"_super")
					end
				else
					 -- every uknown name will hold a string with its own name
					 -- until we finish creating the class
					if _runClass then
						return key
					end
					 -- every uknown name will hold a string "invalid"
					 -- until we finish creating the aspect
					if _runAspect then
						return "_invalid"
					end
				end
			  end
	}
setmetatable(_G, globalMT)

------------------ Functions

function start(...)
	if arg.n > 0 then
		local nclass = {}
		local t = arg[1]
		if type(t[1]) == String then
			_G[t[1]] = nclass
		else error("The first argument (Class name) must be a String",2)
		end
		newClass(t)
	else
		error("No arguments to the function")
	end
end

function newClass(t)
	_G[t[1]]._name = t[1]
	-- If the type of the second argument is a String, that is because it was nil
	if type(t[2]) == String then
		error("Not a valid class: "..t[2],3)
	end
	if t[2] ~= nil then
		_G[t[1]]._super = t[2]
	else
		_G[t[1]]._super = nil
	end
	_G[t[1]]._attributes = {}
	_G[t[1]]._methods = {}
	_G[t[1]]._aspects = {}
	_G[t[1]]._aspectsAtt = {}

	-- Create contructor NEW
	_G[t[1]].new = newobject -- it is a function

	local classref = _G[t[1]]
	for key, value in pairs(t) do
		-- ignore keys that are numbers
		if type(key) == String then
		-- if there is an attribute in a superclass with the same name,
		-- then this attribute must have also the same type. otherwise it is an ERROR
			local ref = classref._super
			while ref ~= nil do
				if ref._attributes then
					if ref._attributes[key] then
						if ref._attributes[key] ~= value then
							s = "Attribute "..key.." already exists with other type (in superclass)"
							error(s,3)
						end
					end
				end
				ref = ref._super
			end

			if value == String or value == Number or value == Boolean then
				classref._attributes[key] = value
			elseif type(value) == String then
				-- It should be a class...
				if type(_G[value]) == "table" then
					classref._attributes[key] = value
				else
					error("Not a valid type: "..value,3)
				end
			elseif type(value) == "table" then
				if type(value._name) == String then
					classref._attributes[key] = value._name
				else
					classref._attributes[key] = Table
				end
			else
				m = "Not a valid type for attribute "..key.." (a "..type(value).." value)"
				error(m,3)
			end
		end
	end -- end for loop

	-- create metatable for the class
	local mt = {
				__index = function(self,key)
							if key ~= "_super" then
								local objref = _G["_obj"]
								if objref ~= nil then
									if objref._attributes[key] ~= nil then
										return objref._attributes[key]
									end
								end

								local ref = self
								while ref ~= nil do
--~ 									printd("class index: "..key)
--~ 									printT(self,0)
									if ref._methods[key] ~= nil then
										-- Before calling the method, armazenate a reference to its superclass
										_G["_super"] = self._super
										return ref._methods[key]
									end
									ref = rawget(ref,"_super")
								end
							end
						end,

				__newindex = function (self,key,value)
								-- All methods of a class are found in its '_methods' table
								if type(value) == "function" then
										-- Add new function to the class methods table
										return rawset(self._methods,key,value)
								elseif _G["_obj"] ~= nil then
									print("ok")
									_G["_obj"][key] = value
									return
								else
									error("Only methods can be added to a class",2)
								end
						  end
		       }
	setmetatable(classref,mt)

	classref = nil -- Clear the reference
	_runClass = false
end

-----------------
-- Constructor --
-----------------
function newobject(self)
	local obj = {}
	obj._class = self
	obj._super = self._super
	obj._attributes = {}

	-- Initialize the hashmap for aspects and their attributes
	-- HashMap<Aspect, Table>
	obj._aspectsAttHash = {}

	-- Create instances for the class and superclasses attributes, and for their aspects
	local ref = obj._class
	while ref ~= nil do
		-- search in the normal attributes
		for key, value in pairs(ref._attributes) do
				if value == String then
					obj._attributes[key] = ""
				elseif value == Number then
					obj._attributes[key] = 0
				elseif value == Boolean then
					obj._attributes[key] = false
				elseif value == Table then
					obj._attributes[key] = {}
				else
					obj._attributes[key] = nil
				end
		end

		ref = ref._super
	end

	-- create metatable for the object table
	local mt = {
				__index = function (self, key)

								-- Search for attributes from active aspects
								for aspect, attributes in pairs(self._aspectsAttHash) do
									if aspect._switch.active then -- only get attributes from active aspects
										for k, v in pairs(attributes) do  -- value is a table with attributes
											if k == key then
												return v
											end
										end
									end
								end

								-- Search for attributes that were inherited from this object class and superclasses
								if self._attributes[key] ~= nil then
									return rawget(self._attributes, key)
								end

								-- It can still be an object that was initialised with nil, so search for it
								local ref = obj._class
								while ref ~= nil do
									for k, value in pairs(ref._attributes) do
											if k == key then
												-- create a new instance in the object and return it
												if value == String then
													self._attributes[k] = ""
												elseif value == Number then
													self._attributes[k] = 0
												elseif value == Boolean then
													self._attributes[k] = false
												else
													self._attributes[k] = nil
												end
												return rawget(self._attributes, key)
											end
									end
									ref = ref._super
								end

								-- Search for attributes in the aspects of this object class
								-- But only if the aspect is active
								for aspect, attributes in pairs(self._class._aspects) do -- nkey is a reference to the aspect
									if aspect._switch.active then -- aspect is active
										for k,v in pairs(attributes) do
											if k == key then
												self._aspectsAttHash[aspect] = {}
												if v == String then
													self._aspectsAttHash[aspect][k] = ""
												elseif v == Number then
													self._aspectsAttHash[aspect][k] = 0
												elseif v == Boolean then
													self._aspectsAttHash[aspect][k] = false
												else
													self._aspectsAttHash[aspect][k] = nil
												end
												return rawget(self._aspectsAttHash[aspect],k)
											end
										end
									end
								end

								-- If no attribute was found, then search for methods
								local ref = self._class
								while ref ~= nil do
									if ref._methods[key] ~= nil then
										-- Before calling the method, armazenate a reference to its superclass
										_G["_super"] = rawget(self,"_super")
										_G["_obj"] = self
										return function (...)
													local result = ref._methods[key](...)
													clear()
													return result
												end
									end
									ref = ref._super
								end

								-- key not found!
								if key then
										error("No such key: "..key,2)
									else error("No such key", 2)
								end
							end,

				__newindex = function (self, key, value)
								-- Search in the active aspects
								for aspect, attributes in pairs(self._class._aspects) do -- aspect is a reference to the aspect
									if aspect._switch.active then -- aspect is active
										for k,v in pairs(attributes) do
											if k == key then
												checked = typeCheck(v, key, value)
												if checked then
													if self._aspectsAttHash[aspect] == nil then
														self._aspectsAttHash[aspect] = {}
													end
													return checked(self._aspectsAttHash[aspect])
												else error("type checking", 2) end
											end
										end
									end
								end

								if self._class._attributes[key] ~= nil then
									-- we found the key we were looking for
									checked = typeCheck(self._class._attributes[key], key, value)
									if checked then return checked(self._attributes) -- rawset(self._attributes,key,value)
									else error("type checking",2) end
								elseif rawget(self,"_super") ~= nil then
									-- search in the superclasses
									local ref = rawget(self,"_super")
									while ref ~= nil do -- there is a superclass
										if ref._attributes[key] ~= nil then
											-- we found the key we were looking for
											checked = typeCheck(ref._attributes[key], key, value)
											if checked then return checked(self._attributes) -- rawset(self._attributes,key,value)
											else error("type checking",2) end
										end
										ref = rawget(ref,"_super")
									end
								end
								if key then
									error("No such field: "..key,2)
								else error("No such field", 2)
								end
							end -- Function __newindex
				}

	setmetatable(obj,mt)
	return obj
end -- end function
---------------------------------------------------------------------
