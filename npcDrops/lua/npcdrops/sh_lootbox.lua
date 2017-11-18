if SERVER then util.AddNetworkString("npcDrops_lootbox") util.AddNetworkString("npcDrops_lootbox_loot")





net.Receive("npcDrops_lootbox_loot", function(len,pl)

	local ent = net.ReadString()
	local callback = net.ReadString()
	local enti
	if callback=="yes" then enti = net.ReadEntity() enti:Remove() end

	local item = ents.Create(ent)
	item:SetPos( pl:GetPos() + Vector(0,50,10) )
	item:Spawn()
	--item:SetBallSize(47)
	npcDrops.notify("You loot "..npcDrops.getvName(ent))


end)








end -- server end
if SERVER then return end
if CLIENT then

	surface.CreateFont("npcDrops_lootbox18", {font = "Roboto", size = 18, shadow = true,  extended = true})


local function lootBoxGUI(entz)

local entity = net.ReadEntity()
local tab = net.ReadTable()
if not IsValid(entity) then entity = entz end
local itemTable = tab
local rgb = Color


    local frame = vgui.Create("flatblur")
	frame:SetSize( 400, 250 )
    frame:SetTitle("Lootbag")
    frame:MakePopup()
    frame:Center()
    frame:SetMainColor( rgb(165, 136, 85))
		

		local DScrollPanel = vgui.Create( "flatblurScroll", frame )

		DScrollPanel:Dock( FILL )
		DScrollPanel:Center()
		DScrollPanel:SetSBColor( rgb(165, 136, 85))

		local List  = vgui.Create( "DIconLayout", DScrollPanel )
		List:Dock(TOP)
		List:SetSpaceY( 5 ) 
		List:SetSpaceX( 5 ) 
		List:SetLayoutDir(TOP)

	    for k,v in pairs(itemTable) do
	    	print(v)
			local ListItem = List:Add( "DButton" )
			ListItem:SetText( "" )
			ListItem:SetTall( 100 )
			ListItem:SetWide( 175 )
			ListItem:SetFont("Trebuchet24")
			ListItem:SetTextColor(Color(255,255,255))
			local mat = Material("npcDrops/itemtexture.png")

			ListItem.Paint = function(s, w, h)
				if s:IsHovered() then 
					draw.RoundedBox( 0, 0, 0, w, h, rgb(165, 136, 85))
				  	surface.SetMaterial(mat)
					surface.SetDrawColor(255,255,255 ,255)
					surface.DrawTexturedRect(0,0,w,h)
				else
				  	draw.RoundedBox( 0, 0, 0, w, h, rgb(165, 136, 85, 150))
				  	surface.SetMaterial(mat)
					surface.SetDrawColor(255,255,255 ,255)
					surface.DrawTexturedRect(0,0,w,h)
				end
			end

			local LootName = vgui.Create("DLabel", ListItem)
			LootName:SetText(v.ent)
			LootName:SetFont("npcDrops_lootbox18")
			LootName:SizeToContents()
			LootName:SetPos(ListItem:GetWide()/2.9, 0)

			local Rarity = vgui.Create("DLabel", ListItem)
			Rarity:SetText("Rarity: "..v.rarity)
			Rarity:SetFont("npcDrops_lootbox18")
			Rarity:SizeToContents()
			Rarity:SetPos(10,30)

			local Loot_btn = vgui.Create("DButton", ListItem)
			Loot_btn:SetText( "Loot" )
			Loot_btn:SetTall(20)
			Loot_btn:SetWide(100)
			Loot_btn:SetPos( 20, 70 )
			Loot_btn:SetTooltip( "Loot "..k )
			Loot_btn:SetFont("npcDrops_lootbox18")
			Loot_btn:SetTextColor(Color(255,255,255))
			Loot_btn.Paint = function(s, w, h)
					if s:IsHovered() then 
						draw.RoundedBox(0,0,0,w,h,rgb(231, 76, 60))
					else
						draw.RoundedBox(0,0,0,w,h,rgb(192, 57, 43))
					end
			end
			Loot_btn.DoClick = function()
				itemTable[k] = nil
				net.Start("npcDrops_lootbox_loot")
					net.WriteString(v.ent)
					if table.Count(itemTable) == 0 then
						net.WriteString("yes")
						net.WriteEntity(entity)
					else
						net.WriteString("no")
					end

				net.SendToServer()
				frame:Close()

				if table.Count(itemTable) == 0 then return end
				lootBoxGUI(entity)
				
				--PrintTable(itemTable)

			end

		end -- for end


end

net.Receive("npcDrops_lootbox", lootBoxGUI)

end

