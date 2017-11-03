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

 iZotope gpio class

 This module provides a gpio class for manipulating linux GPIOs using iZotope's /dev/gpio interface

    local Gpio = require "izo.gpio".Gpio
    gpio_plumbus = Gpio('plumbus', Gpio.DIRECTION.input)
    print('The plumbus is '..gpio_plumbus:get_active() and 'active' or 'inactive')

 @module izo.gpio
]]

local class = require 'izo.class'
require 'izo.string'.monkey_patch()
local M

local Gpio = class.new_class(nil, {
	--- GPIO directions
	-- @table DIRECTION
	DIRECTION = {
		input = 'in', -- gpio input
		output = 'out', -- gpio output
	},

	--- Gpio constructor.
	-- @function Gpio:init
	-- @string gpio_name name of the gpio as it appears in /dev/gpio/
	-- @tparam DIRECTION initial_direction the direction to set the pin to
	-- @bool initially_active if inital_direction is output, what state to init the pin to
	init = function(self, gpio_name, initial_direction, initially_active)
		self.valid = false
		self.name = gpio_name
		self.path = '/dev/gpio/'..self.name..'/'

		-- validate the gpio (make sure the directory exists)
		-- maybe should validate permissions of all files like 'direction' and 'value'
		-- by attempting to open the file
		local f = io.open(self.path)
		if f then
			f:close()
			self.valid = true
		else
			self:_error("path doesn't exist "..self.path)
			return
		end

		self:set_direction(initial_direction)
		if self.direction == self.DIRECTION.output and initially_active then
			self:set_active(true)
		end
	end,

	--- set the gpio direction.
	-- @function Gpio:set_direction
	-- @tparam DIRECTION the state to set the pin
	-- @bool initially_active if direction is output, the inital active state to set
	set_direction = function(self, direction, initially_active)
		if not self.valid then return end

		local success = self:gpio_class_io('direction', direction)
		if success then
			self.direction = direction
			if direction == self.DIRECTION.output  and initially_active then
				self:set_active(true)
			end
		end
	end,

	--- set the output value of the gpio.
	--
	-- Set the output value of the gpio. Only works if in output state, ignored otherwise
	-- @function Gpio:set_active
	-- @bool active true if set to active, false if set to inactive
	set_active = function(self, value)
		if not self.valid then return end

		if self.direction == 'out' then
			self:gpio_class_io('value', value and '1' or '0')
		end
	end,

	--- checks if an input pin is in the active state
	-- @function Gpio:is_active
	-- @treturn[1] bool active state
	-- @return[2] nil on error
	is_active = function(self)
		if not self.valid then return nil end
		if self.direction ~= self.DIRECTION.input then return nil end

		local value = tonumber(self:gpio_class_io('value'))
		if type(value) == "number" then
			if value == 0 then
				return false
			else
				return true
			end
		else
			return nil
		end
	end,

	--[[ Internal functions ]]--
	
	-- print an error about this instance
	-- @string err the string error to print
	_error = function(self, err)
		print(string.format("GPIO error '%s': %s", self.name or '?', tostring(err)))
	end,

	-- write or read to gpio file with error handling
	-- @string file file name to open in the gpio directory
	-- @string value value to write to file. if nil, do a read
	-- @return string that was read if 'r', or empy string on 'w'. Nil on error
	gpio_class_io = function(self, file, value)
		local mode = value and 'w' or 'r'
		local ret_string = ""

		local f = io.open(self.path..file, mode)
		if f then
			if mode == 'r' then
				ret_string = f:read('all'):trim()
			elseif mode == 'w' then
				f:write(value)
			end
		else
			self:_error(string.format"couldn't open file '%s' for mode '%s'", file, mode)
			return nil
		end

		local success, err, errno = f:close()
		if success then
			return ret_string
		else
			self:_error(string.format("couldn't %s %s: %d %s",(mode=='r' and 'read' or 'write'), file, errno, err))
			return nil
		end
	end,
})

--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--

M = {
	-- the gpio prototype class
	Gpio = Gpio
}

return M
