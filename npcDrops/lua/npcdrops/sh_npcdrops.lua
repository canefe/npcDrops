-- npcDrops base file - npcDrops by cmetopapa
AddCSLuaFile()
local version = "1.4" 

local npcDrops = npcDrops or {} -- in-lua data 

npcDrops.debug = false -- debug thing for just 100% rate to drop.
local changelog
local con = http.Fetch( "https://raw.githubusercontent.com/canefe/npcDrops/master/changelog",
	function( body, len, headers, code )
		changelog = body

	end,
	function( error )
		changelog = "ERROR"
	end
 )

local dropsTable
if SERVER then util.AddNetworkString("npcDrops_menu")
util.AddNetworkString("npcDrops_new")
util.AddNetworkString("npcDrops_edit")
util.AddNetworkString("npcDrops_delete")
util.AddNetworkString("npcDrops_reset")
end

local rgb = Color

	local function tables_exist()
		local query,result
		print("")
		print("==============================================================")
		MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Loading npcDrops, checking databases...\n"  )


		if (sql.TableExists("npcdrops_data")) then
			MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Databases ok, loading completed.\n"  )
		else
			if (!sql.TableExists("npcdrops_data")) then
				query = "CREATE TABLE npcdrops_data ( npc_id varchar(255), ent varchar(255), chance float, ship bool )"
				result = sql.Query(query)
				if (sql.TableExists("npcdrops_data")) then
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Database npcdrops_data succesfully created.\n"  )
					sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `ent`, `chance`, `ship`)VALUES ('npc_combine_camera', 'item_battery', '0.1', 'false')" )
				else
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Error occured when creating database.\n"  )
					Msg( sql.LastError( result ) .. "\n" )
				end
			end
		end

		print("==============================================================")
		print("")
		
	end
	hook.Add("Initialize", "npcDrops Init", tables_exist)
	
	local function createError(msg) -- or notif maybe

		for k,v in pairs(player.GetHumans()) do

			if v:IsAdmin() then


				v:SendLua("LocalPlayer():EmitSound('HL1/fvox/beep.wav')")
				v:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[["..msg.."]]}chat.AddText(unpack(tab))")

			end

		end

	end

	local function npcDropsShipment(ply, ent, pos, chance)
		local foundKey
		local checking
		for k,v in pairs(CustomShipments) do
			if table.HasValue(CustomShipments[k], ent) then checking = true end
			if v.entity == ent then

				foundKey = k
			end


		end

		if not checking then
			createError("\nAn error occured about shipments! \nSomething wrong with shipment entity!\n"..ent.." is not a valid shipment.\n")

			MsgC( Color( 255, 0, 0 ), "[ERROR]", rgb(230, 126, 34), " <npcDrops>: ", rgb(231, 76, 60), " An error occured: \nSomething wrong with shipment entity!\n"..ent.." is not a valid shipment.\n"  )
			return
		end

		local shipment = ents.Create("spawned_shipment") -- creating a shipment
		shipment.SID = ply.SID -- setting SID
		shipment:Setowning_ent(ply)
		shipment:SetContents(foundKey, 1)

		shipment:SetPos(pos)
		shipment.nodupe = true
		shipment:Spawn()
		shipment:SetPlayer(ply)
		shipment:SetModel("models/Items/item_item_crate.mdl") -- shipment model
		shipment:PhysicsInit(SOLID_VPHYSICS) -- phys
		shipment:SetMoveType(MOVETYPE_VPHYSICS)
		shipment:SetSolid(SOLID_VPHYSICS)	

		local phys = shipment:GetPhysicsObject()
		phys:Wake()

		if GetConVar("npcdrops_itemremove"):GetBool() then -- Item Removing
			timer.Simple(GetConVar("npcdrops_itemremovedly"):GetInt(), function()
				if not IsValid(shipment) then return end
				shipment:Remove()


			end)
		end

		if CustomShipments[foundKey].onBought then
			CustomShipments[foundKey].onBought(ply, CustomShipments[foundKey], weapon)
		end
		hook.Call("playerBoughtShipment", nil, ply, CustomShipments[foundKey], weapon)
	end

	local function newNPCDrops(npc,ent,rate,ship) -- creating new npcDrops

			sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `ent`, `chance`, `ship`)VALUES ('"..npc.."', '"..ent.."', '"..rate.."', '"..tostring(ship).."')" )
			local result = sql.Query( "SELECT npc_id, ent, chance, ship FROM npcdrops_data WHERE npc_id = '"..npc.."'" )
			if (result) then
		
				createError("\nSuccessfully created npcdrops with id "..npc)

			else
				Msg("Something went wrong with creating a players info !\n")
			end
	end

	local function saveNPCDrops( npc,enti,ratev,shipe ) -- saving npcDrops


		local evo = tostring(shipe)
		local query = "UPDATE npcdrops_data SET ent = '"..enti.."', chance = '"..ratev.."', ship = '"..evo.."' WHERE npc_id = '"..npc.."'"
		sql.Query(query)

		createError("\nSuccessfully edited npc with id "..npc)

	end

	local function loadNPCDrops() -- loading Table


		if not (sql.TableExists("npcdrops_data")) then return end

		local res = sql.Query( "SELECT * FROM npcdrops_data" )
		if not istable(res) then return end

		return res


	end

	local function deleteNPCDrops(code,npc) -- Deleting a npcDrops


		if not (code == 1) then 
			if not (sql.TableExists("npcdrops_data")) then return end
		elseif (code == 1) then end

		if not (code == 1) then
		local res = sql.Query( "SELECT * FROM npcdrops_data" )
		if not istable(res) then return end
		elseif (code == 1) then end

		local query,result

		if code and code == 1 then
				sql.Query("DROP TABLE npcdrops_data")
				timer.Simple(2, function()

				query = "CREATE TABLE npcdrops_data ( npc_id varchar(255), ent varchar(255), chance float, ship bool )"
				res = sql.Query( "SELECT * FROM npcdrops_data" )
				result = sql.Query(query)
				if (sql.TableExists("npcdrops_data")) then
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Database npcdrops_data succesfully created.\n"  )
					sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `ent`, `chance`, `ship`)VALUES ('npc_combine_camera', 'item_battery', '0.1', 'false')" )
					createError("Successfully resetted database.")
				else
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Error occured when creating database.\n"  )
					Msg( sql.LastError( result ) .. "\n" )
					createError("Error occured when resetting! Better check console and restart server!")
				end
				end)
			return
		end
		if not npc then return end
			query = "DELETE FROM npcdrops_data WHERE npc_id = '"..npc.."'"
			result = sql.Query(query)

			if result == false then
				createError("Problem with deleting a npcdrop! Check error on console.\n")
				createError(sql.LastError())
			else
				createError("Successfully deleted!\n")
			end
		


	end

	net.Receive("npcDrops_new", function(len,pl)

		local npcid = net.ReadString()
		local entid = net.ReadString()
		local rate  = net.ReadFloat()
		local ship  = net.ReadBool()

		newNPCDrops(npcid,entid,rate,ship)

	end)

	net.Receive("npcDrops_edit", function(len,pl)

		local npcide = net.ReadString()
		local entide = net.ReadString()
		local rated  = net.ReadFloat()
		local shipx  = net.ReadString()


		saveNPCDrops(npcide,entide,rated,tobool(shipx))

	end)

	net.Receive("npcDrops_delete", function(len,pl)


		local npcid = net.ReadString()
		



		deleteNPCDrops(0, npcid)



	end)

	net.Receive("npcDrops_reset", function(len,pl)


		deleteNPCDrops(1)


	end)

	concommand.Add("+npcDrops", function(ply,cmd,arg)

			if not IsValid(ply) then return end
			if ply:IsAdmin() then else return end

			local table = sql.Query( "SELECT * FROM npcdrops_data")
			if not (IsValid(table) || istable(table)) then createError("Error occured with database. Please reset npcDrops.") return end

			ply:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Menu is loading...]]}chat.AddText(unpack(tab))")

			net.Start("npcDrops_menu")
				net.WriteTable(table)
			net.Send(ply)


	end)

	local function getvName(class)
		 for k,v in pairs( weapons.GetList() ) do

			if (v.ClassName == class) then
				if not isstring(v.PrintName) then return class end
				return v.PrintName

			end
			
		end

		for n,l in pairs(scripted_ents.GetList()) do

			if (n == class) then

				if not isstring(l.t.PrintName) then return class end
				return l.t.PrintName


			end


		end
		return class

	end

	local lootSound = sound.Add( {
	name = "npcdrops_lootsound",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = { 95, 110 },
	sound = "npcdrops/lootdrop.wav"
} )


