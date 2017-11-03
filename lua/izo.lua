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

iZotope Lua Standard Libraries.

 This module contains a selection of extended stdlib and lua functions
 as well as various genearl purpose functions.

 This module depends on, extends and borrows it's style from the lua stdlib project
]]

local M

--- Module table.
--
-- In addition to the functions documented on this page, and a `version`
-- field, references to other submodule functions will be loaded on
-- demand.
-- @table izo
-- @field version release version string

local function X (decl, fn)
  return require "std.debug".argscheck ("izo." .. decl, fn)
end

M = {
	version = "iZotope Lua libraries / 1.0",
}

--- Metamethods
-- @section Metamethods

return setmetatable (M, {
	--- Lazy loading of izo modules.
	-- Don't load everything on initial startup, wait until first attempt
	-- to access a submodule, and then load it on demand.
	-- @function __index
	-- @string name submodule name
	-- @treturn table|nil the submodule that was loaded to satisfy the missing
	--   `name`, otherwise `nil` if nothing was found
	-- @usage
	-- local izo = require "izo"
	-- local prototype = std.object.prototype
	__index = 
		function (self, name)
			local ok, t = pcall (require, "izo." .. name)
			if ok then
				rawset (self, name, t)
				return t
			else
				print("Error on require of izo."..name)
				print(t)
			end
		end,
})
