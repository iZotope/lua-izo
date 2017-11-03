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

 iZotope wrapper for std.optparse

 This module wraps std.optparse and adds some extra helper functions

    local optparse = require "izo.optparse"

 @module izo.optparse
]]

local optparse = require 'std.optparse'
local std = require'std'
---[[
optparse_mt = getmetatable(optparse)

local optparse_init = optparse_mt._init
local optparse_parse = optparse_mt.__index.parse

--[[
Add support for required arguments
--]]

--- add a required field to the parser
-- @function optparse:required_field
-- @string required_field string of the flag that is required on the command line
optparse_mt.__index.required_field = function(self, required_field)
	self.required_fields = self.required_fields or {}
	table.insert(self.required_fields, required_field)
end

--- extended parse function
--
-- extended the orignal optpasre:parse method to also check for required flags
optparse_mt.__index.parse = function (self, arglist, defaults)
	-- call the base optpasre.parse
	local unrec, opts = optparse_parse(self, arglist, defaults)

	-- check for required fields
	for k,v in pairs(self.required_fields or {}) do
		if opts[v] == nil or type(opts[v]) == 'function' then
			print(string.format("Error: Command line option '%s' is required", v))
			self:help()
		end
	end
	return unrec, opts
end

return optparse