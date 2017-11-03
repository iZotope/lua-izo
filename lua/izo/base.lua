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

 iZotope base extension to Lua

 This module is a series of helper functions that are genearl extensions to the Lua language

    local base = require "izo.base"

 @module izo.base
]]

local debug = require 'std.debug'
local stdlib = require 'posix.stdlib'
local libgen = require 'posix.libgen'

local M

local function is_array(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then return false end
	end
	return true
end

local function setup_path_for_cli_app()
	-- get the source name of the calling function
	local filename = debug.getinfo(2,"S").source
	-- only do the operation if we got back a file (indicated with a prefixed '@')
	if filename:sub(1,1) == '@' then
		filename = filename:sub(2)
		print(filename)
		-- get the directory of the real path
		local filepath = libgen.dirname(stdlib.realpath(filename))
		-- strip any realative path entries from pacakges.path
		local path = package.path:gsub(';%./.-;',';'):gsub(';%./.*','')
		-- add in our absoluate pats at the end of the path
		path = string.format('%s;%s/?.lua;%s/?/init.lua',path,filepath,filepath)
		package.path = path
	end
end

--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--

local function X (decl, fn)
  return debug.argscheck ("izo.base." .. decl, fn)
end

M = {
	--- checks if a table is a true array
	--
	-- Tables with only integer keys and no holes are considered an array
	-- @function is_array
	-- @tparam table t table to check
	-- @treturn bool true if it is an array, false otherwise
	-- @usage
	-- isanarray = is_array({"will", "return", "true", 10, true})
	is_array = X("is_Array (table)", is_array),

	--- Remove relative paths from pacakge.path and adds the path of the calling file
	-- @function setup_path_for_cli_app
	setup_path_for_cli_app = setup_path_for_cli_app,
}

return M
