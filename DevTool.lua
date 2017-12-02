IncludeFile("Lib\\TOIR_SDK.lua")


function DrawTextToScreen(text,v1,xoff,yoff,color)
	local x = xoff or 0
	local y = yoff or 0
	local color = color or Lua_ARGB(255, 255, 255, 255)
	local x1,y1 =  WorldToScreen(v1.x, v1.y, v1.z)
	DrawTextD3DX(x1+x, y1+y , text, color)
end


function DrawNearbyObjects(unit)    
    GetAllObjectAroundAnObject(unit.Addr, 1000)
	local objectlist = pObject 
    for k,v in pairs(objectlist) do
    	if k >= 30 then break end
    	local vec = Vector(GetPos(v))
    	local _type = GetType(v)
    	local name = GetObjName(v)
    	local isTroy = string.find(string.lower(name), ".troy")
    	local isBuff = string.find(string.lower(name), "buff")
    	if _type ~= 6 and isTroy == nil and isBuff == nil then   		
        	DrawTextToScreen("NAME= " .. tostring(GetChampName(v)), vec, -40, 0)
        	DrawTextToScreen("TEAM_ID= " .. tostring(GetTeamId(v)), vec, -40, 20) 
        	DrawTextToScreen("TYPE=" .. tostring(_type), vec, -40, 40)          	
        else
        	DrawTextToScreen("NAME= " .. tostring(GetObjName(v)), vec, -40, 0)        	
        end              
    end    
end

function DrawBuffs(unit)
	GetAllBuffNameActive(unit.Addr)
	local vec = Vector(GetPos(unit.Addr))
	local buffs = pBuffName
	local count	= 100
	for k,v in pairs(buffs) do
		local buff = GetBuffByName(unit.Addr, v)
		local bStack = GetBuffStack(unit.Addr, v)
		local bCount = GetBuffCount(unit.Addr, v)
		if bStack == 0 and bCount ~= 0 then
			DrawTextToScreen("BUFF_NAME= " .. tostring(v) .. " ||| BUFF_ID= " .. tostring(buff) .. " ||| BUFF_COUNT=" .. tostring(bCount), vec, -300, count)
		elseif bStack ~= 0 and bCount == 0 then
			DrawTextToScreen("BUFF_NAME= " .. tostring(v) .. " ||| BUFF_ID= " .. tostring(buff) .. " ||| BUFF_STACKS= " .. tostring(bStack), vec, -300, count)
		elseif bStack == 0 and bCount == 0 then
			DrawTextToScreen("BUFF_NAME= " .. tostring(v) .. " ||| BUFF_ID= " .. tostring(buff) , vec, -300, count)
		else
			DrawTextToScreen("BUFF_NAME= " .. tostring(v) .. " ||| BUFF_ID= " .. tostring(buff) .. " ||| BUFF_STACKS= " .. tostring(bStack) .. " ||| BUFF_COUNT=" .. tostring(bCount), vec, -300, count) --Not sure if possible
		end
		--DrawTextToScreen("BUFF_ID= " .. tostring(buff), vec, -40, 20)
        --DrawTextToScreen("BUFF_STACKS= " .. tostring(stack), vec, -40, 40) 
        --DrawTextToScreen("BUFF_COUNT=" .. tostring(count), vec, -40, 60) 
        count = count +20      
	end


end

function DrawHeroInfo(unit)
	local vec = Vector(unit.x,unit.y,unit.z)
	DrawTextToScreen("NAME= " .. unit.CharName,  vec, 80, -140)
	DrawTextToScreen("TEAM_ID= " .. tostring(unit.TeamId), vec, 80, -120)
	DrawTextToScreen("Q_SPELL= " .. tostring(GetSpellNameByIndex(unit.Addr, 0)), vec, 80, -100)
	DrawTextToScreen("W_SPELL= " .. tostring(GetSpellNameByIndex(unit.Addr, 1)), vec, 80, -80)	
	DrawTextToScreen("E_SPELL= " .. tostring(GetSpellNameByIndex(unit.Addr, 2)), vec, 80, -60)
	DrawTextToScreen("R_SPELL= " .. tostring(GetSpellNameByIndex(unit.Addr, 3)), vec, 80, -40)
	DrawTextToScreen("SUM_SPELL_1= " .. tostring(GetSpellNameByIndex(unit.Addr, 4)), vec, 80, -20)
	DrawTextToScreen("SUM_SPELL_2= " .. tostring(GetSpellNameByIndex(unit.Addr, 5)), vec, 80, 0)
end

function DrawCursorPos()
	local pos3d = Vector(GetMousePos())
	local pos2d = Vector(GetCursorPos())
	local xoff = 40
	local yoff = 0
	if pos2d.x > 900 then xoff = -200 end
	if pos2d.y < 100 then yoff = 60 end
	DrawTextToScreen("WORLD_POS= " .. tostring(math.floor(pos3d.x)) .. " , " .. tostring(math.floor(pos3d.y)) .. " , " .. tostring(math.floor(pos3d.z)) ,pos3d,xoff, yoff)
	DrawTextToScreen("SCREEN_POS= " .. tostring(math.floor(pos2d.x)) .." , ".. tostring(math.floor(pos2d.y)) ,pos3d,xoff,yoff-20)
end

local DevMenu = menuInst.addItem(SubMenu.new("TOIR DevTool v1.0"))        
         DevMenu.addItem(MenuSeparator.new("   Features", true))
        DevMenu_buffs =  DevMenu.addItem(SubMenu.new("Draw Buffs"))
        DevMenu_buffs_me = DevMenu_buffs.addItem(MenuBool.new("Draw My Buffs", true))
        DevMenu_buffs_targ = DevMenu_buffs.addItem(MenuBool.new("Draw Target Buffs", true))       
        DevMenu_obj =  DevMenu.addItem(MenuBool.new("Draw Nearby Objects", true))
        DevMenu_info =  DevMenu.addItem(MenuBool.new("Draw Hero Info", true))
        DevMenu_cursor =  DevMenu.addItem(MenuBool.new("Draw Cursor Info", true))
        DevMenu.addItem(MenuSeparator.new("   Made by RMAN", true))

       

Callback.Add("Draw", function() 
	local unit = GetMyHero()
	local target = GetEnemyChampNearest(1000)
	
	if DevMenu_obj.getValue() then DrawNearbyObjects(unit) end
	if DevMenu_info.getValue() then DrawHeroInfo(unit) end
	if DevMenu_cursor.getValue() then DrawCursorPos() end
	if DevMenu_buffs_me.getValue() then DrawBuffs(unit) end
	if DevMenu_buffs_targ.getValue() and target ~= 0 then
		local unit2 = GetAIHero(target)
		DrawBuffs(unit2) 
	end
	


	
end)


__PrintTextGame("TOIR DevTool v1.0 - Made by RMAN")



