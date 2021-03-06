include("shared.lua")

function ENT:Draw()

	local mainWide = 950
	local mainTall = 950

	local camPos = self:LocalToWorld( Vector( -(mainTall/10)/2 , -(mainWide/10)/2 , -1 ) )
	local camAng = self:LocalToWorldAngles( Angle( 0, 90, 0 ) )

	//self:DrawModel()

	local imageMat = GAMEMODE.Util.Images["joinBoard"]

	cam.Start3D2D( camPos , camAng , 0.1)

		surface.SetDrawColor(color_white)
	    surface.SetMaterial( imageMat )
	    surface.DrawTexturedRect( 0 , 0 , 950 , 950 )
		draw.NoTexture()

	cam.End3D2D()	

end