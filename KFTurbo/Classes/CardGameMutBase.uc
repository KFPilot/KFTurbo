//Killing Floor Turbo CardGameMutBase
//Base class for card game mutators. Allows for API to run in KFTurbo without knowing specific implementation.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameMutBase extends Mutator;

//Returns what index a card matching CardID was activated at. Returns -1 if no card matching CardID is present in active card list.
function int HasCard(string CardID)
{
	return -1;
}

simulated function String GetHumanReadableName()
{
	return FriendlyName;
}

defaultproperties
{
	GroupName="KF-CardGame" //Used by TurboGameplayAchievementPack to determine if a card game is being played.
}
