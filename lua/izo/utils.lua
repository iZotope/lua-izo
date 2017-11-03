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

 iZotope lua utility functions

 @module izo.utils
]]

local M

--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--

-- run a program in a subshell
-- @function run
-- @string program the program and arguments to run
-- @tparam bool error_on_notfound if true raise an error if the program wasn't found
-- @treturn int the exit code of program
-- @treturn string the stdout and stderr output of program
-- @usage
-- exitcode, output = run(program, error_on_notfound)
local function run(program, error_on_notfound)
	
	local PROGRAM_NOT_FOUND_EXIT_CODE = 127

	error_on_notfound = (error_on_notfound) and true or false

	-- run the program with popen so we can ge the output and errorcode
	-- always add '2>&1' to redirect stderr to stdout
	local file = assert(io.popen(program .. ' 2>&1','r'))
	local output = file:read('*all')
	local rc = {file:close()}
	local exitcode = rc[3]

	if error_on_notfound and exitcode == PROGRAM_NOT_FOUND_EXIT_CODE then
		error("Program not found, ending test")
	end
	
	return exitcode, output
end

M = {
	run = run,
}

return M