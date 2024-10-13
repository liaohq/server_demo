local logger = require "logger"
local skynet = require "skynet"
require "skynet.manager"


local function initPackagePath()
	package.path = package.path .. ";app/gs/?.lua"
	logger.logInfo("gs packagePath:", package.path)
end

local function initLogger()
	logger.init("gs.log")
end

local function init()
	initLogger()
	initPackagePath()
end

local function start_gs()
	logger.logInfo("Server start")
	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.newservice("debug_console",8000)
	skynet.newservice("simpledb")
	local watchdog = skynet.newservice("watchdog")
	local addr,port = skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	logger.logInfo("Watchdog listen on " .. addr .. ":" .. port)
end

skynet.start(function()
	init()
	logger.logInfo("Main Server start")
	local mongoService = skynet.newservice(
		"mongodb_service", "127.0.0.1", 27017, "testdb", "test", "test"
	)

	skynet.name(".mongo_service", mongoService)

	--skynet.call(".mongo_service", "lua", "test", 123)

	--protobuf
	skynet.uniqueservice("protobuf_service")
	local account_mgr_service = skynet.uniqueservice("account_mgr")
	skynet.name(".account_mgr", account_mgr_service)
	skynet.call(".account_mgr", "lua", "test", 123)
	start_gs()

	local a = require "libcore"
	a.test()
end)
