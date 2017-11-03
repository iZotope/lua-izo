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

 Additions to std.string which is based on the core string module.

 The module table returned by `izo.string` also contains all of the entries
 from std.string and the core string table.  An hygienic way to import this
 module, then, is simply to override the core `string` locally:

    local string = require "izo.string"

 @module izo.string
]]

local stdstring = require 'std.string'
local std = require 'std'
local base = std.base
local debug = std.debug

local M

local function prepend_lines(s, prepend_string, line_break)
	line_break = line_break or "\n"
	local splitlines = s:split("\n")
	for i,v in ipairs(splitlines) do
		splitlines[i] = prepend_string .. splitlines[i]
	end
	return table.concat(splitlines, "\n")
end

local function monkey_patch (namespace)
  namespace = namespace or _G
  namespace.string = base.copy (namespace.string or {}, M)

  local string_metatable = getmetatable ""
  string_metatable.__concat = M.__concat
  string_metatable.__index = M.__index

  return M
end

--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--

-- Macro like function for wrapping access to exported functions with argument type checking
local function X (decl, fn)
  return debug.argscheck ("izo.string." .. decl, fn)
end

M = {
	--- prepend each line in a string with another string
	-- @function finds
	-- @string s target string
	-- @string prepend_string string to prepend on each line
	-- @string[opt="\n"] line_break line break string
	-- @return string with each line prepended
	-- @usage
	-- prepend_lines("hello\nworld\n", " # ")
	--   print (tostring (t.capt))
	-- end
	prepend_lines = X ("prepend_lines (string, string, ?string)", prepend_lines),

	--- Overwrite core `string` methods with `izo` and `std` enhanced versions.
	--
	-- Also adds auto-stringification to `..` operator on core strings, and
	-- integer indexing of strings with `[]` dereferencing.
	-- @function monkey_patch
	-- @tparam[opt=_G] table namespace where to install global functions
	-- @treturn table the module table
	-- @usage local string = require "izo.string".monkey_patch ()
	monkey_patch = X ("monkey_patch (?table)", monkey_patch),
}

-- due to the way __index is implmented in std.string you must put any modifications
-- directly back in it for them to work with the monkey_patch.
return base.merge(stdstring, M)
