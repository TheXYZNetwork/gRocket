--[[

	Server Side Config

]]

// SQL Data

GM.Config.SQL = {}
GM.Config.SQL.Host 	= "185.141.207.138"
GM.Config.SQL.Port 	= 3306
GM.Config.SQL.DB 	= "policerp_seriousrp"
GM.Config.SQL.User 	= "policerp_srpuser"
GM.Config.SQL.Pass 	= "_wbxwVewwAku"

// Player Data

GM.Config.DefaultCoins = 100

GM.Config.PlayerLoadout = {
	"weapon_physgun"
}

GM.Config.ForbiddenEnts = {
	"ent_match_ball",
	"ent_boost_ball",
	"ent_match_board",
	"ent_queue_board"
}

// Game Config
GM.Config.BoostMultiplier = 100

GM.Config.BigBoostAmount = 100

GM.Config.BoostDelay = 10

// Map Config

GM.Config.SpawnPos = Vector( 7841.591797 , 3350.276367 , 1607.031250 )

GM.Config.CarPositions = {
	
	["Team1"] = {

		Vector( 6148.564941 , 2318.067139 , 1088.031250 ),
		Vector( 5445.368652 , 2355.130371 , 1088.031250 ),
		Vector( 6840.470703 , 2355.130371 , 1088.031250 ),

	},

	["Team2"] = {

		Vector( 6148.564941 , 4327.604980 , 1088.031250 ),
		Vector( 5445.368652 , 4418.386230 , 1088.031250 ),
		Vector( 6840.470703 , 4418.386230 , 1088.031250 ),

	}	

}

GM.Config.CarAngles = {
	
	["Team1"] = Angle( 0,0,0 ),
	["Team2"] = Angle( 0,180,0 )

}

GM.Config.BoardPos = Vector( 7821.472656 , 3161.940918 , 1600.575806 )
GM.Config.BoardAng = Angle( 90 , -90 , 180 )

GM.Config.QueuePos = Vector( 7942.119141 , 3296.791260 , 1600.575806 )
GM.Config.QueueAng = Angle( 90 , 0 , 180 )

GM.Config.BallPos = Vector( 6144.689453 , 3329.415039 , 1260.531250 )

GM.Config.BoostPos = {
	
	Vector( 5247.230957 , 2089.328613 , 1073.154541 ),
	Vector( 7026.954590 , 2089.328613 , 1073.154541 ),

	Vector( 5247.230957 , 4541.312500 , 1073.154541 ),
	Vector( 7026.954590 , 4541.312500 , 1073.154541 ),	

}