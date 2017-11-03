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

 iZotope wrapper for json functionality.

 This module wraps cjson and resty.prettycjson as well as providing helper functions

    local json = require "izo.json"

 @module izo.json
]]

local cjson = require 'cjson.safe' -- Note: always use safe
local prettycjson = require 'resty.prettycjson'
local debug = require 'std.debug'
local io = require 'std.io'

local M

local function encode(data, pretty)
	if pretty then
		return prettycjson(data)
	else
		return cjson.encode(data)
	end
end

local function decodefile(filename)
	local success, ret = pcall(io.slurp, filename)
	if not success then
		return nil, ret
	elseif not ret then
		return nil, "invalid file"
	end

	local jsondata, err = cjson.decode(ret)
	if jsondata then
		return jsondata
	else
		return nil, err
	end
end

--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--

-- Macro like function for wrapping access to exported functions with argument type checking
local function X (decl, fn)
  return debug.argscheck ("izo.json." .. decl, fn)
end

M = {
	--- encode a tabe into a json string
	-- @function encode
	-- @tparam table data data to convert into json
	-- @bool[opt=false] pretty set to true to do pretty string formatting of JSON
	-- @treturn string|nil json encoded string, or nil on error
	-- @return error on error, this is the error returned, otherwise nil
	-- @usage
	-- mystring, err = encode({a='hello', 0='test', 1=10})
	encode = X ("encode (table, [?bool|:pretty])", encode),

	--- decode a JSON string to a table
	-- @function decode
	-- @string json text to be decoded
	-- @treturn table|nil table of decuded values, or nil on error
	-- @return error on error, this is the error returned, otherwise nil
	-- @usage
	-- mytable, err = decode('{"count" : 5}')
	decode = X ("decode (string)", cjson.decode),

	--- decode JSON from a file
	-- @function decodefile
	-- @string path to file to decode
	-- @treturn table|nil table of decoded valuesm or nil on error
	-- @return error on error, this is set to the error, otherwise nil
	-- @usage
	-- mytable, err = decodefile('/path/to/file.name')
	decodefile = X ("decodefile (string)", decodefile),

	--- cjson module table for access to internel functions.
	-- see [CJson documentation for more details about usage](https://www.kyne.com.au/%7Emark/software/lua-cjson-manual.html).
	cjson = cjson,
}

return M
