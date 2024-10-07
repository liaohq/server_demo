local parser = require "sprotoparser"
local core = require "sproto.core"
local sproto = require "sproto"

local loader = {}

function loader.register(filename, index)
	local f = assert(io.open(filename), "Can't open sproto file")
	local data = f:read "a"
	f:close()
	local sp = core.newproto(parser.parse(data))
	core.saveproto(sp, index)
end

function loader.save(bin, index)
	local sp = core.newproto(bin)
	core.saveproto(sp, index)
end

function loader.load(index)
	local sp = core.loadproto(index)
	--  no __gc in metatable
	return sproto.sharenew(sp)
end


local function load(name)
	local filename = string.format("protos/%s.sproto", name)
		local f = assert(io.open(filename), "Can't open " .. name)
		local t = f:read "a"
		f:close()
	return t
end

function loader.registerFileList(fileNameList, index)
	local context=""
	for i, name in ipairs(fileNameList) do
		local p = load(name)
		context = context .. p	
	end


	local p = parser.parse(context)
	loader.save(p, index)	
end



return loader

