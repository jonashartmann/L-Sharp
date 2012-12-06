-------------------------------
--~ Author: Jonas Hartmann <jonasharty@gmail.com>
-------------------------------

---------------------------------------------------------------------
-- Clear temporary references to super and object
---------------------------------------------------------------------
function clear()
	_G["_super"] = nil
	_G["_obj"] = nil
end
---------------------------------------------------------------------
-- Compare Strings
---------------------------------------------------------------------
function compareStrings(n1, n2)
	if type(n1) == String and type(n2) == String then
		if n1 == n2 then
			return true
		else
			return false
		end
	else
		error("The parameters must be strings",2)
	end
end

---------------------------------------------------------------------
-- Check for attributes being declared with the same name of existing ones
---------------------------------------------------------------------
function checkSameAttName(key, value, objref)
	-- if there is an attribute in a superclass with the same name,
	-- then this attribute must have also the same type. otherwise it is an ERROR
	local ref = objref
	while ref ~= nil do
		if ref._attributes ~= nil then
			if ref._attributes[key] ~= nil then

				if ref._attributes[key] ~= value then
					s = "Attribute "..key.." already exists with other type"
					error(s,4)
				end
			end
		end
		ref = ref._super
	end
end
---------------------------------------------------------------------
-- Type Error
---------------------------------------------------------------------
function typeError(n1, n2, ...)
	local level = 4 -- default value
	if arg.n > 0 then
		if type(arg[1]) == "number" then
			level = arg[1]
		end
	end
	error("TYPE CHECK: Expects a "..n1.." and got a "..n2,level)
end
---------------------------------------------------------------------
---------------------------------------------------------------------
-- Type Checking
---------------------------------------------------------------------
-- returns a function
---------------------------------------------------------------------
function typeCheck(name, key, value)
	-- create the function to return
	function returnFunc(t)
		rawset(t,key,value)
	end

	if compareStrings(name, type(value)) then
		-- we found the key we were looking for
		return returnFunc
	end

	if type(value) == "table" then
		if value._class ~= nil then
			-- if they have the same name means the same type
			if compareStrings(name, value._class._name) then
				return returnFunc
			-- A subclass is conform to the superclass
			elseif rawget(value,"_super") ~= nil then
				if value._super._name ~= nil then
					if compareStrings(name, value._super._name) then
						return returnFunc
					else
						typeError(name, value._class._name) -- fifth case
					end
				else
					typeError(name, type(value)) -- fourth case
				end
			else
				typeError(name, value._class._name) -- first case
			end
		else
			typeError(name, type(value)) -- second case
		end
	elseif type(value) == "nil" then
			return returnFunc
	else
		typeError(name, type(value)) -- third case
	end
end
--------------------------------------------------------------------
--------------------------------------------------------------------

------------------------------
-- Functions for Debugging ---
------------------------------
function printT(t, level)
	if level == nil then error("printT requires a level as second argument",2) end
	print('--- Table ----')
	for k,v in pairs(t) do
		if level > 0 then
			if type(v) == "table" then
				print(tostring(k)..":")
				printT(v, level-1)
			else
				print("  "..tostring(k),':',v)
			end
		else
			print("   "..tostring(k),':',v)
		end
	end
	print('-------')
end

function printd(msg,...)
	print("- #[DEBUG]: "..tostring(msg),unpack(arg))
end

---------------
-- Debugging --
---------------

