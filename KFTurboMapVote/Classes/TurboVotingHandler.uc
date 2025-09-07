//Killing Floor Turbo TurboVotingHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVotingHandler extends KFVotingHandler
	config(KFMapVote);

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

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

defaultproperties
{
	MapListLoaderType="KFTurboMapVote.TurboMapListLoader"
}