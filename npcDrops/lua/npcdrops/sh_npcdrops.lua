<<<<<<< HEAD
-- npcDrops base file - npcDrops by cmetopapa
AddCSLuaFile()
local version = "1.6" 

npcDrops = npcDrops or {} -- in-lua data 



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
util.AddNetworkString("npcDrops_refresh")
util.AddNetworkString("npcDrops_delux")
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
				query = "CREATE TABLE npcdrops_data ( npc_id varchar(255), data varchar(51200) )"
				result = sql.Query(query)
				if (sql.TableExists("npcdrops_data")) then
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Database npcdrops_data succesfully created.\n"  )
					local testTable = {}
					testTable[1] = {
						rate = 0.3,
						ent = "sent_ball",
						shipment = false
					}
					testTable[2] = {
						rate = 0.5,
						ent = "sent_balle",
						shipment = false
					}

					sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `data`)VALUES ('npc_combine_camera', '".. util.TableToJSON( testTable ) .."')" )
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
	
	function npcDrops.notify(msg) -- or notif maybe

		for k,v in pairs(player.GetHumans()) do

			if v:IsAdmin() then

				if CLIENT then v:EmitSound("HL1/fvox/beep.wav") chat.AddText(Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),msg) return end
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
			npcDrops.notify("\nAn error occured about shipments! \nSomething wrong with shipment entity!\n"..ent.." is not a valid shipment.\n")

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

	local function newNPCDrops(npc,en,rat,shi) -- creating new npcDrops
			local testTable = {}
			testTable[1] = {
				rate = rat,
				ent = en,
				shipment = shi
			}
			sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `data`)VALUES ('"..npc.."', '".. util.TableToJSON( testTable ) .."')" )
			local result = sql.Query( "SELECT data FROM npcdrops_data WHERE npc_id = '"..npc.."'" )
			if (result) then
		
				npcDrops.notify("\nSuccessfully created npcdrops with id "..npc)

			else
				npcDrops.notify("\nError when creating: "..npc)
			end
	end


	local function saveNPCDrops( npc,enti,ratev,shipe,key,code,... ) -- saving npcDrops


		local evo = tostring(shipe)
		local tab = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..npc.."'")
		for k,v in pairs(tab) do if v.npc_id == npc then tab = util.JSONToTable(v.data) end end

		
		tab[key] = {ent=enti,rate=ratev,shipment=shipe,code=code}
		local arger = {}
		if ... then
		for k,v in pairs({...}) do
			print(k.."---".."undabe")
			--print(v.."+++")
			PrintTable(v)
			for c,a in pairs(v) do
				arger[c] = a
			end
			
		end
		print("argeris")
		PrintTable(arger)
		table.Merge(tab[key],arger)

		end
		print("tabkey")
		PrintTable(tab[key])
		local query = "UPDATE npcdrops_data SET data = '"..util.TableToJSON(tab).."' WHERE npc_id = '"..npc.."'"
		sql.Query(query)

		npcDrops.notify("\nSuccessfully edited npc with id "..npc)--]]

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

				query = "CREATE TABLE npcdrops_data ( npc_id varchar(255), data varchar(51200) )"
				res = sql.Query( "SELECT * FROM npcdrops_data" )
				result = sql.Query(query)
				if (sql.TableExists("npcdrops_data")) then
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Database npcdrops_data succesfully created.\n"  )
					local testTable = {}
					testTable[1] = {
						rate = 0.3,
						ent = "sent_ball",
						shipment = false
					}
					testTable[2] = {
						rate = 0.5,
						ent = "sent_balle",
						shipment = false
					}					sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `data`)VALUES ('npc_combine_camera', '".. util.TableToJSON( testTable ) .."')" )
					npcDrops.notify("Successfully created new database!\n")
					GetConVar("npcdrops_disabled"):SetBool(false)
				else
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Error occured when creating database.\n"  )
					Msg( sql.LastError( result ) .. "\n" )
				end
			return
		end
		if not npc then return end
			query = "DELETE FROM npcdrops_data WHERE npc_id = '"..npc.."'"
			result = sql.Query(query)

			if result == false then
				npcDrops.notify("Problem with deleting a npcdrop! Check error on console.\n")
				npcDrops.notify(sql.LastError())
			else
				npcDrops.notify("Successfully deleted!\n")
			end
		


	end

	net.Receive("npcDrops_new", function(len,pl)

		local npcid = net.ReadString()
		local entid = net.ReadString()
		local rate  = net.ReadFloat()
		local ship  = net.ReadBool()

		newNPCDrops(npcid,entid,rate,ship)

	end)

	net.Receive("npcDrops_delux", function(len,pl)


		local npcid = net.ReadString()
		local entid = net.ReadString()
		local rateid  = net.ReadFloat()
		local ship  = net.ReadBool()

		local tab = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..npcid.."'")
		local drops = util.JSONToTable(tab[1].data)

		drops[#drops + 1] = {ent=entid,rate=rateid,shipment=ship}
		local query = "UPDATE npcdrops_data SET data = '"..util.TableToJSON(drops).."' WHERE npc_id = '"..npcid.."'"
		sql.Query(query)

		npcDrops.notify("Successfully added new drop to "..npcid)	

	end) -- update 1.5 delux!

	net.Receive("npcDrops_edit", function(len,pl)

		local npcide = net.ReadString()
		local entide = net.ReadString()
		local rated  = net.ReadFloat()
		local shipx  = net.ReadString()
		local key    = net.ReadString()
		local code   = net.ReadString()
		local label  = {label = net.ReadString()}
		local labelrem = {labelrem = net.ReadString()}

		saveNPCDrops(npcide,entide,rated,tobool(shipx),key,code,label,labelrem)


	end)

	net.Receive("npcDrops_delete", function(len,pl)


		local npcid = net.ReadString()
		



		deleteNPCDrops(0, npcid)



	end)

	net.Receive("npcDrops_reset", function(len,pl)


		deleteNPCDrops(1)


	end)

	net.Receive("npcDrops_refresh", function(len,pl)
			if not IsValid(pl) then return end

			local table = sql.Query( "SELECT * FROM npcdrops_data")
			if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") return end

			net.Start("npcDrops_menu")
				net.WriteTable(table)
			net.Send(pl)
	end)

	concommand.Add("+npcDrops", function(ply,cmd,arg)

			if not IsValid(ply) then return end
			if ply:IsAdmin() then else return end

			local table = sql.Query( "SELECT * FROM npcdrops_data")
			--if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") return end
			if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") GetConVar("npcdrops_disabled"):SetBool(1) end


			if SERVER then
			ply:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Menu is loading...]]}chat.AddText(unpack(tab))")

			net.Start("npcDrops_menu")
				if IsValid(table) || istable(table) then net.WriteTable(table) end
			net.Send(ply)
		end

	end)

	hook.Add( "PlayerSay", "npcDrops_chat", function( ply, msg, group )
		local comchattable = string.Explode( " ", msg )
		if ( comchattable[1] == "!npcdrops" ) then
			if ply:IsAdmin() then
			local table = sql.Query( "SELECT * FROM npcdrops_data")
			--if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") return end
			if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") GetConVar("npcdrops_disabled"):SetBool(1) end



			ply:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Menu is loading...]]}chat.AddText(unpack(tab))")

			net.Start("npcDrops_menu")
				if IsValid(table) || istable(table) then net.WriteTable(table) end
			net.Send(ply)

			else
				ply:ChatPrint( "No Access" )
			end
			return false
		end
	end )	

	concommand.Add("npcDrops_removedrop", function(ply,cmd,arg)

		--[[ arg 1 -> npc_id arg 2 -> key

		]]
		if not IsValid(ply) then return end
		if ply:IsAdmin() then else return end

		local tab = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..arg[1].."'")
		local drops = util.JSONToTable(tab[1].data)
		--print("---------------LOK AT Menu	")
		--PrintTable(drops[1])
		local num = tonumber(math.floor(arg[2]))
		--print("num=",num)
		--PrintTable(drops[arg[2]])
		drops[num] = nil

		local query = "UPDATE npcdrops_data SET data = '"..util.TableToJSON(drops).."' WHERE npc_id = '"..arg[1].."'"
		sql.Query(query)

		npcDrops.notify("Successfully removed the drop from "..arg[1])						

	end)

	function npcDrops.getvName(class)
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

		local dropsTable = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..npc:GetClass().."'")

		if not (IsValid(dropsTable) || istable(dropsTable)) then  return end


		if GetConVar("npcdrops_disabled"):GetBool() then return end
		local shouldNotify = GetConVar("npcdrops_notify"):GetBool()
		local chance
		PrintTable(dropsTable)
		local med	
		for k,v in pairs(dropsTable) do if v.npc_id == npc:GetClass() then med = util.JSONToTable(v.data) else return end end

		local passes = {}
		for k,v in pairs(med) do
			local rate = math.Rand( 0, 1 )
			if GetConVar("npcdrops_debug"):GetBool() then v.rate = 1 end
			local hector
			--if #med == 1 then hector = med else hector = med[k] end
			if rate <= tonumber(v.rate) or v.rate == 1 then print("got you") passes[v.ent] = v end

			
		end

		local lootbox
		for k,v in pairs(passes) do

				if GetConVar("npcdrops_lootsound"):GetBool() then killer:EmitSound("npcdrops_lootsound") end
				if tobool(v.ship) then
					npcDropsShipment(killer, v.ent, npc:GetPos())
					print("[npcDrops] NPC_id: "..v.npc_id.." dropped shipment. Chance Rate: "..v.chance.." was rate:")
					if shouldNotify and (math.floor(v.chance) != 1) then killer:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Congratulations! You have dropped '"..npcDrops.getvName(v.ent).."' with rate "..v.chance.."!]]}chat.AddText(unpack(tab))") end
				else



						

					local check




						PrintTable(passes)
						local item = ents.Create(v.ent)

						if v.labelrem and tobool(v.labelrem) == false then
							print(v.labelrem,"got pasd")
						item:SetNWBool("isnpcDrop",true)
						end
						item:SetNWInt("npcDropdly", CurTime() + GetConVar("npcdrops_itemremovedly"):GetInt())
						local name
						if v.label and tobool(v.label) != false then name = v.label else name = npcDrops.getvName(v.ent) end
						item:SetNWString("npcDropname", name)
						item:SetNWInt("npcDroprate", tonumber(v.rate))
						local luaToRun = v.code
						print("vcode is=",v.code,v.labelrem)
						npcDrops.EntVal = item
						npcDrops.Killer = killer
						npcDrops.NPC 	= npc
						local playerLua = "local ENT = npcDrops.EntVal local PLY = npcDrops.Killer local NPC = npcDrops.NPC "

						if IsValid(item) and tobool(luaToRun) != false then
						print("hey")
						RunString(playerLua..luaToRun, "npcDrops-Lua")
						npcDrops.EntVal = nil
						npcDrops.Killer = nil
						npcDrops.NPC    = nil
						end
						--[[
						print("test=",table.Count(passes) == 1,table.Count(passes))
						if not (table.Count(passes) == 1) then
						local lootbox = ents.Create("npcDrops_loot")
						lootbox:SetPos(npc:GetPos())
						lootbox.itemTable = {
								ent = v.ent,
								rate = v.rate,
							}
						print("lootbox.itemtable=",lootbox.itemTable)
						PrintTable(lootbox.itemTable)

						end--]]

						
						if not IsValid(item) then check = 1 end

						if check == 1 then
							npcDrops.notify("\nAn error occured about entity! \nSomething wrong with entity!\n"..v.ent.." is not a valid entity!\n")

							MsgC( Color( 255, 0, 0 ), "[ERROR]", rgb(230, 126, 34), " <npcDrops>: ", rgb(231, 76, 60), " An error occured: \nSomething wrong with entity!\n"..v.ent.." is not a entity!\n"  )
							return
						end	
						item:SetPos( npc:GetPos() + Vector(0,0,50) )






						item:Spawn()



						print("[npcDrops] NPC_id: "..npc:GetClass().." dropped item. Chance Rate: "..v.rate)
						if shouldNotify and (tonumber(v.rate) <= 0.8) then killer:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Congratulations! You have dropped '"..npcDrops.getvName(v.ent).."' with rate "..Anakinn(v.rate).."!]]}chat.AddText(unpack(tab))") end
						if GetConVar("npcdrops_itemremove"):GetBool() then
							timer.Simple(GetConVar("npcdrops_itemremovedly"):GetInt(), function()
								if not IsValid(item) then return end

								item:Remove()


							end)
						end




				


			end
		end
			--if IsValid(lootbox) then lootbox:Spawn() end

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
	surface.CreateFont("npcDrops_DermaFont", {font = "Roboto", size = 24, shadow = true,  extended = true})



	hook.Add("PostDrawOpaqueRenderables","npcDrops draw", function() -- loot labels



		for k,v in pairs(ents.GetAll()) do

			 if v:GetNWBool("isnpcDrop", false) then

			 		if GetConVar("npcdrops_labels"):GetBool() then
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
						end
					end	
					if GetConVar("npcdrops_itemremove"):GetBool() and GetConVar("npcdrops_itemremovelabel"):GetBool() then
						cam.Start3D2D( v:GetPos() + Vector( 0, 0, 15 ), Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ), 0.02 )
							surface.SetDrawColor( Color( 235, 189, 99, 50 ) )
							surface.DrawRect( -400, 0 + math.sin( CurTime() ) * 50, 800, 100 )
							draw.SimpleText( "Removing after: "..math.floor((v:GetNWInt("npcDropdly") - CurTime())), "npcDrops_itemFont", 0, 50 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						cam.End3D2D()
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
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()


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





	local function npcDropsSettings(tbl)

		local frame = vgui.Create( "flatblur" )
		frame:SetSize( 400, 400 )
		frame:Center()
		frame:SetTitle("npcDrops ~ Settings")
		frame.OnClose = function()
		 	net.Start("npcDrops_refresh")

		 	net.SendToServer()		
		end
		frame:MakePopup()
		local DScrollPanel = vgui.Create( "flatblurScroll", frame )

		DScrollPanel:Dock( FILL )
		DScrollPanel:Center()
		DScrollPanel:SetSBColor( rgb(192, 57, 43))
			local DCollapsible = vgui.Create( "DCollapsibleCategory", DScrollPanel )	// Create a collapsible category
			DCollapsible:Dock(TOP)									 // Set position
			DCollapsible:SetSize( 400, 100 )										 // Set size
			DCollapsible:SetExpanded( 0 )											 // Is it expanded when you open the panel?
			DCollapsible:SetLabel( "General Settings" )							// Set the name ( label )
			DCollapsible.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			end

			local DCollapsible2 = vgui.Create( "DCollapsibleCategory", DScrollPanel )
			DCollapsible2:Dock(TOP)					
			DCollapsible2:SetSize( 400, 100 )					
			DCollapsible2:SetExpanded( 0 )											
			DCollapsible2:SetLabel( "Lootbox Settings" )						
			DCollapsible2.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			end

			local advancedCategory = vgui.Create( "DCollapsibleCategory", DScrollPanel )
			advancedCategory:Dock(TOP)					
			advancedCategory:SetSize( 400, 100 )					
			advancedCategory:SetExpanded( 0 )											
			advancedCategory:SetLabel( "Advanced Settings" )						
			advancedCategory.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			end

			local advancedSettings = vgui.Create( "DPanelList", frame )	
				advancedSettings:EnableHorizontal( false )			
				advancedSettings:EnableVerticalScrollbar( true )		
				advancedCategory:SetContents( advancedSettings )
	
	

				local generalBar = vgui.Create("flatblurScroll", frame)
				generalBar:SetSBColor( rgb(192, 57, 43))
				DCollapsible:SetContents( generalBar )
				local Don = vgui.Create( "DCheckBoxLabel", generalBar )
					Don:Dock( TOP )
					Don:SetText( "Disable npcDrops?" )
					Don:SetConVar( "npcdrops_disabled" )
					Don:SetValue( GetConVarNumber( "npcdrops_disabled" ) )


				local arrl = vgui.Create( "DCheckBoxLabel", generalBar )
					arrl:Dock( TOP )
					arrl:SetText( "Remove Item after a while?" )
					arrl:SetConVar( "npcdrops_itemremove" )
					arrl:SetValue( GetConVarNumber( "npcdrops_itemremove" ) )
		
					
				local arr = vgui.Create( "DNumSlider", generalBar )
					arr:Dock( TOP )
					arr:SetValue( GetConVarNumber( "npcdrops_itemremovedly" ) )
					arr:SetConVar( "npcdrops_itemremovedly" )
					arr:SetSize( 400, 90 )
					arr:SetText( "Remove item after x seconds" )
					arr:SetDecimals(2)
					arr:SetEnabled(not GetConVarNumber( "npcdrops_itemremove" ))
					arr:SetMinMax( 1 , 600 )

				local lab = vgui.Create( "DCheckBoxLabel", generalBar )
					lab:Dock( TOP )
					lab:SetText( "Enable 'removing after' label?" )
					lab:SetValue( GetConVarNumber( "npcdrops_itemremovelabel" ) )
					lab:SetConVar("npcdrops_itemremovelabel")

					

				local notex = vgui.Create( "DCheckBoxLabel", generalBar )
					notex:Dock( TOP )
					notex:SetText( "Notify player if have dropped something? \n(NOTE: If chance to drop is 100% it doesn't notify)" )
					notex:SetConVar( "npcdrops_notify" )
					notex:SetValue( GetConVarNumber( "npcdrops_notify" ) )


				local shouldsound = vgui.Create( "DCheckBoxLabel", generalBar )
					shouldsound:Dock( TOP )
					shouldsound:SetText( "Play sound when drops?" )
					shouldsound:SetConVar( "npcdrops_lootsound" )
					shouldsound:SetValue( GetConVarNumber( "npcdrops_lootsound" ) )

				local badges = vgui.Create( "DCheckBoxLabel", generalBar )
					badges:Dock( TOP )
					badges:SetText( "Enable drop labels-rarity bar?" )
					badges:SetConVar( "npcdrops_labels" )
					badges:SetValue( GetConVarNumber( "npcdrops_labels" ) )

				local debug = vgui.Create( "DCheckBoxLabel", generalBar )
					debug:Dock( TOP )
					debug:SetText( "npcDrops will discard rate chance." )
					debug:SetConVar( "npcdrops_debug" )
					debug:SetValue( GetConVarNumber( "npcdrops_debug" ) )

local function factCallback()
					net.Start("npcDrops_reset")
					net.SendToServer()
end
				local factReset = vgui.Create("DButton", generalBar)
					factReset:Dock( TOP )
					factReset:SetText( "Reset npcDrops" )
					factReset:SetTall(20)
					factReset:SetWide(100)

					factReset:SetTooltip( "Re-create npcDrops database. Will delete everything!" )
					factReset:SetFont("Trebuchet18")
					factReset:SetTextColor(Color(255,255,255))


					factReset.DoClick = function()

						Derma_Query( "Are you sure to reset addon? This can not be undone and all of created npcDrops will be removed.", "npcDrops Reset", "Yes", function() factCallback() end, "No", function() return end)



					end

					factReset.Paint = function(s, w, h)
						if s:IsHovered() then 
							draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
						else
							draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
						end
					end


				local notd = vgui.Create( "DLabel",  frame  )
				notd:Dock(BOTTOM)
				notd:SetText( "npcDrops by cometopapa 2017" )
				notd:SizeToContents() -- "General Settings"

			local LootboxSettings = vgui.Create( "DPanelList", frame )
				LootboxSettings:EnableHorizontal( false )			
				LootboxSettings:EnableVerticalScrollbar( true )		
				DCollapsible2:SetContents( LootboxSettings )

				





	end




	local function npcDropsEdit(npc_id,ent,rate,ship,key,code,label,labelrem)

		local frame = vgui.Create( "DFrame" )
		frame:SetSize(500, 400)
		frame:Center()
		frame:SetTitle("Editing: "..npc_id.."["..key.."]")

		frame:MakePopup()
		frame:ShowCloseButton( false )
		function frame:Paint(w, h)
			draw.RoundedBox(0, 0, 0, 500, 22, rgb(44, 62, 80))
			draw.RoundedBox(0, 0, 22, 500, 576, Color(46, 46, 46, 255))
			--draw.RoundedBox(number cornerRadius,number x,number y,number width,number height,table color)
			draw.RoundedBox(0, 10, 67, 8, 270, Color(128, 128, 128, 255))

		end

		local btn_close = vgui.Create( "DButton", frame ) 
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( frame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()
				
		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		

			local sheet = vgui.Create("DPropertySheet", frame)
			function sheet.Paint()
			end
			function sheet:Think()
				for k, v in pairs(sheet.Items) do
					if !v.Tab then continue end
					v.Tab:SetTextColor(Color(255, 255, 255, 255))
					if sheet:GetActiveTab() == v.Tab then
						function v.Tab:Paint(w, h)
							draw.RoundedBox(0, 0, 0, w-4.6, h, Color(128, 128, 128, 255))
						end
					else
						function v.Tab:Paint(w, h)
							draw.RoundedBox(0, 0, 0, w-4.6, h, Color(46, 46, 46, 255))

						end
					end
				end
			end

			sheet:DockMargin(5, 10, 0, 30)
			sheet:Dock(FILL)




		local panel1 = vgui.Create( "DPanel", sheet )
		--panel1.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255, self:GetAlpha() ) ) end
		function panel1:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(128, 128, 128, 255))
		end 
		local DScrollPanel = vgui.Create( "DScrollPanel", panel1 )
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

		local npcidraw = npc_id
		local codeisok = code
		local labelisok = label or false

		local entityidraw
		local TextEntry = vgui.Create( "DTextEntry", DScrollPanel ) 
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
		local boolCheckbox = vgui.Create( "DCheckBox", panel1 ) 
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
		
		local shipmentEnabledLabel = vgui.Create("DLabel", panel1)
		shipmentEnabledLabel:SetPos(50, 100)
		shipmentEnabledLabel:SetTextColor(Color(255, 255, 255, 255))
		shipmentEnabledLabel:SetText("Is shipment? (only DarkRP) (and it has to be a shipment just like f4)")
		shipmentEnabledLabel:SizeToContents()

		local luaremEnabledLabel = vgui.Create("DLabel", panel1)
		luaremEnabledLabel:SetPos(50, 120)
		luaremEnabledLabel:SetTextColor(Color(255, 255, 255, 255))
		luaremEnabledLabel:SetText("Remove label for this item? (You can remove for all drops though)")
		luaremEnabledLabel:SizeToContents()

		local remlabel = labelrem
		local boolLabel = vgui.Create( "DCheckBox", panel1 ) 
			boolLabel:SetPos( 20, 120 )
			boolLabel:SetValue(ship)
			boolLabel:SetTooltip("Remove label for this item")
			function boolLabel:OnChange( bVal )
				if ( bVal ) then
					remlabel = true
				else
					remlabel = false
				end
			end

			local NumberWangValue = rate
			local DermaNumSlider = vgui.Create( "DNumSlider", panel1 )
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

		sheet:AddSheet( "General", panel1, "icon16/wrench.png" )

		local panel2 = vgui.Create( "DPanel", sheet )
		function panel2:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(128, 128, 128, 255))
		end 
		local luaEntry = vgui.Create("DTextEntry", panel2)
		luaEntry:DockMargin(5,70,10,15)
		luaEntry:Dock(FILL)
		luaEntry:SetMultiline(true)
		luaEntry:SetAlpha(255)
		luaEntry:SetText(code or "ENT:Remove() -- lol its a joke :D")
		luaEntry:SetTextColor(color_white)
		luaEntry.Paint = function(panel,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(46, 46, 46, 255))
		panel:DrawTextEntryText( rgb(32, 194, 14), rgb(255, 242, 0), rgb(255, 242, 0) )
		end


		local luaLabel = vgui.Create("DLabel", panel2)
		luaLabel:SetPos(5, 30)
		luaLabel:SetTextColor(Color(255, 255, 255, 255))
		luaLabel:SetText("ENT varible for dropped entity \n PLY variable for killed npc \n NPC variable for npc") --76561198176907257
		luaLabel:SizeToContents()
		
			local luaEnabledLabel = vgui.Create("DLabel", panel2)
			luaEnabledLabel:SetPos(5, 10)
			luaEnabledLabel:SetTextColor(Color(255, 255, 255, 255))
			luaEnabledLabel:SetText("Execute lua? ( you better not if you don't know lua )")
			luaEnabledLabel:SizeToContents()



		local schemaList = vgui.Create( "flatblurScroll", panel2 )
		schemaList:Dock( RIGHT )
		schemaList:Center()
		schemaList:SetWide(120)
		schemaList.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,Color(46, 46, 46, 255))
		end
		local schemaProp = vgui.Create( "DButton", schemaList )
		schemaProp:SetText( "Spawn Prop in Front" )
		--schemaProp:SetTall(20)
		schemaProp:SetWide(160)
		schemaProp:Dock(TOP)
		schemaProp:SetFont("Trebuchet18")
		schemaProp:SetTextColor(Color(255,255,255))
		schemaProp.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end
		schemaProp.DoClick = function()
			luaEntry:SetText([[
-- creating prop
local a = ents.Create("prop_physics")
-- you can change its model copy from q
a:SetModel("models/props_borealis/bluebarrel001.mdl")
-- spawning prop in front of player
a:SetPos( PLY:EyePos() + PLY:GetAimVector() * 30 )
-- setting collision not sure it is ok
a:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
-- spawning
a:Spawn()

				]])
		end


		local schemaNut = vgui.Create( "DButton", schemaList )
		schemaNut:SetText( "Spawn nutscript item" )
		schemaNut:SetWide(160)
		schemaNut:Dock(TOP)
		schemaNut:SetFont("Trebuchet18")
		schemaNut:SetTextColor(Color(255,255,255))
		schemaNut.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end
		schemaNut.DoClick = function()
			luaEntry:SetText([[
 -- change burger whatever you want
nut.item.spawn("burger", NPC:GetPos() + Vector(10, 0, 16))
 -- remove old one
ENT:Remove() 
	]])
		end


		local schemaRemove = vgui.Create( "DButton", schemaList )
		schemaRemove:SetText( "Remove timer" )
		schemaRemove:SetWide(160)
		schemaRemove:Dock(TOP)
		schemaRemove:SetFont("Trebuchet18")
		schemaRemove:SetTextColor(Color(255,255,255))
		schemaRemove.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end
		schemaRemove.DoClick = function()
			luaEntry:SetText([[
 -- make a timer that remove drop in 10 sec
 -- you can change it
timer.Simple(10, function()
 -- remove old one
ENT:Remove() 
end)
	]])
		end
			



		if tobool(code) == false then
		luaLabel:SetDisabled(true)
		luaLabel:SetAlpha(0)
		luaEntry:SetEditable(false)
		luaEntry:SetAlpha(0)
		end	
		local luaEnabledCheckBox = vgui.Create("DCheckBox", panel2)
		luaEnabledCheckBox:SetSize(20, 20)
		luaEnabledCheckBox:SetPos(270, 10)
		luaEnabledCheckBox:SetValue(tobool(code) or false)
		function luaEnabledCheckBox:OnChange(enabled)
			if enabled then
				codeisok = true
				luaLabel:SetDisabled(false)
				luaLabel:SetAlpha(255)
				luaEntry:SetEditable(true)
				luaEntry:SetAlpha(255)
			else 
				codeisok = false
				luaLabel:SetDisabled(true)
				luaLabel:SetAlpha(0)
				luaEntry:SetEditable(false)
				luaEntry:SetAlpha(0)
			end
		end

		local panel3 = vgui.Create( "DPanel", sheet )
		--panel1.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255, self:GetAlpha() ) ) end
		function panel3:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(128, 128, 128, 255))
		end 



		local customEnabledLabel = vgui.Create("DLabel", panel3)
		customEnabledLabel:SetPos(5, 10)
		customEnabledLabel:SetTextColor(Color(255, 255, 255, 255))
		customEnabledLabel:SetText("Custom label?")
		customEnabledLabel:SizeToContents()

		local customLabel = vgui.Create("DLabel", panel3)
		customLabel:SetPos(5, 40)
		customLabel:SetTextColor(Color(255, 255, 255, 255))
		customLabel:SetText("You wanna custom label for your drop? Just enter it.") --76561198176907257
		customLabel:SizeToContents()
		local customEntry = vgui.Create( "DTextEntry", panel3)
		customEntry:SetText(label or "Beef")
		customEntry:Dock( BOTTOM )
		customEntry:DockMargin(0,0,0,100)

		if tobool(label) == false then
			customLabel:SetDisabled(true)
			customLabel:SetAlpha(0)
			customEntry:SetEditable(false)
			customEntry:SetAlpha(0)
		end


		local customEnabledCheckBox = vgui.Create("DCheckBox", panel3)
		customEnabledCheckBox:SetSize(20, 20)
		customEnabledCheckBox:SetPos(250, 10)
		customEnabledCheckBox:SetValue(tobool(label) or false)
		function customEnabledCheckBox:OnChange(enabled)
			if enabled then
				labelisok = true
				customLabel:SetDisabled(false)
				customLabel:SetAlpha(255)
				customEntry:SetEditable(true)
				customEntry:SetAlpha(255)
			else 
				labelisok = false
				customLabel:SetDisabled(true)
				customLabel:SetAlpha(0)
				customEntry:SetEditable(false)
				customEntry:SetAlpha(0)
			end
		end

		sheet:AddSheet( "Execute LUA", panel2, "icon16/application_edit.png" )
		sheet:AddSheet( "Custom Label", panel3, "icon16/world_edit.png" )
		local btn_submit = vgui.Create( "DButton", frame )
		btn_submit:SetText( "Save" )
		btn_submit:SetTall(20)
		btn_submit:Dock( BOTTOM )
		btn_submit:SetWide(100)
		btn_submit:SetPos( 20, 120 )
		btn_submit:SetTooltip( "Click here to save this npcdrop" )
		btn_submit:SetFont("Trebuchet18")
		btn_submit:SetTextColor(Color(255,255,255))
		btn_submit.DoClick = function()
			local anyerror = 0
			if entityidraw then else  anyerror = anyerror + 1 end 
			if not (anyerror == 0) then return end
			print("[npcDrops] Editing: ", npcidraw, " with values: ", entityidraw, NumberWangValue, boolis, codeisok, labelisok)
			codeisok = codeisok and luaEntry:GetValue() or false
			labelisok = labelisok and customEntry:GetValue() or false
			print(labelisok,"labelisok")
			net.Start("npcDrops_edit")
				net.WriteString(npcidraw)
				net.WriteString(entityidraw)
				net.WriteFloat(tonumber(NumberWangValue))
				net.WriteString(tostring(boolis))
				net.WriteString(tostring(key))
				net.WriteString(tostring(codeisok))
				net.WriteString(tostring(labelisok))
				net.WriteString(tostring(remlabel))

			net.SendToServer()
			frame:Close()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()






		end
		btn_submit.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
				end
		end			


	end



	local function npcDropsNew(npc)

		local frame = vgui.Create( "DFrame" )
		frame:SetSize( 200, 200 )
		frame:Center()
		frame:SetTitle("npcDrops ~ Create New Drop")
		frame:MakePopup()
		frame:ShowCloseButton( false )
		frame.Paint = function(s, w, h)
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

		end
		local btn_close = vgui.Create( "DButton", frame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( frame:GetWide() - 22, 0  )
		btn_close.DoClick = function()
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		



		local entityidraw = "sent_ball"
		local TextEntry = vgui.Create( "DTextEntry", frame )
			TextEntry:SetPos( 20, 50 )
			TextEntry:SetSize( 170, 20 )
			TextEntry:SetText( "sent_ball" )
			TextEntry:SetTooltip("Add entity to spawn")
			TextEntry:SetUpdateOnType( true )
			function TextEntry:OnValueChange( val )
				
				entityidraw = val


			end

		local boolis = false
		local boolCheckbox = vgui.Create( "DCheckBox", frame )
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

		richtext:InsertColorChange( 255,255,255,255 )
		richtext:SetVerticalScrollbarEnabled( false )



		local btn_submit = vgui.Create( "DButton", frame )
		btn_submit:SetText( "Add New" )
		btn_submit:SetTall(20)
		btn_submit:SetWide(100)
		btn_submit:SetPos( 20, 120 )
		btn_submit:SetTooltip( "Click here to add new npcdrop" )
		btn_submit:SetTextColor(Color(255,255,255))
		btn_submit.DoClick = function()
			if entityidraw then richtext:SetText("OK.") else  richtext:SetText(" EntityID is invalid!") anyerror = anyerror + 1 end
			
			
			
			net.Start("npcDrops_delux")
				net.WriteString(npc)
				net.WriteString(entityidraw)

				net.WriteFloat(tonumber(NumberWangValue))
				net.WriteBool(boolis)
			net.SendToServer()
			frame:Close()


		 	net.Start("npcDrops_refresh")

		 	net.SendToServer()




		end
		btn_submit.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
				end
		end







		


	end

	local function npcDropsListDrops(tbl, npc)

	local DFrame = vgui.Create( "DFrame" )
	DFrame:SetSize( 570, 30 )
	DFrame:SizeTo( 570, 600, 1, 0, -1 )
	DFrame:Center() 
	DFrame:MakePopup()
	local text
	text = "npcDrops ~ Editing Drops of "..npc

	DFrame:SetTitle(text)
	DFrame:ShowCloseButton( false )
		local btn_close = vgui.Create( "DButton", DFrame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
				DFrame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

		end

		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end	
	    local btn_new = vgui.Create("DButton", DFrame)
	    btn_new:SetText( "CREATE NEW DROP" )
	    btn_new:SetTall(22)
	    btn_new:SetWide(120)
	    btn_new:SetTextColor(Color(255,255,255))
	    btn_new:SetPos( DFrame:GetWide() - 172, 0 )
	    btn_new.DoClick = function()
	    	npcDropsNew(npc)
	    	DFrame:Close()
	    end
	    btn_new.Paint = function(s, w, h)
	        if s:IsHovered() then 
	            draw.RoundedBox(0,0,0,w,h,rgb(46, 204, 113))
	        else
	            draw.RoundedBox(0,0,0,w,h,rgb(39, 174, 96))
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
					net.WriteString( npc )


				net.SendToServer()



				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()





	end
	local function tCallback(npc,id)

			RunConsoleCommand( "npcdrops_removedrop", npc,id )

			DFrame:Remove()


				net.Start("npcdrops_refresh")

				net.SendToServer()


	end
	local function Dmenux(id,npc_id,ent,chance,ship,code,label)


				local Menu = vgui.Create( "DMenu" )		-- Is the same as vgui.Create( "DMenu" )

				local Remove = Menu:AddOption( "Remove" ) -- Simple option, but we're going to add an icon
				Remove:SetIcon( "icon16/cancel.png" )	-- Icons are in materials/icon16 folder

				Remove.OnMousePressed = function( button, key )
					Derma_Query( "Are you sure to delete this drop?", "scol Remove", "Yes", function() tCallback(npc_id,id) end, "No", function() return end)
					Menu:Remove()
				end

				local Edit = Menu:AddOption( "Edit" ) -- Simple option, but we're going to add an icon
				Edit:SetIcon( "icon16/pencil.png" )	-- Icons are in materials/icon16 folder

				Edit.OnMousePressed = function( button, key )
					DFrame:Close()
					LocalPlayer():PrintMessage( HUD_PRINTTALK, "Loading..." )				
					Menu:Remove()
					npcDropsEdit(npc_id,ent,chance,ship,id,code,label)
				end

				Menu:SetPos(input.GetCursorPos())

				Menu:Open()

	end
local isEmpty = 0
	for k,v in pairs(tbl) do

		if (v.npc_id == npc) then

			local loops = v.data

			for id, drops in pairs(util.JSONToTable(v.data)) do
				local DLabel = DScrollPanel:Add( "DButton" )
				DLabel:SetText( drops.ent .." - Chance: ".. drops.rate .." - isShipment: ".. tostring(drops.shipment) )
				DLabel:SetTall(50)
				DLabel:SetFont("Trebuchet24")
				DLabel:SetToolTip(" ")
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
					Dmenux(id,v.npc_id,drops.ent,drops.rate,drops.shipment,drops.code,drops.label)
					--[[
					if code and code == 1 then
						Derma_Query( "Are you sure to delete "..v.npc_id.." ?", "npcDrops Delete", "Yes", function() dermaCallback(v.npc_id) end, "No", function() end)

						return
					end
					npcDropsEdit(v.npc_id,v.ent,v.chance,v.ship)--]]

				end
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
		local btn_close = vgui.Create( "DButton", DFrame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
				DFrame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

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
					net.WriteString( npc )


				net.SendToServer()



				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()





	end

local isEmpty = 0
	for k,v in pairs(tbl) do
		if not (v.npc_id == "npc_combine_camera") then

			local DLabel = DScrollPanel:Add( "DButton" )
			DLabel:SetText( v.npc_id )
			DLabel:SetTall(50)
			DLabel:SetFont("Trebuchet24")
			DLabel:SetToolTip(" ")
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
				npcDropsListDrops(tbl, v.npc_id)

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
		btn_close.DoClick = function()
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		

		local npcidraw
		local npcID = vgui.Create( "DTextEntry", frame )
			npcID:SetPos( 20, 30 )
			npcID:SetSize( 170, 20 )
			npcID:SetText( "npc_" )

			npcID:SetTooltip("Add npc to death loot")
			npcID:SetUpdateOnType( true )
			function npcID:OnValueChange( val )
				
				npcidraw = val


			end

		local entityidraw = "sent_ball"
		local TextEntry = vgui.Create( "DTextEntry", frame )
			TextEntry:SetPos( 20, 50 )
			TextEntry:SetSize( 170, 20 )
			TextEntry:SetText( "sent_ball" )
			TextEntry:SetTooltip("Add entity to spawn")
			TextEntry:SetUpdateOnType( true )
			function TextEntry:OnValueChange( val )
				
				entityidraw = val


			end

		local boolis = false
		local boolCheckbox = vgui.Create( "DCheckBox", frame )
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

		richtext:InsertColorChange( 255,255,255,255 )
		richtext:SetVerticalScrollbarEnabled( false )



		local btn_submit = vgui.Create( "DButton", frame )
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


		 	net.Start("npcDrops_refresh")

		 	net.SendToServer()




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
		DFrame:SizeTo( 570, 350, 0.5, 0, -1 ) -- little faster gui opening

		DFrame:Center() 
		DFrame:MakePopup()
		DFrame:SetTitle("npcDrops ~ Main Menu")
		DFrame:ShowCloseButton( false )
		local btn_close = vgui.Create( "DButton", DFrame )
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
				DFrame:Remove()
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

		local DScrollPanel = vgui.Create( "flatblurScroll", DFrame )
		DScrollPanel:SetSize( 565, 300 )
		DScrollPanel:SetPos( 5, 500 )
		DScrollPanel:Dock( FILL )
		DScrollPanel:Center()

--[[-------------------------------------------------------------------------
New Button > main gui
---------------------------------------------------------------------------]]
			local newBtn = DScrollPanel:Add( "npcDropsButton" )
			newBtn.isEnabled = function() return isEnabled end
			newBtn:SetText( "New NPCDrop" )
			newBtn:SetTall(50)
			newBtn:SetTooltip( "Create new NPCDrop" )
			newBtn:SetTextColor(Color(255,255,255))
			newBtn:Dock( TOP )
			newBtn:SetEnabled(isEnabled)		
			newBtn:DockMargin( 0, 0, 0, 5 )
			newBtn.DoClick = function()
				npcDrops(tbl)
				DFrame:Remove()
			end
--[[-------------------------------------------------------------------------
Edit Button > main gui
---------------------------------------------------------------------------]]
			local editBtn = DScrollPanel:Add( "npcDropsButton" )
			editBtn.isEnabled = function() return isEnabled end
			editBtn:SetText( "Edit existed NPCDrop" )
			editBtn:SetTall(50)
			editBtn:SetTooltip( "Edit any created NPCDrops" )
			editBtn:SetTextColor(Color(255,255,255))
			editBtn:Dock( TOP )
			editBtn:SetEnabled(isEnabled)
			editBtn:DockMargin( 0, 0, 0, 5 )		
			editBtn:DockMargin( 0, 0, 0, 5 )
			editBtn.DoClick = function()
				npcDropsList(tbl)
				DFrame:Remove()
			end
--[[-------------------------------------------------------------------------
Delete Button > main gui
---------------------------------------------------------------------------]]
			local deleteBtn = DScrollPanel:Add( "npcDropsButton" )
			deleteBtn.isEnabled = function() return isEnabled end
			deleteBtn:SetText( "Delete NPCDrops" )
			deleteBtn:SetTall(50)
			deleteBtn:SetTooltip( "Delete a NPCDrop" )
			deleteBtn:SetTextColor(Color(255,255,255))
			deleteBtn:Dock( TOP )
			deleteBtn:SetEnabled(isEnabled )
			deleteBtn:DockMargin( 0, 0, 0, 5 )
			deleteBtn.DoClick = function()			
				npcDropsList(tbl,1)
				DFrame:Remove()
			end

--[[-------------------------------------------------------------------------
Changelog Button > main gui
---------------------------------------------------------------------------]]
			local logBtn = DScrollPanel:Add( "npcDropsButton" )
			logBtn:SetText( "NPCDrops Changelog" )
			logBtn.isEnabled = function() return isEnabled end
			logBtn:SetTall(50)
			logBtn:SetTooltip( "View changelog" )
			logBtn:SetTextColor(Color(255,255,255))
			logBtn:Dock( TOP )
			logBtn:DockMargin( 0, 0, 0, 5 )
			logBtn.DoClick = function()

				npcDropsChangelog()
				DFrame:Remove()
			end
--[[-------------------------------------------------------------------------
Settings Button > main gui
---------------------------------------------------------------------------]]
			local cfgButton = DScrollPanel:Add( "npcDropsButton" )
			cfgButton:SetText( "NPCDrops Settings" )
			cfgButton.isEnabled = function() return isEnabled end
			cfgButton:SetTall(50)
			cfgButton:SetTooltip( "View changelog" )
			cfgButton:SetTextColor(Color(255,255,255))
			cfgButton:Dock( TOP )
			cfgButton:DockMargin( 0, 0, 0, 5 )
			cfgButton.DoClick = function()

				npcDropsSettings(tbl)
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



=======
-- npcDrops base file - npcDrops by cmetopapa
AddCSLuaFile()
local version = "1.5" 

npcDrops = npcDrops or {} -- in-lua data 



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
util.AddNetworkString("npcDrops_refresh")
util.AddNetworkString("npcDrops_delux")
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
				query = "CREATE TABLE npcdrops_data ( npc_id varchar(255), data varchar(51200) )"
				result = sql.Query(query)
				if (sql.TableExists("npcdrops_data")) then
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Database npcdrops_data succesfully created.\n"  )
					local testTable = {}
					testTable[1] = {
						rate = 0.3,
						ent = "sent_ball",
						shipment = false
					}
					testTable[2] = {
						rate = 0.5,
						ent = "sent_balle",
						shipment = false
					}

					sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `data`)VALUES ('npc_combine_camera', '".. util.TableToJSON( testTable ) .."')" )
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
	
	function npcDrops.notify(msg) -- or notif maybe

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
			npcDrops.notify("\nAn error occured about shipments! \nSomething wrong with shipment entity!\n"..ent.." is not a valid shipment.\n")

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

	local function newNPCDrops(npc,en,rat,shi) -- creating new npcDrops
			local testTable = {}
			testTable[1] = {
				rate = rat,
				ent = en,
				shipment = shi
			}
			sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `data`)VALUES ('"..npc.."', '".. util.TableToJSON( testTable ) .."')" )
			local result = sql.Query( "SELECT data FROM npcdrops_data WHERE npc_id = '"..npc.."'" )
			if (result) then
		
				npcDrops.notify("\nSuccessfully created npcdrops with id "..npc)

			else
				npcDrops.notify("\nError when creating: "..npc)
			end
	end

	local function saveNPCDrops( npc,enti,ratev,shipe,key ) -- saving npcDrops


		local evo = tostring(shipe)
		local tab = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..npc.."'")
		for k,v in pairs(tab) do if v.npc_id == npc then tab = util.JSONToTable(v.data) end end

		--tab[k]
		tab[key] = {ent=enti,rate=ratev,shipment=shipe}

		local query = "UPDATE npcdrops_data SET data = '"..util.TableToJSON(tab).."' WHERE npc_id = '"..npc.."'"
		sql.Query(query)

		npcDrops.notify("\nSuccessfully edited npc with id "..npc)--]]

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

				query = "CREATE TABLE npcdrops_data ( npc_id varchar(255), data varchar(51200) )"
				res = sql.Query( "SELECT * FROM npcdrops_data" )
				result = sql.Query(query)
				if (sql.TableExists("npcdrops_data")) then
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Database npcdrops_data succesfully created.\n"  )
					local testTable = {}
					testTable[1] = {
						rate = 0.3,
						ent = "sent_ball",
						shipment = false
					}
					testTable[2] = {
						rate = 0.5,
						ent = "sent_balle",
						shipment = false
					}					sql.Query( "INSERT INTO npcdrops_data (`npc_id`, `data`)VALUES ('npc_combine_camera', '".. util.TableToJSON( testTable ) .."')" )
					npcDrops.notify("Successfully created new database!\n")
					GetConVar("npcdrops_disabled"):SetBool(false)
				else
					MsgC( rgb(230, 126, 34), " [npcDrops]: ", rgb(231, 76, 60), " Error occured when creating database.\n"  )
					Msg( sql.LastError( result ) .. "\n" )
				end
			return
		end
		if not npc then return end
			query = "DELETE FROM npcdrops_data WHERE npc_id = '"..npc.."'"
			result = sql.Query(query)

			if result == false then
				npcDrops.notify("Problem with deleting a npcdrop! Check error on console.\n")
				npcDrops.notify(sql.LastError())
			else
				npcDrops.notify("Successfully deleted!\n")
			end
		


	end

	net.Receive("npcDrops_new", function(len,pl)

		local npcid = net.ReadString()
		local entid = net.ReadString()
		local rate  = net.ReadFloat()
		local ship  = net.ReadBool()

		newNPCDrops(npcid,entid,rate,ship)

	end)

	net.Receive("npcDrops_delux", function(len,pl)


		local npcid = net.ReadString()
		local entid = net.ReadString()
		local rateid  = net.ReadFloat()
		local ship  = net.ReadBool()

		local tab = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..npcid.."'")
		local drops = util.JSONToTable(tab[1].data)

		drops[#drops + 1] = {ent=entid,rate=rateid,shipment=ship}
		local query = "UPDATE npcdrops_data SET data = '"..util.TableToJSON(drops).."' WHERE npc_id = '"..npcid.."'"
		sql.Query(query)

		npcDrops.notify("Successfully added new drop to "..npcid)	

	end) -- update 1.5 delux!

	net.Receive("npcDrops_edit", function(len,pl)

		local npcide = net.ReadString()
		local entide = net.ReadString()
		local rated  = net.ReadFloat()
		local shipx  = net.ReadString()
		local key    = net.ReadString()


		saveNPCDrops(npcide,entide,rated,tobool(shipx),key)

	end)

	net.Receive("npcDrops_delete", function(len,pl)


		local npcid = net.ReadString()
		



		deleteNPCDrops(0, npcid)



	end)

	net.Receive("npcDrops_reset", function(len,pl)


		deleteNPCDrops(1)


	end)

	net.Receive("npcDrops_refresh", function(len,pl)
			if not IsValid(pl) then return end

			local table = sql.Query( "SELECT * FROM npcdrops_data")
			if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") return end

			net.Start("npcDrops_menu")
				net.WriteTable(table)
			net.Send(pl)
	end)

	concommand.Add("+npcDrops", function(ply,cmd,arg)

			if not IsValid(ply) then return end
			if ply:IsAdmin() then else return end

			local table = sql.Query( "SELECT * FROM npcdrops_data")
			--if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") return end
			if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") GetConVar("npcdrops_disabled"):SetBool(1) end



			ply:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Menu is loading...]]}chat.AddText(unpack(tab))")

			net.Start("npcDrops_menu")
				if IsValid(table) || istable(table) then net.WriteTable(table) end
			net.Send(ply)


	end)

	hook.Add( "PlayerSay", "npcDrops_chat", function( ply, msg, group )
		local comchattable = string.Explode( " ", msg )
		if ( comchattable[1] == "!npcdrops" ) then
			if ply:IsAdmin() then
			local table = sql.Query( "SELECT * FROM npcdrops_data")
			--if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") return end
			if not (IsValid(table) || istable(table)) then npcDrops.notify("Error occured with database. Please reset npcDrops.") GetConVar("npcdrops_disabled"):SetBool(1) end



			ply:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Menu is loading...]]}chat.AddText(unpack(tab))")

			net.Start("npcDrops_menu")
				if IsValid(table) || istable(table) then net.WriteTable(table) end
			net.Send(ply)

			else
				ply:ChatPrint( "No Access" )
			end
			return false
		end
	end )	

	concommand.Add("npcDrops_removedrop", function(ply,cmd,arg)

		--[[ arg 1 -> npc_id arg 2 -> key

		]]
		if not IsValid(ply) then return end
		if ply:IsAdmin() then else return end

		local tab = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..arg[1].."'")
		local drops = util.JSONToTable(tab[1].data)
		--print("---------------LOK AT Menu	")
		--PrintTable(drops[1])
		local num = tonumber(math.floor(arg[2]))
		--print("num=",num)
		--PrintTable(drops[arg[2]])
		drops[num] = nil

		local query = "UPDATE npcdrops_data SET data = '"..util.TableToJSON(drops).."' WHERE npc_id = '"..arg[1].."'"
		sql.Query(query)

		npcDrops.notify("Successfully removed the drop from "..arg[1])						

	end)

	function npcDrops.getvName(class)
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

		local dropsTable = sql.Query( "SELECT * FROM npcdrops_data WHERE npc_id = '"..npc:GetClass().."'")

		if not (IsValid(dropsTable) || istable(dropsTable)) then  return end


		if GetConVar("npcdrops_disabled"):GetBool() then return end
		local shouldNotify = GetConVar("npcdrops_notify"):GetBool()
		local chance
		

		local med	
		for k,v in pairs(dropsTable) do if v.npc_id == npc:GetClass() then med = util.JSONToTable(v.data) else return end end

		local passes = {}
		for k,v in pairs(med) do
			local rate = math.Rand( 0, 1 )
			local hector
			--if #med == 1 then hector = med else hector = med[k] end
			if rate <= tonumber(v.rate) or v.rate == 1 then print("got you") passes[v.ent] = {ent=v.ent,rate=v.rate,shipment=v.shipment} end

			
		end

		local lootbox
		for k,v in pairs(passes) do

				if GetConVar("npcdrops_lootsound"):GetBool() then killer:EmitSound("npcdrops_lootsound") end
				if tobool(v.ship) then
					npcDropsShipment(killer, v.ent, npc:GetPos())
					print("[npcDrops] NPC_id: "..v.npc_id.." dropped shipment. Chance Rate: "..v.chance.." was rate:")
					if shouldNotify and (math.floor(v.chance) != 1) then killer:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Congratulations! You have dropped '"..npcDrops.getvName(v.ent).."' with rate "..v.chance.."!]]}chat.AddText(unpack(tab))") end
				else



						

					local check


						


						local item = ents.Create(v.ent)
						item:SetNWBool("isnpcDrop",true)
						item:SetNWInt("npcDropdly", CurTime() + GetConVar("npcdrops_itemremovedly"):GetInt())
						item:SetNWString("npcDropname", npcDrops.getvName(v.ent))
						item:SetNWInt("npcDroprate", tonumber(v.rate))
						--[[
						print("test=",table.Count(passes) == 1,table.Count(passes))
						if not (table.Count(passes) == 1) then
						local lootbox = ents.Create("npcDrops_loot")
						lootbox:SetPos(npc:GetPos())
						lootbox.itemTable = {
								ent = v.ent,
								rate = v.rate,
							}
						print("lootbox.itemtable=",lootbox.itemTable)
						PrintTable(lootbox.itemTable)

						end--]]

						
						if not IsValid(item) then check = 1 end

						if check == 1 then
							npcDrops.notify("\nAn error occured about entity! \nSomething wrong with entity!\n"..v.ent.." is not a valid entity!\n")

							MsgC( Color( 255, 0, 0 ), "[ERROR]", rgb(230, 126, 34), " <npcDrops>: ", rgb(231, 76, 60), " An error occured: \nSomething wrong with entity!\n"..v.ent.." is not a entity!\n"  )
							return
						end	
						item:SetPos( npc:GetPos() + Vector(0,0,50) )






						item:Spawn()



						print("[npcDrops] NPC_id: "..npc:GetClass().." dropped item. Chance Rate: "..v.rate)
						if shouldNotify and (tonumber(v.rate) <= 0.8) then killer:SendLua("local tab={Color(26, 188, 156),[[<npcDrops>: ]],Color(236, 240, 241),[[Congratulations! You have dropped '"..npcDrops.getvName(v.ent).."' with rate "..Anakinn(v.rate).."!]]}chat.AddText(unpack(tab))") end
						if GetConVar("npcdrops_itemremove"):GetBool() then
							timer.Simple(GetConVar("npcdrops_itemremovedly"):GetInt(), function()
								if not IsValid(item) then return end

								item:Remove()


							end)
						end




				


			end
		end
			--if IsValid(lootbox) then lootbox:Spawn() end

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

			 		if GetConVar("npcdrops_labels"):GetBool() then
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
						end
					end	
					if GetConVar("npcdrops_itemremove"):GetBool() and GetConVar("npcdrops_itemremovelabel"):GetBool() then
						cam.Start3D2D( v:GetPos() + Vector( 0, 0, 15 ), Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ), 0.02 )
							surface.SetDrawColor( Color( 235, 189, 99, 50 ) )
							surface.DrawRect( -400, 0 + math.sin( CurTime() ) * 50, 800, 100 )
							draw.SimpleText( "Removing after: "..math.floor((v:GetNWInt("npcDropdly") - CurTime())), "npcDrops_itemFont", 0, 50 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						cam.End3D2D()
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
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()


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


	local function npcDropsSettings()

		local frame = vgui.Create( "flatblur" )
		frame:SetSize( 400, 400 )
		frame:Center()
		frame:SetTitle("npcDrops ~ Settings")
		frame.OnClose = function()
		 	net.Start("npcDrops_refresh")

		 	net.SendToServer()		
		end
		frame:MakePopup()
		local DScrollPanel = vgui.Create( "flatblurScroll", frame )

		DScrollPanel:Dock( FILL )
		DScrollPanel:Center()
		DScrollPanel:SetSBColor( rgb(192, 57, 43))
			local DCollapsible = vgui.Create( "DCollapsibleCategory", DScrollPanel )	// Create a collapsible category
			DCollapsible:Dock(TOP)									 // Set position
			DCollapsible:SetSize( 400, 100 )										 // Set size
			DCollapsible:SetExpanded( 0 )											 // Is it expanded when you open the panel?
			DCollapsible:SetLabel( "General Settings" )							// Set the name ( label )
			DCollapsible.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			end

			local DCollapsible2 = vgui.Create( "DCollapsibleCategory", DScrollPanel )
			DCollapsible2:Dock(TOP)					
			DCollapsible2:SetSize( 400, 100 )					
			DCollapsible2:SetExpanded( 0 )											
			DCollapsible2:SetLabel( "Lootbox Settings" )						
			DCollapsible2.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			end

			local GeneralSettings = vgui.Create( "DPanelList", frame )	
				GeneralSettings:EnableHorizontal( false )			
				GeneralSettings:EnableVerticalScrollbar( true )		
				DCollapsible:SetContents( GeneralSettings )
				local Don = vgui.Create( "DCheckBoxLabel", GeneralSettings )
					Don:SetPos( 10, 0 )
					Don:SetText( "Disable npcDrops?" )
					Don:SetConVar( "npcdrops_disabled" )
					Don:SetValue( GetConVarNumber( "npcdrops_disabled" ) )


				local arrl = vgui.Create( "DCheckBoxLabel", GeneralSettings )
					arrl:SetPos( 10, 30 )
					arrl:SetText( "Remove Item after a while?" )
					arrl:SetConVar( "npcdrops_itemremove" )
					arrl:SetValue( GetConVarNumber( "npcdrops_itemremove" ) )
		
					
				local arr = vgui.Create( "DNumSlider", GeneralSettings )
					arr:SetPos( 10, 40 )
					arr:SetValue( GetConVarNumber( "npcdrops_itemremovedly" ) )
					arr:SetConVar( "npcdrops_itemremovedly" )
					arr:SetSize( 400, 90 )
					arr:SetText( "Remove item after x seconds" )
					arr:SetDecimals(2)
					arr:SetEnabled(not GetConVarNumber( "npcdrops_itemremove" ))
					arr:SetMinMax( 1 , 600 )

				local lab = vgui.Create( "DCheckBoxLabel", GeneralSettings )
					lab:SetPos( 10, 100 )
					lab:SetText( "Enable 'removing after' label?" )
					lab:SetValue( GetConVarNumber( "npcdrops_itemremovelabel" ) )
					lab:SetConVar("npcdrops_itemremovelabel")

					

				local notex = vgui.Create( "DCheckBoxLabel", GeneralSettings )
					notex:SetPos( 10, 120 )
					notex:SetText( "Notify player if have dropped something? \n(NOTE: If chance to drop is 100% it doesn't notify)" )
					notex:SetConVar( "npcdrops_notify" )
					notex:SetValue( GetConVarNumber( "npcdrops_notify" ) )


				local shouldsound = vgui.Create( "DCheckBoxLabel", GeneralSettings )
					shouldsound:SetPos( 10, 180 )
					shouldsound:SetText( "Play sound when drops?" )
					shouldsound:SetConVar( "npcdrops_lootsound" )
					shouldsound:SetValue( GetConVarNumber( "npcdrops_lootsound" ) )

				local badges = vgui.Create( "DCheckBoxLabel", GeneralSettings )
					badges:SetPos( 10, 210 )
					badges:SetText( "Enable drop labels-rarity bar?" )
					badges:SetConVar( "npcdrops_labels" )
					badges:SetValue( GetConVarNumber( "npcdrops_labels" ) )

local function factCallback()
					net.Start("npcDrops_reset")
					net.SendToServer()
end
				local factReset = vgui.Create("DButton", GeneralSettings)
					factReset:SetText( "Reset npcDrops" )
					factReset:SetTall(20)
					factReset:SetWide(100)
					factReset:SetPos( 10, 230 )
					factReset:SetTooltip( "Re-create npcDrops database. Will delete everything!" )
					factReset:SetFont("Trebuchet18")
					factReset:SetTextColor(Color(255,255,255))


					factReset.DoClick = function()

						Derma_Query( "Are you sure to reset addon? This can not be undone and all of created npcDrops will be removed.", "npcDrops Reset", "Yes", function() factCallback() end, "No", function() return end)



					end

					factReset.Paint = function(s, w, h)
						if s:IsHovered() then 
							draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
						else
							draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
						end
					end


				local notd = vgui.Create( "DLabel",  frame  )
				notd:Dock(BOTTOM)
				notd:SetText( "Copyright © npcDrops cometopapa 2017 ~ All rights Reserved." )
				notd:SizeToContents() -- "General Settings"

			local LootboxSettings = vgui.Create( "DPanelList", frame )
				LootboxSettings:EnableHorizontal( false )			
				LootboxSettings:EnableVerticalScrollbar( true )		
				DCollapsible2:SetContents( LootboxSettings )

				





	end




	local function npcDropsEdit(npc_id,ent,rate,ship,key)

		local frame = vgui.Create( "DFrame" )
		frame:SetSize( 200, 200 )
		frame:Center()
		frame:SetTitle("Editing: "..npc_id.."["..key.."]")

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
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()
				
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
			if entityidraw then richtext:AppendText("EntityID is OK.") else  richtext:AppendText("EntityID is invalid!") anyerror = anyerror + 1 end 
			if not (anyerror == 0) then return end
			print("[npcDrops] Editing: ", npcidraw, " with values: ", entityidraw, NumberWangValue, boolis)
			net.Start("npcDrops_edit")
				net.WriteString(npcidraw)
				net.WriteString(entityidraw)
				net.WriteFloat(tonumber(NumberWangValue))
				net.WriteString(tostring(boolis))
				net.WriteString(tostring(key))

			net.SendToServer()
			frame:Close()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()






		end
		btn_submit.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
				end
		end			


	end

	local function npcDropsNew(npc)

		local frame = vgui.Create( "DFrame" )
		frame:SetSize( 200, 200 )
		frame:Center()
		frame:SetTitle("npcDrops ~ Create New Drop")
		frame:MakePopup()
		frame:ShowCloseButton( false )
		frame.Paint = function(s, w, h)
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

		end
		local btn_close = vgui.Create( "DButton", frame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( frame:GetWide() - 22, 0  )
		btn_close.DoClick = function()
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		



		local entityidraw = "sent_ball"
		local TextEntry = vgui.Create( "DTextEntry", frame )
			TextEntry:SetPos( 20, 50 )
			TextEntry:SetSize( 170, 20 )
			TextEntry:SetText( "sent_ball" )
			TextEntry:SetTooltip("Add entity to spawn")
			TextEntry:SetUpdateOnType( true )
			function TextEntry:OnValueChange( val )
				
				entityidraw = val


			end

		local boolis = false
		local boolCheckbox = vgui.Create( "DCheckBox", frame )
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

		richtext:InsertColorChange( 255,255,255,255 )
		richtext:SetVerticalScrollbarEnabled( false )



		local btn_submit = vgui.Create( "DButton", frame )
		btn_submit:SetText( "Add New" )
		btn_submit:SetTall(20)
		btn_submit:SetWide(100)
		btn_submit:SetPos( 20, 120 )
		btn_submit:SetTooltip( "Click here to add new npcdrop" )
		btn_submit:SetTextColor(Color(255,255,255))
		btn_submit.DoClick = function()
			if entityidraw then richtext:SetText("OK.") else  richtext:SetText(" EntityID is invalid!") anyerror = anyerror + 1 end
			
			
			
			net.Start("npcDrops_delux")
				net.WriteString(npc)
				net.WriteString(entityidraw)

				net.WriteFloat(tonumber(NumberWangValue))
				net.WriteBool(boolis)
			net.SendToServer()
			frame:Close()


		 	net.Start("npcDrops_refresh")

		 	net.SendToServer()




		end
		btn_submit.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
				else
					draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
				end
		end







		


	end

	local function npcDropsListDrops(tbl, npc)

	local DFrame = vgui.Create( "DFrame" )
	DFrame:SetSize( 570, 30 )
	DFrame:SizeTo( 570, 600, 1, 0, -1 )
	DFrame:Center() 
	DFrame:MakePopup()
	local text
	text = "npcDrops ~ Editing Drops of "..npc

	DFrame:SetTitle(text)
	DFrame:ShowCloseButton( false )
		local btn_close = vgui.Create( "DButton", DFrame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
				DFrame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

		end

		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end	
	    local btn_new = vgui.Create("DButton", DFrame)
	    btn_new:SetText( "CREATE NEW DROP" )
	    btn_new:SetTall(22)
	    btn_new:SetWide(120)
	    btn_new:SetTextColor(Color(255,255,255))
	    btn_new:SetPos( DFrame:GetWide() - 172, 0 )
	    btn_new.DoClick = function()
	    	npcDropsNew(npc)
	    	DFrame:Close()
	    end
	    btn_new.Paint = function(s, w, h)
	        if s:IsHovered() then 
	            draw.RoundedBox(0,0,0,w,h,rgb(46, 204, 113))
	        else
	            draw.RoundedBox(0,0,0,w,h,rgb(39, 174, 96))
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
					net.WriteString( npc )


				net.SendToServer()



				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()





	end
	local function tCallback(npc,id)

			RunConsoleCommand( "npcdrops_removedrop", npc,id )

			DFrame:Remove()


				net.Start("npcdrops_refresh")

				net.SendToServer()


	end
	local function Dmenux(id,npc_id,ent,chance,ship)


				local Menu = vgui.Create( "DMenu" )		-- Is the same as vgui.Create( "DMenu" )

				local Remove = Menu:AddOption( "Remove" ) -- Simple option, but we're going to add an icon
				Remove:SetIcon( "icon16/cancel.png" )	-- Icons are in materials/icon16 folder

				Remove.OnMousePressed = function( button, key )
					Derma_Query( "Are you sure to delete this drop?", "scol Remove", "Yes", function() tCallback(npc_id,id) end, "No", function() return end)
					Menu:Remove()
				end

				local Edit = Menu:AddOption( "Edit" ) -- Simple option, but we're going to add an icon
				Edit:SetIcon( "icon16/pencil.png" )	-- Icons are in materials/icon16 folder

				Edit.OnMousePressed = function( button, key )
					DFrame:Close()
					LocalPlayer():PrintMessage( HUD_PRINTTALK, "Loading..." )				
					Menu:Remove()
					npcDropsEdit(npc_id,ent,chance,ship,id)
				end

				Menu:SetPos(input.GetCursorPos())

				Menu:Open()

	end
local isEmpty = 0
	for k,v in pairs(tbl) do

		if (v.npc_id == npc) then

			local loops = v.data

			for id, drops in pairs(util.JSONToTable(v.data)) do
				local DLabel = DScrollPanel:Add( "DButton" )
				DLabel:SetText( drops.ent .." - Chance: ".. drops.rate .." - isShipment: ".. tostring(drops.shipment) )
				DLabel:SetTall(50)
				DLabel:SetFont("Trebuchet24")
				DLabel:SetToolTip(" ")
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
					Dmenux(id,v.npc_id,drops.ent,drops.rate,drops.shipment)
					--[[
					if code and code == 1 then
						Derma_Query( "Are you sure to delete "..v.npc_id.." ?", "npcDrops Delete", "Yes", function() dermaCallback(v.npc_id) end, "No", function() end)

						return
					end
					npcDropsEdit(v.npc_id,v.ent,v.chance,v.ship)--]]

				end
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
		local btn_close = vgui.Create( "DButton", DFrame ) -- create the form as a child of frame
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
				DFrame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

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
					net.WriteString( npc )


				net.SendToServer()



				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()





	end

local isEmpty = 0
	for k,v in pairs(tbl) do
		if not (v.npc_id == "npc_combine_camera") then

			local DLabel = DScrollPanel:Add( "DButton" )
			DLabel:SetText( v.npc_id )
			DLabel:SetTall(50)
			DLabel:SetFont("Trebuchet24")
			DLabel:SetToolTip(" ")
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
				npcDropsListDrops(tbl, v.npc_id)

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
		btn_close.DoClick = function()
				frame:Remove()


				 	net.Start("npcDrops_refresh")

				 	net.SendToServer()

		end
		btn_close.Paint = function(s, w, h)
			if s:IsHovered() then 
				draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
			else
				draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
			end
		end		

		local npcidraw
		local npcID = vgui.Create( "DTextEntry", frame )
			npcID:SetPos( 20, 30 )
			npcID:SetSize( 170, 20 )
			npcID:SetText( "npc_" )

			npcID:SetTooltip("Add npc to death loot")
			npcID:SetUpdateOnType( true )
			function npcID:OnValueChange( val )
				
				npcidraw = val


			end

		local entityidraw = "sent_ball"
		local TextEntry = vgui.Create( "DTextEntry", frame )
			TextEntry:SetPos( 20, 50 )
			TextEntry:SetSize( 170, 20 )
			TextEntry:SetText( "sent_ball" )
			TextEntry:SetTooltip("Add entity to spawn")
			TextEntry:SetUpdateOnType( true )
			function TextEntry:OnValueChange( val )
				
				entityidraw = val


			end

		local boolis = false
		local boolCheckbox = vgui.Create( "DCheckBox", frame )
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

		richtext:InsertColorChange( 255,255,255,255 )
		richtext:SetVerticalScrollbarEnabled( false )



		local btn_submit = vgui.Create( "DButton", frame )
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


		 	net.Start("npcDrops_refresh")

		 	net.SendToServer()




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
		DFrame:SizeTo( 570, 350, 0.5, 0, -1 ) -- little faster gui opening

		DFrame:Center() 
		DFrame:MakePopup()
		DFrame:SetTitle("npcDrops ~ Main Menu")
		DFrame:ShowCloseButton( false )
		local btn_close = vgui.Create( "DButton", DFrame )
		btn_close:SetText( "" )
		btn_close:SetTall(22)
		btn_close:SetWide(22)
		btn_close:SetPos( DFrame:GetWide() - 22, 0 )
		btn_close.DoClick = function()
				DFrame:Remove()
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

			local DLabel5 = DScrollPanel:Add( "DButton" )
			DLabel5:SetText( "NPCDrops Settings" )
			DLabel5:SetTall(50)
			DLabel5:SetTooltip( "View changelog" )
			DLabel5:SetFont("Trebuchet24")
			DLabel5:SetTextColor(Color(255,255,255))
			DLabel5:Dock( TOP )
			DLabel5:DockMargin( 0, 0, 0, 5 )
			local oanim5 = 0
			local oanimlength5 = 0	
			DLabel5.Paint = function(s, w, h)

				if s:IsHovered() then 
					oanimlength5 = w 

				else
					oanimlength5 = 3


				end
				oanim5 = math.Approach(oanim5,oanimlength5,FrameTime()*1200)
				draw.RoundedBox( 0, 0, 0, w, h, Color(192, 57, 43, 200))

				draw.RoundedBox( 0, 0, 0, oanim5, h, Color(237,74,59,255))
			end

			DLabel5.DoClick = function()

				npcDropsSettings()
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



>>>>>>> 00e8a99c0cc123847d81028b188d9121aee16eb3
