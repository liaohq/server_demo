package.cpath = "luaclib/?.so;skynet/luaclib/?.so"
package.path = "lualib/common/?.lua;lualib/?.lua;skynet/lualib/?.lua;skynet/examples/?.lua"

local tableutil = require "tableutil"

if _VERSION ~= "Lua 5.4" then
    error "Use lua 5.4"
end



local socket = require "client.socket"
local dataHelper = require "protobufDataHelper"

local fd = assert(socket.connect("127.0.0.1", 8888))


local function send_data(name, args)
    local data = dataHelper.encode(name, args)
    -- 发送数据
    socket.send(fd,data)
end

local loginInfo = { account = "lhq", passwd = "haha"}
send_data("Login.login", loginInfo)
send_data("Common.heartbeat", {})


local function unpack_package(text)
    local size = #text
    if size < 2 then
        return nil, text
    end
    local s = text:byte(1) * 256 + text:byte(2)
    if size < s+2 then
        return nil, text
    end

    return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
    local result
    result, last = unpack_package(last)
    if result then
        return result, last
    end
    local r = socket.recv(fd)
    if not r then
        return nil, last
    end
    if r == "" then
        error "Server closed"
    end
    return unpack_package(last .. r)
end

local last = ""
local function dispatch_package()
    while true do
        local v
        v, last = recv_package(last)
        if not v then
            break
        end

	local packName, data = dataHelper.decode(v)
	print("packName:", packName)
        print("data:", tableutil.tPrint(data) )
    end
end

while true do

	dispatch_package()
	socket.usleep(1000000)
end