local function Anakinn(number)
	number = tonumber(number)
	if number==0 or number>1 then return end

	local kalan = number%0.1
	number = number-kalan

	return number
end

	local function onEnpisiKild(npc,killer,weapon)
		if not killer then return end
		if not killer:IsPlayer() then return end
		if killer:IsVehicle() and killer:GetDriver():IsPlayer() then killer = killer:GetDriver() end
		local dropsTable = loadNPCDrops()

		if not (IsValid(dropsTable) || istable(dropsTable)) then createError("Error occured with database. Please reset npcDrops.") return end


		if GetConVar("npcdrops_disabled"):GetBool() then return end
		local shouldNotify = GetConVar("npcdrops_notify"):GetBool()
		local chance
		


		for k,v in pairs(dropsTable) do

			if npcDrops.debug and (killer:IsAdmin()) then chance = 1 else chance = v.chance end
			if npc:GetClass() == v.npc_id then

				if not (chance == 1) then

					local rate = math.Rand( 0, 1 )

					if rate <= tonumber(v.chance) then else print("[npcDrops] NPC_id: "..v.npc_id.." didn't dropped. Chance Rate: "..v.chance.." was rate:"..rate.." "..tonumber(v.chance)) return end
					

				end

				if GetConVar("npcdrops_lootsound"):GetBool() then killer:EmitSound("npcdrops_lootsound") end
				if tobool(v.ship) then
					npcDropsShipment(killer, v.ent, npc:GetPos())
					print("[npcDrops] NPC_id: "..v.npc_id.." dropped shipment. Chance Rate: "..v.chance.." was rate:")
					if shouldNotify and (math.floor(v.chance) != 1) then killer:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Congratulations! You have dropped '"..getvName(v.ent).."' with rate "..v.chance.."!]]}chat.AddText(unpack(tab))") end
				else


						

					local check


						




						local item = ents.Create(v.ent)
						item:SetNWBool("isnpcDrop",true)
						item:SetNWInt("npcDropdly", CurTime() + GetConVar("npcdrops_itemremovedly"):GetInt())
						item:SetNWString("npcDropname", getvName(v.ent))
						item:SetNWInt("npcDroprate", tonumber(v.chance))




						
						if not IsValid(item) then check = 1 end

						if check == 1 then
							createError("\nAn error occured about entity! \nSomething wrong with entity!\n"..v.ent.." is not a valid entity!\n")

							MsgC( Color( 255, 0, 0 ), "[ERROR]", rgb(230, 126, 34), " <npcDrops>: ", rgb(231, 76, 60), " An error occured: \nSomething wrong with entity!\n"..v.ent.." is not a entity!\n"  )
							return
						end	
						item:SetPos( npc:GetPos() + Vector(0,0,50) )







						item:Spawn()



						print("[npcDrops] NPC_id: "..v.npc_id.." dropped item. Chance Rate: "..v.chance)
						if shouldNotify and (tonumber(v.chance) <= 0.8) then killer:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Congratulations! You have dropped '"..getvName(v.ent).."' with rate "..Anakinn(v.chance).."!]]}chat.AddText(unpack(tab))") end
						if GetConVar("npcdrops_itemremove"):GetBool() then
							timer.Simple(GetConVar("npcdrops_itemremovedly"):GetInt(), function()
								if not IsValid(item) then return end
								--if IsValid(item:GetOwner()) then return end



								item:Remove()


							end)
						end




				end


			end
		end

	end

	hook.Add("OnNPCKilled", "DropShipOnNPCKilled", onEnpisiKild)


