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
local rgb=Color
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

		net.Receive("testerx", function()

		local killer = net.ReadString()

		local frame = vgui.Create("questionFlat")



		frame:SetSize(300, 200)
		frame:Center()
		frame:SetTitle("RDM - Checker")


		local richtext = vgui.Create( "RichText", frame )
		richtext:Dock( TOP )
		richtext:SetTall(100)

		richtext:SetText( "Bu bir RDM miydi?" )
		richtext:SetVerticalScrollbarEnabled( false )
		richtext:SetMouseInputEnabled(false)

		local KillerText = vgui.Create( "DLabel" , frame )
		KillerText:SetFont("cool30")
		KillerText:SetText("Katil: "..(killer or "NaN"))
		KillerText:SizeToContents()
		KillerText:SetPos(20,70)

		local Y = vgui.Create( "DButton", frame )
		Y:SetText( "Evet" )
		Y:SetTall(40)
		Y:SetWide(70)
		Y:SetPos( 20, 120 )
		Y:SetTooltip( "RDM ise buna bas." )
		Y:SetFont("cool18")
		Y:SetTextColor(Color(255,255,255))
		Y.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
				end
		end

		Y.DoClick = function()

			frame:Close()

		end


		local N = vgui.Create( "DButton", frame )
		N:SetText( "Hayır" )
		N:SetTall(40)
		N:SetWide(70)
		N:SetPos( 120, 120 )
		N:SetTooltip( "RDM değilse buna bas." )
		N:SetFont("cool18")
		N:SetTextColor(Color(255,255,255))
		N.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(46, 204, 113))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(39, 174, 96))
				end
		end	

		N.DoClick = function()

			frame:Close()

		end



		function richtext:PerformLayout()

			self:SetFontInternal( "cool30" )
			--self:SetBGColor( rgb(44, 62, 80, 200) )
			self:SetFGColor( Color( 255, 255, 255 ) )


		end

		timer.Simple(6 ,function()


			frame:Close()
		end)




	end)

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


	util.AddNetworkString("testerx")

	concommand.Add("testerd", function(ply,cmd,arg)

		net.Start("testerx")

		net.Send(ply)


	end)

	hook.Add("PlayerDeath","rdm_Check", function(ply,inf,att)


		if IsValid(ply) and IsValid(att) and att:IsPlayer() and ply:IsPlayer() then


		elseif IsValid(ply) and IsValid(att) and ply:IsPlayer() then

			if att:IsVehicle() then

				att = att:GetDriver()

			end

		end

		if att == ply then return end

		net.Start("testerx")

			net.WriteString(att:Name())

		net.Send(ply)





	end)

end







