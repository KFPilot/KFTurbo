//Killing Floor Turbo TurboVotingHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVotingHandler extends KFVotingHandler
	config(KFMapVote);

var globalconfig bool bCanSpectatorsMapVote; //If true, spectators can map vote.

function AddMapVoteReplicationInfo(PlayerController Player)
{
	local TurboVotingReplicationInfo VotingReplicationInfo;

	VotingReplicationInfo = Spawn(class'TurboVotingReplicationInfo', Player, , Player.Location);
	if (VotingReplicationInfo == None)
	{
		Log("___Failed to spawn VotingReplicationInfo", 'MapVote');
		return;
	}

	VotingReplicationInfo.PlayerID = Player.PlayerReplicationInfo.PlayerID;
	MVRI[MVRI.Length] = VotingReplicationInfo;
}

function SubmitMapVote(int MapIndex, int GameIndex, Actor Voter)
{
	//Not sure why KFMapVoteV2 allows for spectator map voting by default.
	if (!bCanSpectatorsMapVote && PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator)
	{
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

	Super.SubmitMapVote(MapIndex, GameIndex, Voter);
}

defaultproperties
{
	MapListLoaderType="KFTurboMapVote.TurboMapListLoader"
	bCanSpectatorsMapVote=false
}