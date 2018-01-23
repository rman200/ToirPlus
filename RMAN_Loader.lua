local file = io.open(SCRIPT_PATH .. "\\PrestigiousAIO.RMAN", 'rb')
if file then
	local bytecode = file:read "*a"		
	file:close()
	loadstring(bytecode)()
end