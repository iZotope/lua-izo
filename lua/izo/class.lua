--[[--
 Software License Agreement (BSD 3-clause License)

  Copyright (c) 2017, iZotope, Inc.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above
     copyright notice, this list of conditions and the following
     disclaimer in the documentation and/or other materials provided
     with the distribution.
   * Neither the name of iZotope Inc. nor the names of its
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

 iZotope class implementation.

 This module provides a basic class implementation that allows for
 single inheritance and constructors.

    local class = require "izo.class"
    NewClass = new_class(nil, {init = function() print 'hello' end})
    DerivedClass = new_class(NewClass, {init = function() print 'top constructor' self.base.init()})
    derived_inst = DerivedInst()

 @module izo.class
]]

local M

local function new_class(base, overrides)
	-- overrides is a table of k,v pairs to set in the new class. These will override base
	overrides = overrides or {}
	-- "cls" is the new class
	local cls = {}
	-- copy base class contents into the new class
	if base then
		for k, v in pairs(base) do
			cls[k] = v
		end
	end

	-- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
	-- so you can do an "instance of" check using my_instance.is_a[MyClass]
	cls.__index, cls.is_a = cls, {[cls] = true}
	if base then
		for c in pairs(base.is_a) do
			cls.is_a[c] = true
		end
		cls.is_a[base] = true
		cls.base = base
	end

	-- copy any overrides on top of the class now
	for k,v in pairs(overrides) do
		cls[k] = v
	end

	-- the class's __call metamethod
	setmetatable(cls, {
		__call = function (c, ...)
			local instance = setmetatable({}, c)
			-- run the init method if it's there
			-- note this will fall through to the base class if not defined here
			if instance.init then instance:init(...) end
			return instance
		end})
	-- return the new class table, that's ready to fill with methods
	return cls
end

--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--

M = {
	--- create a new class prototype
	-- @function new_class
	-- @string base the base class to derive from or nil for none
	-- @tparam table overrides table of values to set in new derived class. nil for none
	-- @return the new prototype class
	new_class = new_class
}

return M
