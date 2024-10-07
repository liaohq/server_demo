local M = {}

function M.tPrint(t, indent)  
    if t == nil then
		return
	 end

    indent = indent or ""  		
	local result = ""  
	for k, v in pairs(t) do  
		 if type(v) == "table" then  
		 -- 递归处理嵌套表  
			result = result .. indent .. tostring(k) .. " = {\n"  
			result = result .. table_to_string(v, indent .. "  ") .. "\n" .. indent .. "}\n"  							
		else  
			-- 处理非表类型的值           
			result = result .. indent .. tostring(k) .. " = " .. tostring(v) .. "\n"  
		end  
	end  
	return result  
end 

return M
