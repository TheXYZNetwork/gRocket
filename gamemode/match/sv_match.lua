--[[

	Server Side Matchmaking

]]

GM.Match = (GAMEMODE or GM).Match or {}

GM.Match.Queue = (GAMEMODE or GM).Match.Queue or {}
GM.Match.Invites = (GAMEMODE or GM).Match.Invites or {}
GM.Match.Cars = (GAMEMODE or GM).Match.Cars or {}
GM.Match.Game = (GAMEMODE or GM).Match.Game or {}

GM.Match.QueueAttempts = (GAMEMODE or GM).Match.QueueAttempts or 0

util.AddNetworkString( "gRocket_UpdateMatch" )
util.AddNetworkString( "gRocket_UpdatePlayerQueue" )
util.AddNetworkString( "gRocket_UpdateQueue" )
util.AddNetworkString( "gRocket_RequestQueue" )

util.AddNetworkString( "gRocket_RequestRandom" )
util.AddNetworkString( "gRocket_RequestPrivate" )
util.AddNetworkString( "gRocket_CreatePrivate" )
util.AddNetworkString( "gRocket_RequestLeave" )
util.AddNetworkString( "gRocket_RequestInvite" )

util.AddNetworkString( "gRocket_AdminKick" )
util.AddNetworkString( "gRocket_AdminDisband" )

function GM.Match:GetQueuePlayers( queueID )

	if !self.Queue[queueID] then return end

	local plyTable = {}
	plyTable["Team1"] = {}
	plyTable["Team2"] = {}

	for k, v in pairs(self.Queue[queueID]["Players"]["Team1"]) do

		table.insert( plyTable["Team1"] , v )

	end

	for k, v in pairs(self.Queue[queueID]["Players"]["Team2"]) do

		table.insert( plyTable["Team2"] , v )

	end

	local plyAmount = #plyTable["Team1"] + #plyTable["Team2"]

	return plyAmount, plyTable

end

function GM.Match:CurrentGame()

	if table.Count( self.Game ) == 0 then

		return false

	end

end

function GM.Match:Initialize()

	timer.Create("gRocket_QueueCheck",30,0,function()

		if self:CurrentGame() then return end

		if !self.Queue[1] then return end
		if !(self.Queue[1]["Created"] + 30 > CurTime()) then return end

		local queueAmount, queuePlayers = self:GetQueuePlayers( 1 )

		if !queueAmount then return end
		if !queuePlayers then return end

		if queueAmount < 2 then
			
			self.QueueAttempts = self.QueueAttempts + 1

			if self.QueueAttempts > 3 then

				local owner = self.Queue["Leader"]

				if !IsValid( owner ) then return end

				local tempQueue = self.Queue[1]

				table.insert( self.Queue , tempQueue )

				table.remove( self.Queue , 1 )

				self:UpdateQueue()

				owner:PrintMessage( HUD_PRINTCENTER , "Your team has been moved to the back of the queue as you do not have enough players." )

			end

			return

		end

		self:StartMatch( queueAmount , queuePlayers )

		self.Queue[1] = nil

		self:UpdateQueue()		

		// Update Game Details Here

	end)

end

function GM.Match:InitialSpawn( ply )

	ply:SetInMatch( false )
	ply:SetInQueue( false )

	self:UpdateQueue()

end

function GM.Match:OnCarSpawned( ply , car )

	--[[for k, v in pairs( ents.FindByClass( "ent_boost_ball" ) ) do

		local yes = constraint.NoCollide( v, car, 0, 0 )

		if !yes then print("MEME") end

	end]]

end

function GM.Match:SpawnPlayerCar( ply , pos , ang )

	local car = ents.Create( "prop_vehicle_jeep_old" )
	car:SetModel("models/tdmcars/focusrs.mdl")
	car:SetKeyValue("vehiclescript","scripts/vehicles/TDMCars/focusrs.txt")
	car:SetPos( pos )
	car:SetAngles( ang )
	car.Owner = ply
	car:Spawn()
	car:Activate()

	ply:EnterVehicle( car )

	self.Cars[ply:SteamID64()] = car

	self.OnCarSpawned( ply , car )

