local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local login = require "login"
local tableutil = require "tableutil"

local dataHelper = require "protobufDataHelper"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd


function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function send_data(name, args)
	local data = dataHelper.encode(name, args)
	-- 发送数据
	socket.write(client_fd,data)
end

function REQUEST:login()
	print("login account,passwd:", self.account, self.passwd)
	local result = login.loginRequest(self.account, self.passwd)
	if result ~= 0 then
		print("kill client, client_fd:", client_fd)
		REQUEST:quit()
	end

	local loginInfo = { account = "kk", passwd = "haha"}
	send_data("Login.login", loginInfo)
	
	return {result = result}
end

function REQUEST:loginTest()
	print("loginTest:", tableutil.tPrint(self))
end


local function request(name, args, response)
	local f = assert(REQUEST[name])
	print("recieve request, protoName:", name, tableutil.tPrint(args))
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

--[[
skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (fd, _, type, ...)
		assert(fd == client_fd)	-- You can use fd to reply message
		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		skynet.trace()
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}--]]

skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,	
    unpack = skynet.tostring,   --- 将C point 转换为lua 二进制字符串
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	skynet.fork(function()
		local index = 1
		while true do
			
			--send_package(send_request "heartbeat")
			index = index + 1
			local loginInfo = { account = "kk"..index, passwd = "haha"}
			send_data("Login.login", loginInfo)
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

--- 分发消息
local function  dispatch_message(msg)
	--- 反序列化二进制string数据
	local pack_name,data = dataHelper.decode(msg)     --   pack_name = c2s.test
	local sub_name = pack_name:match(".+%.(%w+)$")    --   sub_name = test

	print("recieve request, protoName:", pack_name, tableutil.tPrint(data))
	
	local f = REQUEST[sub_name]
	if f == nil then
		print("not function define handle package:", pack_name)
		return
	end
	f(data)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.dispatch("client", function (session, address, msg)
		dispatch_message(msg)
	end)
end)
