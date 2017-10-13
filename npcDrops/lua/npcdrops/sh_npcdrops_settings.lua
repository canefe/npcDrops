-- npcDrops Settings file - npcDrops by cometopapa
local rgb = Color
local function factCallback()
					net.Start("npcDrops_reset")
					net.SendToServer()
end
hook.Add( "PopulateToolMenu", "npcDrops Settings", function()
	spawnmenu.AddToolMenuOption( "Utilities", "npcDrops", "npcDropsTab", "Settings", "", "", function( panel )
		panel:ClearControls()
		if LocalPlayer():IsAdmin() then
			local Don = vgui.Create( "DCheckBoxLabel" )
				Don:SetPos( 10, 50 )
				Don:SetText( "Disable npcDrops?" )
				Don:SetTextColor(rgb(44, 62, 80))
				Don:SetConVar( "npcdrops_disabled" )
				Don:SetValue( GetConVarNumber( "npcdrops_disabled" ) )
				panel:AddItem( Don )

			local arrl = vgui.Create( "DCheckBoxLabel" )
				arrl:SetPos( 20, 50 )
				arrl:SetText( "Remove Item after a while?" )
				arrl:SetTextColor(rgb(44, 62, 80))
				arrl:SetConVar( "npcdrops_itemremove" )
				arrl:SetValue( GetConVarNumber( "npcdrops_itemremove" ) )
				panel:AddItem( arrl )	
				
			local arr = vgui.Create( "DNumSlider" )
				arr:SetPos( 30, 50 )
				arr:SetValue( GetConVarNumber( "npcdrops_itemremovedly" ) )
				arr:SetConVar( "npcdrops_itemremovedly" )
				arr:SetSize( 300, 100 )
				--arr:SetTextColor(rgb(44, 62, 80))
				arr:SetText( "Remove item after x seconds (if above true)" )
				arr:SetDecimals(2)
				arr:SetMinMax( 1 , 600 )
				panel:AddItem( arr )
				

			local notex = vgui.Create( "DCheckBoxLabel" )
				notex:SetPos( 40, 50 )
				notex:SetText( "Notify player if have dropped something? (NOTE: If chance to drop 100% doesn't notify)" )
				notex:SetTextColor(rgb(44, 62, 80))
				notex:SetConVar( "npcdrops_notify" )
				notex:SetValue( GetConVarNumber( "npcdrops_notify" ) )
				panel:AddItem( notex )

			local shouldsound = vgui.Create( "DCheckBoxLabel" )
				shouldsound:SetPos( 50, 50 )
				shouldsound:SetText( "Play sound when drops?" )
				shouldsound:SetTextColor(rgb(44, 62, 80))
				shouldsound:SetConVar( "npcdrops_lootsound" )
				shouldsound:SetValue( GetConVarNumber( "npcdrops_lootsound" ) )
				panel:AddItem( shouldsound )

			local factReset = vgui.Create("DButton")
				factReset:SetText( "Reset npcDrops" )
				factReset:SetTall(20)
				factReset:SetWide(100)
				factReset:SetPos( 60, 50 )
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
				panel:AddItem( factReset )

			local notd = vgui.Create( "DLabel" )
			notd:SetPos( 90, 50 )
			notd:SetColor(Color(44, 62, 80))
			notd:SetText( "Copyright © npcDrops 2017 ~ All rights Reserved." )
			notd:SizeToContents()
			panel:AddItem( notd )

		end
	end )
end )