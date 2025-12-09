//Common Core CoreKFGameType
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class CorePlayerController extends ServerPerks.KFPCServ;

//Track whether or not we were spectating the previous wave (to fix joining from spectator during a trader time).
var protected bool bWasSpectatingWave;

simulated event ReceiveLocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Super.ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

function MarkSpectatingWave()
{
	bWasSpectatingWave = true;
}

function BecomeSpectator()
{
	if (PlayerReplicationInfo == None || PlayerReplicationInfo.bOnlySpectator)
	{
		Super.BecomeSpectator();
		return;
	}

	Super.BecomeSpectator();

	if (PlayerReplicationInfo.bOnlySpectator && CoreKFGameType(Level.Game).bWaveInProgress)
	{
        MarkSpectatingWave();
	}
}

function BecomeActivePlayer()
{
	if (PlayerReplicationInfo == None || !PlayerReplicationInfo.bOnlySpectator)
	{
		Super.BecomeActivePlayer();
		return;
	}

	Super.BecomeActivePlayer();

	if (Level.Game.bDelayedStart && bWasSpectatingWave && !PlayerReplicationInfo.bOnlySpectator && Pawn == None)
	{
		bWasSpectatingWave = false;
		PlayerReplicationInfo.bOutOfLives = false;
		PlayerReplicationInfo.NumLives = 0;
		
		if (!CoreKFGameType(Level.Game).bWaveInProgress)
		{
			SetViewTarget(Self);
			ClientSetBehindView(false);
			bBehindView = False;
			ClientSetViewTarget(Pawn); //TWI calls this for some reason but pawn would be None at this point...

			ServerReStartPlayer();	
		}
	}
}

defaultproperties
{
    bWasSpectatingWave = false
}