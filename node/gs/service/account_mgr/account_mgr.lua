
local function get_current_script_dir()  
    local info = debug.getinfo(1, "S")  
    local script_path = info.source:sub(2) -- 去除开头的 '@' 字符  
    local script_dir = script_path:match("(.*)/")  
    return script_dir or "./"  
end  

local current_dir = get_current_script_dir()
print("current_dir:", current_dir)  
-- 设置 package.path 以包含当前目录  
package.path = current_dir .. "/command/?.lua;" .. package.path 

local skynet = require "skynet"
local command = require "command"



skynet.start( function()
	print("start account_mgr service begin")


	skynet.dispatch("lua", function(_,_,cmd,...)
       	local f = assert(command[cmd])
       	skynet.ret(skynet.pack(f(...)))
   	end)

	print("start account_mgr service end")
end)