end

function GM.Match:StartMatch( plyAmount, playerList )

	local team1 = GAMEMODE.Config.CarPositions["Team1"]
	local team2 = GAMEMODE.Config.CarPositions["Team2"]

	local positions = {

		["Team1"] = {},
		["Team2"] = {}

	}

	if (#playerList["Team1"] == 1 and #playerList["Team2"] == 1) then
		positions["Team1"] = { team1[1] }
		positions["Team2"] = { team2[1] }
	elseif (#playerList["Team1"] == 1 and #playerList["Team2"] == 2) then
		positions["Team1"] = { team1[1] }
		positions["Team2"] = { team2[2] , team2[3] }
	elseif (#playerList["Team1"] == 1 and #playerList["Team2"] == 3) then
		positions["Team1"] = { team1[1] }
		positions["Team2"] = { team2[1] , team2[2] , team2[3] }
	elseif (#playerList["Team1"] == 2 and #playerList["Team2"] == 1) then
		positions["Team1"] = { team1[3] , team1[2] }
		positions["Team2"] = { team2[1] }
	elseif (#playerList["Team1"] == 3 and #playerList["Team2"] == 1) then
		positions["Team1"] = { team1[1] , team1[2] , team1[3] }
		positions["Team2"] = { team2[1] }
	elseif (#playerList["Team1"] == 2 and #playerList["Team2"] == 2) then
		positions["Team1"] = { team1[2] , team1[3] }
		positions["Team2"] = { team2[2] , team2[3] }
	elseif (#playerList["Team1"] == 3 and #playerList["Team2"] == 2) then
		positions["Team1"] = { team1[1] , team1[2], team1[3] }
		positions["Team2"] = { team2[2] , team2[3] }
	elseif (#playerList["Team1"] == 2 and #playerList["Team2"] == 3) then
		positions["Team1"] = { team1[2] , team1[3] }
		positions["Team2"] = { team2[1] , team2[2] , team2[3] }
	else		
		positions["Team1"] = { team1[1] , team1[2] , team1[3] }
		positions["Team2"] = { team2[1] , team2[2] , team2[3] }
	end

	local team1increase = 1
	local team2increase = 1

	for k, v in pairs(playerList) do

		local plyTeam = v:GetTeamName()

		if plyTeam == "Team1" then

			self:JoinMatch( v , positions["Team1"][team1increase] , GAMEMODE.Config.CarAngles["Team1"] )
			team1increase = team1increase + 1

		else
 
 			self:JoinMatch( v , positions["Team2"][team2increase] , GAMEMODE.Config.CarAngles["Team2"] )
 			team2increase = team2increase + 1

 		end


	end

	table.remove( self.Queue , 1 )
	self.QueueAttempts = 0

end

function GM.Match:JoinMatch( ply , pos , ang )

	if !ply:IsInMatch() and ply:IsInQueue() then
		
		ply:SetInMatch( true )
		ply:SetInQueue( false )
		ply:SetQueueID( nil )

		self:UpdatePlayerQueue( v , false )
		self:SpawnPlayerCar( ply , pos , ang )
		GAMEMODE.Car:PlayerJoinedMatch( ply )

		self:UpdateMatch( ply , true )

	end

end

function GM.Match:InvitePlayer( ply , groupID )

	if !self.Invites[groupID] then
		self.Invites[groupID] = {}
	end

	table.insert( self.Invites[groupID] , ply )

end

function GM.Match:HasInvite( ply , groupID )

	if table.HasValue(self.Invites[groupID] , ply) then
		return true
	end

	return false

end

function GM.Match:CreateLobby( ply , security , plyTable )

	local lobbyTable = {

		["Security"] = security,
		["Leader"] = ply,
		["Created"] = CurTime(),
		["Players"] = {

			["Team1"] = {},
			["Team2"] = {},

		}

	}

	local index = table.insert( self.Queue , lobbyTable )

	self:JoinQueue( ply , index )

	if security == "closed" then

		for k, v in pairs( plyTable ) do

			local ply = GAMEMODE.Util:FindPlayerByName( v )

			if IsValid(ply) then

				self:InvitePlayer( ply , index )

			end

		end

	end

end

function GM.Match:JoinQueue( ply , queueID )

	local plyName = ply:Nick()

	if (#self.Queue[queueID]["Players"]["Team1"] > #self.Queue[queueID]["Players"]["Team2"]) then
		table.insert( self.Queue[queueID]["Players"]["Team2"] , ply )
		ply:SetTeamName("Team2")
	else
		table.insert( self.Queue[queueID]["Players"]["Team1"] , ply )
		ply:SetTeamName("Team1")
	end

	ply:SetInQueue( true )
	ply:SetQueueID( queueID )

	self:UpdatePlayerQueue( ply , true )
	self:UpdateQueue()

end

function GM.Match:JoinRandomQueue( ply )

	if !ply:IsInMatch() and !ply:IsInQueue() then

		local foundQueue = false

		// Find Open Random Queue:
		for k, v in pairs(self.Queue) do
			if v["Security"] == "open" then

				// If team is full
				if (#v["Players"]["Team1"] == 3) and (#v["Players"]["Team2"] == 3) then return end

				// If everything is good, set the queue id
				foundQueue = k
				break // quit loop
			end
		end

		// Check if queue is set
		if foundQueue then
			self:JoinQueue( ply , foundQueue )
		else // If not then create a new open lobby
			self:CreateLobby( ply , "open" )
		end		

	end

end

function GM.Match:JoinPrivateQueue( ply , queueID )

	if !ply:IsInMatch() and !ply:IsInQueue() then
		
		if !self.Queue[queueID] then return end
		if !self:HasInvite( ply , queueID ) then return end

		self:JoinQueue( ply , queueID )

	end

end

function GM.Match:CreatePrivateQueue( ply )

	if !ply:IsInMatch() and !ply:IsInQueue() then

		local plyTable = net.ReadTable()

		self:CreateLobby( ply , "closed" , plyTable )

	end

end

net.Receive("gRocket_RequestRandom",function(len,ply)
	GAMEMODE.Match:JoinRandomQueue( ply )
end)

net.Receive("gRocket_RequestPrivate",function(len,ply)
	GAMEMODE.Match:JoinPrivateQueue( ply )
end)

net.Receive("gRocket_CreatePrivate",function(len,ply)
	GAMEMODE.Match:CreatePrivateQueue( ply )
end)


function GM.Match:UpdateMatch( ply , inMatch )

	net.Start("gRocket_UpdateMatch")
		net.WriteBool( inMatch )
	net.Send( ply )

end

function GM.Match:UpdatePlayerQueue( ply , inQueue )

	if !IsValid(ply) then return end

	net.Start("gRocket_UpdatePlayerQueue")
		net.WriteBool( inQueue )
	net.Send( ply )

end

function GM.Match:UpdateQueue()

	net.Start("gRocket_UpdateQueue")
		net.WriteTable( self.Queue )
	net.Broadcast()

end

function GM.Match:GetGroupPlayers( groupID )

	local plyTable = {}

	if !self.Queue[groupID] then return end

	for k, v in pairs(self.Queue[groupID]["Players"]["Team1"]) do

		table.insert( plyTable , v )

	end

	for k, v in pairs(self.Queue[groupID]["Players"]["Team2"]) do

		table.insert( plyTable , v )

	end

	return plyTable

end

function GM.Match:RequestQueue( ply )

	local plyTable = {}

	for k, v in pairs( player.GetAll() ) do

		if !v:IsInQueue() and !v:IsInMatch() then
			table.insert( plyTable, v )
		end

	end

	net.Start( "gRocket_RequestQueue" )
		net.WriteTable( plyTable )
	net.Send( ply )

end

function GM.Match:PlayerLeaveMatch( ply )

	if !ply:GetCar() then return end

	ply:RemoveCar()

	ply:SetInMatch( false )

	self:UpdateMatch( ply , false )

end

function GM.Match:PlayerLeaveQueue( ply )

	if !ply:IsInQueue() then return end
	if !ply:GetQueueID() then return end

	local queueID = ply:GetQueueID()

	table.RemoveByValue( self.Queue[queueID]["Players"]["Team1"] , ply )
	table.RemoveByValue( self.Queue[queueID]["Players"]["Team2"] , ply )

	if (#self.Queue[queueID]["Players"]["Team1"] == 0) and (#self.Queue[queueID]["Players"]["Team2"] == 0) then
		self.Queue[queueID] = nil
	end

	ply:SetInQueue( false )
	ply:SetQueueID( nil )

	self:UpdatePlayerQueue( ply , false )
	self:UpdateQueue()	

end

function GM.Match:KickPlayer( ply , kickPlayer )

	if !ply:GetQueueID() then return end
	if !kickPlayer:GetQueueID() then return end

	local queueID = ply:GetQueueID()
	local kickQueueID = kickPlayer:GetQueueID()

	if !( queueID == kickQueueID ) then return end

	if !ply:IsTeamLeader( queueID ) then return end

	table.RemoveByValue( self.Queue[queueID]["Players"][kickPlayer:GetTeamName()] , kickPlayer )

	if (#self.Queue[queueID]["Players"]["Team1"] == 0) and (#self.Queue[queueID]["Players"]["Team2"] == 0) then
		self.Queue[queueID] = nil
	end

	ply:SetInQueue( false )
	ply:SetQueueID( nil )	

	self:UpdatePlayerQueue( kickPlayer , false )
	self:UpdateQueue()

end
net.Receive("gRocket_AdminKick",function( len,ply )
	local kickply = net.ReadEntity()
	GAMEMODE.Match:KickPlayer( ply , kickply )
end)

function GM.Match:DisbandGroup( ply )

	if !ply:GetQueueID() then return end

	local queueID = ply:GetQueueID()

	if !ply:IsTeamLeader( queueID ) then return end

	for k, v in pairs( self:GetGroupPlayers(queueID) ) do

		self:KickPlayer( ply , v )

	end

end
net.Receive("gRocket_AdminDisband",function( len,ply )
	GAMEMODE.Match:DisbandGroup( ply )
end)

net.Receive("gRocket_RequestLeave",function(len,ply)

	GAMEMODE.Match:PlayerLeaveQueue(ply)

end)

concommand.Add("join_match",function( ply, cmd, args )

	GAMEMODE.Match:JoinMatch( ply )

end)

concommand.Add("leave_match",function( ply, cmd, args )

	GAMEMODE.Match:PlayerLeaveMatch( ply )

end)

concommand.Add("get_queue",function( ply, cmd, args )

	PrintTable( GAMEMODE.Match.Queue )

end)

local pmeta = FindMetaTable( "Player" )

function pmeta:SetInMatch( inMatch )

	self.inMatch = inMatch

end

function pmeta:SetInQueue( inQueue )

	self.inQueue = inQueue

end

function pmeta:SetQueueID( queueID )

	self.queueID = queueID

end

function pmeta:GetQueueID()

	return self.queueID or false

end

function pmeta:SetTeamName( teamName )

	self.teamName = teamName

end

function pmeta:GetTeamName()

	return self.teamName or false

end

function pmeta:IsTeamLeader( queueID )

	if (GAMEMODE.Match.Queue[queueID]["Leader"] == self) then
		return true
	else
		return false
	end

end

function pmeta:IsInMatch()

	return self.inMatch

end

function pmeta:IsInQueue()

	return self.inQueue

end

function pmeta:GetCar()

	if !GAMEMODE.Match.Cars[self:SteamID64()] then return end

	return GAMEMODE.Match.Cars[self:SteamID64()]

end

function pmeta:RemoveCar()

	local car = self:GetCar()
	local driver = car:GetDriver() or false

	if driver then
		driver:ExitVehicle()
		driver:SetPos( GAMEMODE.Config.SpawnPos )
	end

	car:Remove()
	GAMEMODE.Match.Cars[self:SteamID64()] = nil

end