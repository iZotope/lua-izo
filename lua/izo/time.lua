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

 iZotope wrapper for time functions.

 local time = require "izo.time"

 @module izo.time
]]

local posix = require 'posix'
posix.time = require 'posix.time'

local M

--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--

--- get monotonic system time
-- @function get_time_monotonic
-- @usage
-- start_time = get_time_monotonic()
local function get_time_monotonic()
	--OSX doesn't have clock_gettime. It is included in the lunix module
	--see [lunix documentation](https://github.com/wahern/lunix) for more details about usage.
	local has_cgt,clock_gettime = pcall(posix.time.clock_gettime, posix.time.CLOCK_MONOTONIC)
	if not has_cgt then
		unix = require'unix'
		os_time = unix.clock_gettime(unix.CLOCK_MONOTONIC)
	else
		time_ts = posix.time.clock_gettime(posix.time.CLOCK_MONOTONIC)
		--convert (sec,nsec) to float
		--eg. (1,500000000) = 1.5
		os_time = time_ts.tv_sec + time_ts.tv_nsec / 10e8
	end
	return os_time
end

M = {
	get_time_monotonic = get_time_monotonic,
}

return M