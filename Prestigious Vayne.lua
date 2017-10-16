-------------------------------------<INITI>-------------------------------------
local myHero = GetMyChamp()
if GetChampName(myHero) ~= "Vayne" then return end
local myHeroPos = Vector({GetPosX(myHero), GetPosY(myHero), GetPosZ(myHero)})
local _heroes = SearchAllChamp()
local _enemies = {}
GetEnemies() 
__PrintTextGame("Prestigious Vayne Loaded, Good Luck!")

local Q = 0
local W = 1
local E = 2
local R = 3

local SpaceKeyCode = 32
local CKeyCode = 67
--local VKeyCode = 86


local SpellQ = {Range = 300, Speed = 2000, Delay = 0.25}
local SpellW = {Range = 550, Target = nil, Count = nil}
local SpellE = {Range = 550, Speed = 2000, Delay = 0.5}
local SpellR = {Range = 1000, Delay = 0.50}
-------------------------------------</INIT>-------------------------------------

-------------------------------------<Base Functions>-------------------------------------
local function GetEnemies()
	for k,v in pairs(_heroes) do
		if IsEnemy(v) then
			table.insert(_enemies, v)
		end
	end
end

local function GetTarget(range)	
	return GetEnemyChampCanKillFastest(range)
end

local function ValidTarget(target, range)
	if target ~= 0 then
		local targetPos = Vector({GetPosX(target), GetPosY(target), GetPosZ(target)})
		if IsDead(target) == false and IsInFog(target) == false and GetTargetableToTeam(target) == 4 and IsEnemy(target) and GetDistanceSqr(myHeroPos, targetPos) < range * range and CountBuffByType(target, 17) == 0 and CountBuffByType(target, 15) == 0 then
			return true
		end
	end
	return false
end

local function GetDistance(p1, p2)
    return math.sqrt(GetDistanceSqr(p1, p2))
end

local function GetDistance2D(p1,p2)
	return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2))
end

local function GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or myHeroPos
	local dx = Pos1.x - Pos2.x
	local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return dx * dx + dz * dz
end


local function IsImmobile(unit)
	if CountBuffByType(unit, 5) or CountBuffByType(unit, 11) or CountBuffByType(unit, 24) or CountBuffByType(unit, 29) or IsRecall(unit) then
		return true
	end
	return false
end

local function IsUnderEnemyTurret(pos)			--Will Only work near myHero
	GetAllObjectAroundAnObject(myHero, 2000)
	local objects = pObject
	for k,v in objects do
		if IsTurret(v) and IsDead(v) == false and IsEnemy(v) and GetTargetableToTeam(v) == 4 then
			local turretPos = Vector({GetPosX(v), GetPosY(v), GetPosZ(v)})
			if GetDistanceSqr(turretPos,pos) < 915*915 then
				return true		
		end 
	end					
	return false
end

local function IsUnderAllyTurret(pos)			--Will Only work near myHero
	GetAllObjectAroundAnObject(myHero, 2000)
	local objects = pObject
	for k,v in objects do
		if IsTurret(v) and IsDead(v) == false and IsAlly(v) and GetTargetableToTeam(v) == 4 then
			local turretPos = Vector({GetPosX(v), GetPosY(v), GetPosZ(v)})
			if GetDistanceSqr(turretPos,pos) < 915*915 then
				return true		
		end 
	end					
	return false
end

local function EnemiesAround(object, range)
	return CountEnemyChampAroundObject(object, range)
end

local function GetPercentHP(target)
	return GetHealthPoint(target)/GetHealthPointMax(target) * 100
end

-------------------------------------</Base Functions>-------------------------------------



-------------------------------------<Unique Functions>-------------------------------------

local function BOTRK(target)
	local iBOTRK = GetSpellIndexByName("ItemSwordOfFeastAndFamine") 
	local iCutlass = GetSpellIndexByName("BilgewaterCutlass")
	if iBOTRK and CanCast(iBOTRK) then 
		CastSpellTargetByName(target, "ItemSwordOfFeastAndFamine")
	elseif iCutlass and CanCast(iCutlass) then
		CastSpellTargetByName(target, "BilgewaterCutlass")
	end
end

local function UpdateBuff()										--Check if need delay
	SpellW.Target = nil
	SpellW.Count = nil
	for k,v in pairs(_enemies) do             
        local var = GetBuffCount(v, "vaynesilvereddebuff")   --Check if buffstack
        if var ~= nil and var ~= 0 then 
        	SpellW.Target = v
        	SpellW.Count = var
        end
    end
end

local function IsCollisionable(vector)	
	return IsWall(vector.x,vector.y,vector.z)
end

local function IsCondemnable(target)								--Check Vectors
	local pP = {x = GetPosX(myHero), y = GetPosY(myHero), z = GetPosZ(myHero)}
	local eP = {x = GetPosX(target), y = GetPosY(target), z = GetPosZ(target)}
	local pD = 450
	if (IsCollisionable(Extended(eP,pP,-pD)) or IsCollisionable(Extended(eP, pP, -pD/2)) or IsCollisionable(Extended(eP, pP, -pD/3))) then	
		if IsImmobile(target) or IsCasting(target) then	
			return true	
		end	
		local enemiesCount = CountEnemyChampAroundObject(myHero, 1200)	
		if 	enemiesCount > 1 and enemiesCount <= 3 then	
				for i=15, pD, 75 do	
					vector3 = Extended(eP,pP, -i)										
					if IsCollisionable(vector3) then	
						return true	
					end					
				end	
		else	
		local hitchance = 50	
		local angle = 0.2 * hitchance	
		local travelDistance = 0.5	
		local alpha = {x= (eP[x] + travelDistance * math.cos(math.pi/180 * angle)), y= eP[y] ,z= (eP[z] + travelDistance * math.sin(math.pi/180 * angle))}			
		local beta = {x= (eP[x]	- travelDistance * math.cos(math.pi/180 * angle)), y= eP[y], z= (eP[z] - travelDistance * math.sin(math.pi/180 * angle))}	
		for i=15, pD, 100 do	
			local col1 = Extended(pP,alpha, i)	
			local col2 = Extended(pP,beta, i)	
			if i>pD then return false end	
			if IsCollisionable(col1) and IsCollisionable(col2) then return true end	
		end	
	return false			
