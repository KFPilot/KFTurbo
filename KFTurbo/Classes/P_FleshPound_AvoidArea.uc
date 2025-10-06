//Killing Floor Turbo P_FleshPound_AvoidArea
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_FleshPound_AvoidArea extends FleshPoundAvoidArea;

function bool RelevantTo(Pawn P)
{	
	if (KFMonster(P) != None && (P.AnimAction == 'KnockDown' || !KFMonster(P).CanGetOutOfWay()))
	{
		return false;
	}

	if (MonsterFleshpoundBase(P) != None)
	{
		return false;
	}

	return Super.RelevantTo(P);
}

defaultproperties
{

}
