
local skynet = require "skynet"
local pb = require "protobuf"
 
--protobuf编码解码
function test4()
    pb.register_file("./protobuf/login.pb")
    --编码
    local msg = {
        account = "101",
        passwd = "123456",
    }
    local buff = pb.encode("Login.login", msg)
    print("len:"..string.len(buff))
    --解码
    local umsg = pb.decode("Login.login", buff)
    if umsg then
        print("id:"..umsg.account)
        print("pw:"..umsg.passwd)
    else
        print("error")
    end
end
 
skynet.start(function()
    test4()
end)


