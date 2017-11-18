include('shared.lua')
local rgb = Color


function ENT:Initialize()

 


end








function ENT:Draw()
    self:DrawModel() -- Draws Model Client Side
 
	if self:GetPos():Distance( LocalPlayer():GetPos() ) < 250 then 
			cam.Start3D2D( self:GetPos() , Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ), 0.1 )
					surface.SetDrawColor( rgb(44, 62, 80, 230) )
					surface.DrawRect( -200, -400 + math.sin( CurTime() ) * 50, 400  , 100 )
					surface.DrawRect( -200, -300 + math.sin( CurTime() ) * 50, 400  , 100 )

					DrawElectricText(1, "LOOTBOX", "npcDrops_itemFont", -185, -400 + math.sin( CurTime() ) * 50, rgb(155, 89, 182), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)								
					draw.SimpleText( "Contains:", "npcDrops_itemFont", 0, -250 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			cam.End3D2D()
	end

end