end


local function IsDangerousPosition(pos)
	if IsUnderEnemyTurret(pos) then return true end
	for k,v in pairs(_enemies) do    	     
    	if not IsDead(v) and IsEnemy(v) and GetDistanceSqr(pos, myHeroPos) < 350 * 350 then return true end      
    end
   	return false
end

function Vayne:GetSmartTumblePos(target)
	if not IsDangerousPosition(mousePos) then return mousePos end
	local targetPos = Vector({GetPosX(target), GetPosY(target), GetPosZ(target)})
	local p0 = myHeroPos
	local points= {	 
	[1] = p0 + 300*Vector(1,0,0), 
	[2] = p0 + 212*Vector(1,0,1), 
	[3] = p0 + 300*Vector(0,0,1), 
	[4] = p0 + 212*Vector(-1,0,1), 
	[5] = p0 + 300*Vector(-1,0,0),
	[6] = p0 + 212*Vector(-1,0,-1),
	[7] = p0 + 300*Vector(0,0,-1),
	[8] = p0 + 212*Vector(1,0,-1)}
	for i=1,#points do
		if not IsDangerousPosition(points[i]) and GetDistanceSqr(points[i], targetPos) < 500 * 500 then return points[i] end
	end
end

local function AntiGapCloser()	
	local target = CountEnemyChampAroundObject(myHero, 600)	
	if IsCasting(myHero) or CanCast(E) == false or Setting_IsComboUseE() == false or target == nil or target == 0 then return end	
	
    for k,v in pairs(_enemies) do             
        if IsValidTarget(v, 550) then
        	if IsDashing(v) then
        		local dashFrom = Vector({GetPosX(v), GetPosY(v), GetPosZ(v)})
				local dashTo =  Vector({GetMoveDestPointPosX(v), GetMoveDestPointPosY(v), GetMoveDestPointPosZ(v)}) 
				if myHeroPos - dashFrom > myHeroPos - dashTo then
        			CastSpellTarget(v, E)
         			break
         		end						
			end
        end
    end
end


--[[				--Placeholder
function Interrupt()
	if not Ready(_E) then return end
	for k,v in pairs(_enemies) do
		local targetPos = Vector({GetPosX(v), GetPosY(v), GetPosZ(v)})
		if not IsDead(v) and IsEnemy(v) and GetDistanceSqr(targetPos, myHeroPos) < 550 * 550 then
			if IsCasting(v) then
				DelayAction(function()
					if IsCasting(v) and GetDistanceSqr(target.pos, myHeroPos) < 550 * 550 then
						CastSpellTarget(v, E)
					end	
				end,0.5)
			end
		end
	end
end]]




-------------------------------------</Unique Functions>-------------------------------------



-------------------------------------<Main Script>-------------------------------------
function OnTick()
	if IsDead(myHero) then return end

	UpdateBuff()	
	AutoCondemn()
	--KillSteal()
	
	
	if IsTyping() then return end --Wont Orbwalk while chatting
	local nKeyCode = GetKeyCode()
	if nKeyCode == SpaceKeyCode then
		SetLuaCombo(true)
		Combo()
	elseif nKeyCode == CKeyCode then
		SetLuaHarass(true)
		Harass()
	end
	--[[
	if nKeyCode == VKeyCode then
		LaneClear()
	end]]

	

end

function Combo()
	local target = GetTarget(550)
	if ValidTarget(target) == false or IsCasting(myHero) then return end

	if GetPercentHP(target) < 80 then
		BOTRK(target)
	end

	if Setting_IsComboUseR() and EnemiesAround(myHero, 800) >= 2 and CanCast(R) then
    	CastSpellTarget(myHero, R)
    end

    if Setting_IsComboUseQ() and CanCast(Q) then
    	local qPos = GetSmartTumblePos(target)
    	if qPos ~= nil then 
    		CastSpellToPos(qPos.x,qPos.z, Q)
    	end
    end	
end

function Harass()
	local target = GetTarget(550)
	if ValidTarget(target) == false or IsCasting(myHero) then return end


    if Setting_IsHarassUseQ() and CanCast(Q) then
    	local qPos = GetSmartTumblePos(target)
    	if qPos ~= nil then 
    		CastSpellToPos(qPos.x,qPos.z, Q)
    	end
    end

    if Setting_IsHarassUseE() and CanCast(E) and SpellW.Count == 2 then
    	local eTarg = SpellW.Target    	
    	CastSpellTarget(eTarg, E)    	
    end

	
end

function AutoCondemn()	
	local target = CountEnemyChampAroundObject(myHero, 600)	
	if IsCasting(myHero) or CanCast(E) == false or Setting_IsComboUseE() == false or target == nil or target == 0 then return end	
	   
    for k,v in pairs(_enemies) do             
        if IsValidTarget(v, 550) then
        	if IsCondemnable(v) then
        		CastSpellTarget(v, E)
         		break						
			end
        end
    end
end



-------------------------------------</Main Script>-------------------------------------




