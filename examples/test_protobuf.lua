package.path = package.path .. ";./lualib/?.lua"
package.cpath = package.cpath .. ";./luaclib/?.so"

local protobuf = require "protobuf"      --引入文件protobuf.lua
protobuf.register_file "./protobuf/common.pb" --注册pb文件
protobuf.register_file "./protobuf/login.pb" --注册pb文件



local loginInfo = { account = "test", passwd = "pw"}

local encodeData = protobuf.encode("Login.login", loginInfo)
print("encodeData:", encodeData)

local decodeData = protobuf.decode("Login.login", encodeData)
print("decodeData account:", decodeData.account)
print("decodeData passwd:", decodeData.passwd)
