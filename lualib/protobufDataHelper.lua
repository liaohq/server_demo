
local protobuf = require "protobuf"      --引入文件protobuf.lua
protobuf.register_file "./protobuf/common.pb" --注册pb文件
protobuf.register_file "./protobuf/login.pb" --注册pb文件
 
 
local protobufDataHelper = {}
--[[
    big endian
    head 
        2 byte body size
        2 byte protonamesize
        n byte protoname
    body
        n byte data
    @desc: 将lua格式的协议序列化为二进制数据
]] 
function protobufDataHelper.encode( name,data )
    local stringbuffer =  protobuf.encode(name, data)         -- protobuf序列化 返回lua string
    local body = string.pack(">s2s",name,stringbuffer)       -- 打包包体 协议名 + 协议数据
    local head = string.pack(">I2",#body)                     -- 打包包体长度
    print("encode proto_name:", name, ",data_size:", #body, ",totalSize:", #head+#body)
    return head .. body                                       -- 包体长度 + 协议名 + 协议数据
end
 
 
--[[
    @desc: 将二进制数据反序列化为lua string
    --@msg: C Point
    @return:协议名字，协议数据
]]
function protobufDataHelper.decode( msg  )
    --- 前两个字节在netpack.filter 已经解析
    print("msg size:", #msg)
    local proto_name,stringbuffer = string.unpack(">s2s",msg)
    print("proto_name", proto_name, "data:", stringbuffer)
    local body = protobuf.decode(proto_name, stringbuffer)
    return proto_name,body
end
 
 
return protobufDataHelper


