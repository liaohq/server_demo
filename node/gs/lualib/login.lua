local skynet = require "skynet"
require "skynet.manager"

local M = {}


local accountList = {}


--新建账号
function M.newLogin(account, passwd)
	print("newLogin begin, account, passwd:", account, passwd)

	local ret = skynet.call(".mongo_service", "lua", "addAccount", account,passwd)
	
	if ret ~= 0 then
		print("newLogin fail, error:", ok,ret)
		return ret
	end

	accountList[account] = passwd
	print("newLogin success, account, passwd:", account, passwd)
	return 0
end


--已有账号
function M.login(account, passwd)
	print("login, account, passwd:", account, passwd)

	if accountList[account] ~= passwd then
		print("login fail, oldPasswd, curPasswd:", accountList[account], passwd)
		return -1
	end

	return 0
end


function M.loginRequest(account, passwd)
	print("loginRequest account, passwd:", account, passwd)
	if account == nil then
		print("loginRequest fail by account is nil")
		return -1
	end

	if passwd == nil then
		print("loginRequest fail by passwd is nil")
		return -1
	end

	local dbAccountInfo = skynet.call(".mongo_service", "lua", "queryAccount", account, passwd)
	print("loginRequest dbAccountInfo:", dbAccountInfo)
	if dbAccountInfo ~= nil then
		accountList[account] = dbAccountInfo.passwd
		return M.login(account, passwd)
	end

	return M.newLogin(account, passwd)
end




return M
