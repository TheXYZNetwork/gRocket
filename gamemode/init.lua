--[[

	Server Side Initialization

]]

// AddCSLua Files:
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

// Include Lua Files:
include( "shared.lua" )
include( "sv_manifest.lua" )

function GM:Initialize()



end

function GM:PlayerInitialSpawn( ply )

	self.Match:InitialSpawn( ply )

end

function GM:CanPlayerSuicide()
	return false
end

function GM:InitPostEntity()

	self.Map:InitPostEntity()

end

function GM:KeyPress( ply , key )

	self.Car:KeyPress( ply , key )

end

function GM:KeyRelease( ply , key )

	self.Car:KeyRelease( ply , key )

end

function GM:CanExitVehicle( veh , ply )

	if ply:IsInMatch() then

		return false

	end

	return true

end

function GM:PlayerNoClip( ply )
	return true
end

function GM:PlayerLoadout( ply )

	for k, v in pairs(GAMEMODE.Config.PlayerLoadout) do

		ply:Give( v )

	end

	return true

end