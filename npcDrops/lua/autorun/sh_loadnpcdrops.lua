--[[
npcDrops
by cometopapa
all rights reserved
]]
-- // #RESOURCES# \\ 

if SERVER then
	resource.AddFile("sound/npcdrops/lootdrop.wav")

	resource.AddSingleFile( "materials/npcDrops/itemtexture.png" )

end


-- LOADING TEXT
local zdiag = {
    '\n\n',
    [[====================================================================]],
}
local loadingtext = {
    [[Loading npcDrops...]],
    [[npcDrops version: 1.4 ]],
}
local ydiag = {
    [[====================================================================]],
}

for k, i in ipairs( zdiag ) do 
    MsgC( Color( 255, 255, 0 ), i .. '\n' )
end

for k, i in ipairs( loadingtext ) do 
    MsgC( Color( 255, 255, 255 ), i .. '\n' )
end

for k, i in ipairs( ydiag ) do 
    MsgC( Color( 255, 255, 0 ), i .. '\n\n' )
end

if CLIENT then
	local files = file.Find( "npcdrops/*", "LUA" )
	for _,v in pairs(files) do
		if string.StartWith(v,"cl_") then
			include("npcdrops/" .. v)
			MsgC(Color(255, 255, 0), "[npcDrops] Loading Client file: " .. v .. "\n")

		elseif string.StartWith(v,"sh_") then
			include("npcdrops/" .. v)
			MsgC(Color(255, 255, 0), "[npcDrops] Loading Shared file: " .. v .. "\n")
		end
	end	




end

if SERVER then
	local files = file.Find( "npcdrops/*", "LUA" )
	for _,v in pairs(files) do
		if string.StartWith(v,"cl_") then
			AddCSLuaFile("npcdrops/" .. v)
			MsgC(Color(255, 255, 0), "[npcDrops] Loading Client file: " .. v .. "\n")
		elseif string.StartWith(v,"sh_") then
			AddCSLuaFile("npcdrops/" .. v)
			include("npcdrops/" .. v)
			MsgC(Color(255, 255, 0), "[npcDrops] Loading Shared file: " .. v .. "\n")
		elseif string.StartWith(v,"sv_") then
			include("npcdrops/" .. v)
			MsgC(Color(255, 255, 0), "[npcDrops] Loading Server file: " .. v .. "\n")
		end
	end



end