--[[--[[-------------------------------------------------------------------------
	CLIENT SIDE
---------------------------------------------------------------------------]]
if SERVER then return end

if CLIENT then




		local matBlurScreen = Material( "pp/blurscreen" )
	surface.CreateFont( "npcdrops_headerFont", {
		font = "UiBold",
		size = 12,
		weight = 450,
	} )
	surface.CreateFont("npcDrops_itemFont", {font = "Roboto", size = 100, shadow = true,  extended = true})



	hook.Add("PostDrawOpaqueRenderables","npcDrops draw", function() -- loot labels


		for k,v in pairs(ents.GetAll()) do

			 if v:GetNWBool("isnpcDrop", false) then
			 	local backgroundColor = rgb(44, 62, 80, 230)
			 	local textV = 1

			 	if v:GetNWInt("npcDroprate") < 0.6 then textV = 2  end

			 	if v:GetNWInt("npcDroprate") < 0.4 then textV = 3  end

			 	if v:GetNWInt("npcDroprate") < 0.2 then textV = 4  end

			 	if v:GetNWInt("npcDroprate") < 0.1 then textV = 5  end

				if v:GetPos():Distance( LocalPlayer():GetPos() ) < 250 then 
						local som = -(v:GetModelBounds()[2]) + 15

						cam.Start3D2D( v:GetPos() + Vector(0,0,som) , Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ), 0.02 )
							surface.SetDrawColor( backgroundColor )
							surface.SetFont("npcDrops_itemFont")
							local ew, eh = surface.GetTextSize(v:GetNWString("npcDropname"))
							local fw = (ew + 500)
							local xpos = (-ew * 0.5) 
							
							surface.DrawRect( xpos - 230, 0 + math.sin( CurTime() ) * 50, fw, 200 )
							if textV == 1 then
								surface.DrawRect( -300, -180 + math.sin( CurTime() ) * 50, 600  , 180 )
								DrawElectricText(1, "BASIC", "npcDrops_itemFont", -130, -150 + math.sin( CurTime() ) * 50, rgb(39, 174, 96), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)								
								draw.SimpleText( v:GetNWString("npcDropname"), "npcDrops_itemFont", 0, 90 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
							end
							if textV == 2 then
								surface.DrawRect( -300, -180 + math.sin( CurTime() ) * 50, 600  , 180 )
								draw.SimpleText( v:GetNWString("npcDropname"), "npcDrops_itemFont", 0, 90 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
								DrawElectricText(1, "COMMON", "npcDrops_itemFont", -200, -150 + math.sin( CurTime() ) * 50, rgb(243, 156, 18), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							end
							if textV == 3 then
								surface.DrawRect( -300, -180 + math.sin( CurTime() ) * 50, 600, 180 )
								draw.SimpleText( v:GetNWString("npcDropname"), "npcDrops_itemFont", 0, 90 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
								DrawFadingText(1, "UNCOMMON", "npcDrops_itemFont", -240, -150 + math.sin( CurTime() ) * 50, rgb(22, 160, 133), rgb(44, 62, 80))
								
							end
							if textV == 4 then
								surface.DrawRect( -300, -180 + math.sin( CurTime() ) * 50, 600, 180 )
								draw.SimpleText( v:GetNWString("npcDropname"), "npcDrops_itemFont", 0, 90 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
								DrawEnchantedText(2, "RARE", "npcDrops_itemFont", -110, -150 + math.sin( CurTime() ) * 50, Color(255, 0, 0), Color(0, 0, 255))
							end
							if textV == 5 then
								
								surface.DrawRect( -300, -180 + math.sin( CurTime() ) * 50, 600  , 180 )
								draw.SimpleText( v:GetNWString("npcDropname"), "npcDrops_itemFont", 0, 90 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
								DrawRainbowText(5, "EPIC", "npcDrops_itemFont", -100, -150 + math.sin( CurTime() ) * 50)
							end

						cam.End3D2D()
					if GetConVar("npcdrops_itemremove"):GetBool() then
						cam.Start3D2D( v:GetPos() + Vector( 0, 0, 15 ), Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ), 0.02 )
							surface.SetDrawColor( Color( 235, 189, 99, 50 ) )
							surface.DrawRect( -400, 0 + math.sin( CurTime() ) * 50, 800, 100 )
							draw.SimpleText( "Removing after: "..math.floor((v:GetNWInt("npcDropdly") - CurTime())), "npcDrops_itemFont", 0, 50 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						cam.End3D2D()
					end	
				end			 	

			 end

		end

	end)

	local function npcDropsChangelog()

		local frame = vgui.Create( "DFrame" )
		frame:SetSize( 400, 400 )
		frame:Center()
		frame:SetTitle("npcDrops ~ Changelog")

		frame:MakePopup()
		frame:ShowCloseButton( false )
		frame.Paint = function(s, w, h)
				surface.SetMaterial( matBlurScreen )
				surface.SetDrawColor( 255, 255, 255, 255 )				
				local wx, wy = frame:GetPos()
				local us = wx / ScrW()
				local vs = wy / ScrH()
				local ue = ( wx + w ) / ScrW()
				local ve = ( wy + h ) / ScrH()
		
				local ew = 16
				
				for i = 1, ew do
					
					matBlurScreen:SetFloat( "$blur", 1 * 5 * ( i / ew ) )
					matBlurScreen:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRectUV( 0, 0, w, h, us, vs, ue, ve )
					
				end
surface.SetDrawColor( rgb(52, 73, 94, 50) )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( Color( 40, 40, 40, 100 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( rgb(44, 62, 80) )
			surface.DrawRect( 0, 0, w - 22, 22 )		
		end

		local btn_close = vgui.Create( "DButton", frame )
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( frame:GetWide() - 22, 0 )

		btn_close.DoClick = function()
			--frame:SizeTo( 5, 5, 1, 0, -1 )
			--timer.Simple(1, function()
				frame:Remove()
			--end)
		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end

		local richtext = vgui.Create( "RichText", frame )
		richtext:Dock( FILL )

		richtext:SetText( (changelog or "ERROR") )


		function richtext:PerformLayout()

			self:SetFontInternal( "Trebuchet18" )
			self:SetBGColor( rgb(44, 62, 80, 200) )

		end

	end




	local function npcDropsEdit(npc_id,ent,rate,ship)
		local frame = vgui.Create( "DFrame" )
		frame:SetSize( 200, 200 )
		frame:Center()
		frame:SetTitle("Editing: "..npc_id)

		frame:MakePopup()
		frame:ShowCloseButton( false )
		frame.Paint = function(s, w, h)
				surface.SetMaterial( matBlurScreen )
				surface.SetDrawColor( 255, 255, 255, 255 )				
				local wx, wy = frame:GetPos()
				local us = wx / ScrW()
				local vs = wy / ScrH()
				local ue = ( wx + w ) / ScrW()
				local ve = ( wy + h ) / ScrH()
		
				local ew = 16
				
				for i = 1, ew do
					
					matBlurScreen:SetFloat( "$blur", 1 * 5 * ( i / ew ) )
					matBlurScreen:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRectUV( 0, 0, w, h, us, vs, ue, ve )
					
				end
surface.SetDrawColor( rgb(52, 73, 94, 50) )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( Color( 40, 40, 40, 100 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( rgb(44, 62, 80) )
			surface.DrawRect( 0, 0, w - 22, 22 )		
		end

		local btn_close = vgui.Create( "DButton", frame ) 
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( frame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
			--frame:SizeTo( 5, 5, 1, 0, -1 )
			--timer.Simple(1, function()
				frame:Remove()
			--end)
		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		

		local npcidraw = npc_id

		local entityidraw
		local TextEntry = vgui.Create( "DTextEntry", frame ) 
			TextEntry:SetPos( 20, 50 )
			TextEntry:SetSize( 170, 20 )
			TextEntry:SetText( ent )
			TextEntry:SetTooltip("Add entity to spawn")
			TextEntry:SetUpdateOnType( true )
			entityidraw = TextEntry:GetValue()
			function TextEntry:OnValueChange( val )
				
				if not (val == "") then
					entityidraw = val
				else
					entityidraw = nil
				end


			end

		local boolis = ship 
		local boolCheckbox = vgui.Create( "DCheckBox", frame ) 
			boolCheckbox:SetPos( 20, 100 )
			boolCheckbox:SetValue(ship)
			boolCheckbox:SetTooltip("Is Shipment? (only DarkRP 2.5+)")
			function boolCheckbox:OnChange( bVal )
				if ( bVal ) then
					boolis = true
				else
					boolis = false
				end
			end

			local NumberWangValue = rate
			local DermaNumSlider = vgui.Create( "DNumSlider", frame )
			DermaNumSlider:SetPos( 20, 70 )		
			DermaNumSlider:SetWide(150)
			DermaNumSlider:SetText( "Chance Rate" )
			DermaNumSlider:SetMin( 0.01 )
			DermaNumSlider:SetValue(rate)
			DermaNumSlider:SetMax( 1 )			
			DermaNumSlider:SetDecimals( 2 )

			function DermaNumSlider:OnValueChanged( val )

				NumberWangValue = val


			end	






		local richtext = vgui.Create( "RichText", frame )
		richtext:SetPos( 0, 150)
		richtext:SetSize( 200, 200)
		richtext:SetText("VAYYYYY")

		function richtext:PerformLayout()

			self:SetFontInternal( "Trebuchet18" )


		end
		richtext:InsertColorChange( 44, 62, 80, 255 )
		richtext:SetVerticalScrollbarEnabled( false )

		local btn_submit = vgui.Create( "DButton", frame )
		btn_submit:SetText( "Save" )
		btn_submit:SetTall(20)
		btn_submit:SetWide(100)
		btn_submit:SetPos( 20, 120 )
		btn_submit:SetTooltip( "Click here to save this npcdrop" )
		btn_submit:SetFont("Trebuchet18")
		btn_submit:SetTextColor(Color(255,255,255))
		btn_submit.DoClick = function()
			local anyerror = 0
			--if npcidraw then richtext:AppendText("NPCID is OK.") else  richtext:AppendText("NPCID is invalid!") anyerror = anyerror + 1 end
			if entityidraw then richtext:AppendText("EntityID is OK.") else  richtext:AppendText("EntityID is invalid!") anyerror = anyerror + 1 end 
			if not (anyerror == 0) then return end
			print("[npcDrops] Editing: ", npcidraw, " with values: ", entityidraw, NumberWangValue, boolis)
			net.Start("npcDrops_edit")
				net.WriteString(npcidraw)
				net.WriteString(entityidraw)
				net.WriteFloat(tonumber(NumberWangValue))
				net.WriteString(tostring(boolis))

			net.SendToServer()
			frame:Close()




		end
		btn_submit.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
				end
		end			


	end

	local function npcDropsList(tbl, code)

	local DFrame = vgui.Create( "DFrame" )
	DFrame:SetSize( 570, 30 )
	DFrame:SizeTo( 570, 600, 1, 0, -1 )
	DFrame:Center() 
	DFrame:MakePopup()
	local text
	if code and code == 1 then
		text = "npcDrops ~ Delete a npcDrop"
	else
		text = "npcDrops ~ Edit a npcDrop"
	end 
	DFrame:SetTitle(text)
	DFrame:ShowCloseButton( false )
	--DFrame:SlideUp( 30 )
		local btn_close = vgui.Create( "DButton", DFrame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		--btn_close:SetTooltip( "close" )
		

		--btn_submit:Dock( TOP )
		--btn_submit:DockMargin( 0, 0, 0, 5 )
		btn_close.DoClick = function()
			--DFrame:SizeTo( 5, 5, 1, 0, -1 )
			--timer.Simple(1, function()
				DFrame:Remove()
			--end)
		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		
	DFrame.Paint = function(s, w, h)
				surface.SetMaterial( matBlurScreen )
				surface.SetDrawColor( 255, 255, 255, 255 )				
				local wx, wy = DFrame:GetPos()
				local us = wx / ScrW()
				local vs = wy / ScrH()
				local ue = ( wx + w ) / ScrW()
				local ve = ( wy + h ) / ScrH()
		
				local ew = 16
				
				for i = 1, ew do
					
					matBlurScreen:SetFloat( "$blur", 1 * 5 * ( i / ew ) )
					matBlurScreen:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRectUV( 0, 0, w, h, us, vs, ue, ve )
					
				end


surface.SetDrawColor( rgb(52, 73, 94, 50) )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( Color( 40, 40, 40, 100 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( rgb(44, 62, 80) )
			surface.DrawRect( 0, 0, w - 22, 22 )				


		end

	local DScrollPanel = vgui.Create( "DScrollPanel", DFrame )
	DScrollPanel:SetSize( 565, 540 )
	DScrollPanel:SetPos( 5, 500 )
	DScrollPanel:Dock( FILL )
	DScrollPanel:Center()

	local sbar = DScrollPanel:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, rgb(231, 76, 60) )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, rgb(231, 76, 60) )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, rgb(189, 195, 199) )
	end

	local function dermaCallback(npc)



				net.Start("npcDrops_delete")

					
					--net.WriteString("no")
					net.WriteString( npc )


				net.SendToServer()



	end

local isEmpty = 0
	for k,v in pairs(tbl) do

		if not (v.npc_id == "npc_combine_camera") then

			local DLabel = DScrollPanel:Add( "DButton" )
			DLabel:SetText( v.npc_id )
			DLabel:SetTall(50)
			DLabel:SetFont("Trebuchet24")
			DLabel:SetToolTip(" [Entity: "..v.ent.. "] [Chance: ".. v.chance.. "] [isShip: ".. v.ship.. "]")
			DLabel:SetTextColor(Color(255,255,255))
			DLabel:Dock( TOP )
			DLabel:DockMargin( 0, 0, 0, 5 )
				DLabel.Paint = function(s, w, h)
					if s:IsHovered() then 
						draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
					else
						draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43, 200))
					end
				end

			DLabel.DoClick = function()
				DFrame:Remove()
				if code and code == 1 then
					Derma_Query( "Are you sure to delete "..v.npc_id.." ?", "npcDrops Delete", "Yes", function() dermaCallback(v.npc_id) end, "No", function() end)

					return
				end
				npcDropsEdit(v.npc_id,v.ent,v.chance,v.ship)

			end
			isEmpty = isEmpty + 1


		end
	end

		if (isEmpty >= 1) then isEmpty = false else isEmpty = true end
		if isEmpty then
		local notd = vgui.Create( "DLabel", DFrame )
		notd:SetPos( 40, 40 )
		notd:SetText( "There is no npcDrops. May you add a few." )
		notd:SizeToContents()
		end
end



	local function npcDrops(tbl)
		if not istable(tbl) then return end

		local frame = vgui.Create( "DFrame" )
		frame:SetSize( 200, 200 )
		frame:Center()
		frame:SetTitle("npcDrops ~ Create New")
		frame:MakePopup()
		frame:ShowCloseButton( false )
		frame.Paint = function(s, w, h)
		frame.Paint = function(s, w, h)
				--draw.RoundedBox(0,0,0,w,h,rgb(52, 152, 219, 200))
				--draw.RoundedBox(0,0,0,w,24,rgb(41, 128, 185))
				--draw.SimpleText("<npcDrops>: Menu", "UiBold", 90,12.5, rgb(236, 240, 241), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				surface.SetMaterial( matBlurScreen )
				surface.SetDrawColor( 255, 255, 255, 255 )				
				local wx, wy = frame:GetPos()
				local us = wx / ScrW()
				local vs = wy / ScrH()
				local ue = ( wx + w ) / ScrW()
				local ve = ( wy + h ) / ScrH()
		
				local ew = 16
				
				for i = 1, ew do
					
					matBlurScreen:SetFloat( "$blur", 1 * 5 * ( i / ew ) )
					matBlurScreen:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRectUV( 0, 0, w, h, us, vs, ue, ve )
					
				end
surface.SetDrawColor( rgb(52, 73, 94, 50) )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( Color( 40, 40, 40, 100 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( rgb(44, 62, 80) )
			surface.DrawRect( 0, 0, w - 22, 22 )		
		end

		end
		local btn_close = vgui.Create( "DButton", frame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( frame:GetWide() - 22, 0  )
		--btn_close:SetTooltip( "close" )
		

		--btn_submit:Dock( TOP )
		--btn_submit:DockMargin( 0, 0, 0, 5 )
		btn_close.DoClick = function()
			--frame:SizeTo( 5, 5, 1, 0, -1 )
				frame:Remove()
		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		

		local npcidraw
		local npcID = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
			npcID:SetPos( 20, 30 )
			npcID:SetSize( 170, 20 )
			npcID:SetText( "npc_" )

			npcID:SetTooltip("Add npc to death loot")
			npcID:SetUpdateOnType( true )
			function npcID:OnValueChange( val )
				
				npcidraw = val


			end

		local entityidraw = "sent_ball"
		local TextEntry = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
			TextEntry:SetPos( 20, 50 )
			TextEntry:SetSize( 170, 20 )
			TextEntry:SetText( "sent_ball" )
			TextEntry:SetTooltip("Add entity to spawn")
			TextEntry:SetUpdateOnType( true )
			function TextEntry:OnValueChange( val )
				
				entityidraw = val


			end

		local boolis = false
		local boolCheckbox = vgui.Create( "DCheckBox", frame ) -- create the form as a child of frame
			boolCheckbox:SetPos( 20, 100 )
			boolCheckbox:SetValue(false)
			boolCheckbox:SetTooltip("Is Shipment? (only DarkRP 2.5+)")	
			function boolCheckbox:OnChange( bVal )
				if ( bVal ) then
					boolis = true
				else
					boolis = false
				end
			end


			local NumberWangValue
			local DermaNumSlider = vgui.Create( "DNumSlider", frame )
			DermaNumSlider:SetPos( 20, 70 )		
			DermaNumSlider:SetWide(150)	
			DermaNumSlider:SetText( "Chance Rate" )
			DermaNumSlider:SetMin( 0.01 )			
			DermaNumSlider:SetMax( 1 )			
			DermaNumSlider:SetDecimals( 2 )
			NumberWangValue = 0.5

			function DermaNumSlider:OnValueChanged( val )

				NumberWangValue = val


			end	
		local richtext = vgui.Create( "RichText", frame )
		--richtext:Dock( FILL )
		richtext:SetPos( 0, 150)
		richtext:SetSize( 200, 40)
		

		function richtext:PerformLayout()

			self:SetFontInternal( "Default" )
			self:SetBGColor( Color( 64, 64, 92 ) )


		end
		-- == created by The Godfather #1 == --
		richtext:InsertColorChange( 255,255,255,255 )
		richtext:SetVerticalScrollbarEnabled( false )



		local btn_submit = vgui.Create( "DButton", frame ) -- create the form as a child of frame
		btn_submit:SetText( "Add New" )
		btn_submit:SetTall(20)
		btn_submit:SetWide(100)
		btn_submit:SetPos( 20, 120 )
		btn_submit:SetTooltip( "Click here to add new npcdrop" )
		btn_submit:SetTextColor(Color(255,255,255))
		btn_submit.DoClick = function()
			local anyerror = 0
			local checke
			for k,v in pairs(tbl) do
				if (v.npc_id == npcidraw) then
					checke = 1
					break
				end
				checke = 0
			end
			if npcidraw and entityidraw then richtext:SetText("OK.") else  richtext:SetText(" NPCID or EntityID is invalid!") anyerror = anyerror + 1 end
			if (checke == 1) then richtext:AppendText("Already a npc with this id! ") anyerror = anyerror + 1 end
			

			if not (anyerror == 0) then richtext:InsertFade( 6, 2 ) return end
			
			net.Start("npcDrops_new")
				net.WriteString(npcidraw)
				net.WriteString(entityidraw)

				net.WriteFloat(tonumber(NumberWangValue))
				net.WriteBool(boolis)
			net.SendToServer()
			frame:Close()



		end
		btn_submit.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
				end
		end







		


	end

	local function npcDropsGUI()

		local tbl = net.ReadTable()
		local isEnabled = not GetConVar("npcdrops_disabled"):GetBool()
		local DFrame = vgui.Create( "DFrame" )
		DFrame:SetSize( 570, 30 )
		DFrame:SizeTo( 570, 350, 1, 0, -1 )
		DFrame:Center() 
		DFrame:MakePopup()
		DFrame:SetTitle("npcDrops ~ Main Menu")
		DFrame:ShowCloseButton( false )
		local btn_close = vgui.Create( "DButton", DFrame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
			--DFrame:SizeTo( 5, 5, 1, 0, -1 )
			--timer.Simple(1, function()
				DFrame:Remove()
			--end)
		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		
		DFrame.Paint = function(s, w, h)
				surface.SetMaterial( matBlurScreen )
				surface.SetDrawColor( 255, 255, 255, 255 )				
				local wx, wy = DFrame:GetPos()
				local us = wx / ScrW()
				local vs = wy / ScrH()
				local ue = ( wx + w ) / ScrW()
				local ve = ( wy + h ) / ScrH()
		
				local ew = 16
				
				for i = 1, ew do
					
					matBlurScreen:SetFloat( "$blur", 1 * 5 * ( i / ew ) )
					matBlurScreen:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRectUV( 0, 0, w, h, us, vs, ue, ve )
					
				end

--[[			surface.SetDrawColor( rgb(52, 73, 94, 50) )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( Color( 40, 40, 40, 100 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( rgb(44, 62, 80) )
			surface.DrawRect( 0, 0, w - 22, 22 )	]]

surface.SetDrawColor( rgb(52, 73, 94, 50) )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( Color( 40, 40, 40, 100 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( rgb(44, 62, 80) )
			surface.DrawRect( 0, 0, w - 22, 22 )				

			end

		local DScrollPanel = vgui.Create( "DScrollPanel", DFrame )
		DScrollPanel:SetSize( 565, 300 )
		DScrollPanel:SetPos( 5, 500 )
		DScrollPanel:Dock( FILL )
		DScrollPanel:Center()

		local sbar = DScrollPanel:GetVBar()
		function sbar:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		function sbar.btnUp:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, rgb(231, 76, 60) )
		end
		function sbar.btnDown:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, rgb(231, 76, 60) )
		end
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, rgb(189, 195, 199) )
		end
	
			local DLabel = DScrollPanel:Add( "DButton" )
			DLabel:SetText( "New NPCDrop" )
			DLabel:SetTall(50)
			DLabel:SetTooltip( "Create new NPCDrop" )
			DLabel:SetFont("Trebuchet24")
			DLabel:SetTextColor(Color(255,255,255))
			DLabel:Dock( TOP )
			DLabel:SetEnabled(isEnabled)
			local oanim = 0
			local oanimlength = 0			
			DLabel:DockMargin( 0, 0, 0, 5 )
			DLabel.Paint = function(s, w, h)
			if not (isEnabled) then draw.RoundedBox( 0, 0, 0, w, h, rgb(44, 62, 80)) return end
				if s:IsHovered() then 
					oanimlength = w 
				else
					oanimlength = 3
				end
				oanim = math.Approach(oanim,oanimlength,FrameTime()*1200)
				draw.RoundedBox( 0, 0, 0, w, h, Color(192, 57, 43, 200))
				draw.RoundedBox( 0, 0, 0, oanim, h, Color(237,74,59,255))
			end


			DLabel.DoClick = function()
				npcDrops(tbl)
				DFrame:Remove()
			end


			local DLabel2 = DScrollPanel:Add( "DButton" )
			DLabel2:SetText( "Edit existed NPCDrop" )
			DLabel2:SetTall(50)
			DLabel2:SetTooltip( "Edit any created NPCDrops" )
			DLabel2:SetFont("Trebuchet24")
			DLabel2:SetTextColor(Color(255,255,255))
			DLabel2:Dock( TOP )
			DLabel2:SetEnabled(isEnabled )
			DLabel2:DockMargin( 0, 0, 0, 5 )
			local oanim2 = 0
			local oanimlength2 = 0			
			DLabel2:DockMargin( 0, 0, 0, 5 )
			DLabel2.Paint = function(s, w, h)
			if not (isEnabled) then draw.RoundedBox( 0, 0, 0, w, h, rgb(44, 62, 80)) return end
				if s:IsHovered() then 
					oanimlength2 = w 
				else
					oanimlength2 = 3
				end
				oanim2 = math.Approach(oanim2,oanimlength2,FrameTime()*1200)
				draw.RoundedBox( 0, 0, 0, w, h, Color(192, 57, 43, 200))
				draw.RoundedBox( 0, 0, 0, oanim2, h, Color(237,74,59,255))
			end

			DLabel2.DoClick = function()
				npcDropsList(tbl)
				DFrame:Remove()
			end

			local DLabel3 = DScrollPanel:Add( "DButton" )
			DLabel3:SetText( "Delete NPCDrops" )
			DLabel3:SetTall(50)
			DLabel3:SetTooltip( "Delete a NPCDrop" )
			DLabel3:SetFont("Trebuchet24")
			DLabel3:SetTextColor(Color(255,255,255))
			DLabel3:Dock( TOP )
			DLabel3:SetEnabled(isEnabled )
			DLabel3:DockMargin( 0, 0, 0, 5 )
			local oanim3 = 0
			local oanimlength3 = 0	
			DLabel3.Paint = function(s, w, h)
				if not (isEnabled) then draw.RoundedBox( 0, 0, 0, w, h, rgb(44, 62, 80)) return end
				if s:IsHovered() then 
					oanimlength3 = w 
				else
					oanimlength3 = 3
				end
				oanim3 = math.Approach(oanim3,oanimlength3,FrameTime()*1200)
				
				draw.RoundedBox( 0, 0, 0, w, h, Color(192, 57, 43, 200))
				draw.RoundedBox( 0, 0, 0, oanim3, h, Color(237,74,59,255))
			end

			DLabel3.DoClick = function()
				npcDropsList(tbl,1)
				DFrame:Remove()
			end

			local DLabel4 = DScrollPanel:Add( "DButton" )
			DLabel4:SetText( "NPCDrops Changelog" )
			DLabel4:SetTall(50)
			DLabel4:SetTooltip( "View changelog" )
			DLabel4:SetFont("Trebuchet24")
			DLabel4:SetTextColor(Color(255,255,255))
			DLabel4:Dock( TOP )
			DLabel4:DockMargin( 0, 0, 0, 5 )
			local oanim4 = 0
			local oanimlength4 = 0	
			DLabel4.Paint = function(s, w, h)

				if s:IsHovered() then 
					oanimlength4 = w 

				else
					oanimlength4 = 3


				end
				oanim4 = math.Approach(oanim4,oanimlength4,FrameTime()*1200)
				draw.RoundedBox( 0, 0, 0, w, h, Color(192, 57, 43, 200))

				draw.RoundedBox( 0, 0, 0, oanim4, h, Color(237,74,59,255))
			end

			DLabel4.DoClick = function()

				npcDropsChangelog()
				DFrame:Remove()
			end


		local richtext = vgui.Create( "RichText", DFrame )
		richtext:SetPos( 200, 330)
		richtext:SetSize( 570, 30)

		function richtext:PerformLayout()

			self:SetFontInternal( "UiBold" )


		end
		-- #credit text
		richtext:InsertColorChange( 255,255,255, 255 )
		richtext:SetVerticalScrollbarEnabled( false )
		richtext:SetFontInternal( "Trebuchet18" )

		richtext:AppendText("Created by cometopapa")
		richtext:InsertFade( 3, 2 )


		timer.Simple(5, function()
		if not IsValid(richtext) then return end
		richtext:SetText("  npcDrops v"..(version or "cracked"))
		end)
















	end
	net.Receive("npcDrops_menu",npcDropsGUI)








end



