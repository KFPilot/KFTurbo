//Killing Floor Turbo KFTurboHoldoutMut
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboHoldoutMut extends Mutator;

#exec obj load file="..\Textures\TurboHoldout.utx" package=KFTurboHoldout

var HoldoutGameRules HoldoutGameRules;
var array<WeaponPickup> WeaponPickupList;
var array<TurboPlayerReplicationInfo> PendingPlayerReplicationInfoList;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(Role != ROLE_Authority)
	{
		return;
	}

	if (!ClassIsChildOf(Level.Game.PlayerControllerClass, class'HoldoutPlayerController'))
	{
		Level.Game.PlayerControllerClass = class'HoldoutPlayerController';
		Level.Game.PlayerControllerClassName = string(class'HoldoutPlayerController');
	}

	HoldoutGameRules = CreateHoldoutGameRules();

	class'KFTurboMut'.static.FindMutator(Level.Game).SetGameType(Self, "turboholdoutgame");
}

function HoldoutGameRules CreateHoldoutGameRules()
{
	local GameRules GameRules;
	local HoldoutGameRules HGR;
	HGR = Spawn(class'HoldoutGameRules', Self);
	HGR.MutatorOwner = Self;

	if (Level.Game.GameRulesModifiers == None)
	{
		Level.Game.GameRulesModifiers = HGR;
	}
	else
	{
		for (GameRules = Level.Game.GameRulesModifiers; GameRules != None; GameRules = GameRules.NextGameRules)
		{
			if (GameRules.NextGameRules == None)
			{
				GameRules.NextGameRules = HGR;
				break;
			}
		}
	}

	return HGR;
}

function Tick(float DeltaTime)
{
	local int Index;
	for (Index = PendingPlayerReplicationInfoList.Length - 1; Index >= 0; Index--)
	{
		SpawnHoldoutPlayerSparseInfo(PendingPlayerReplicationInfoList[Index]);
	}
	PendingPlayerReplicationInfoList.Length = 0;
}

function SpawnHoldoutPlayerSparseInfo(TurboPlayerReplicationInfo PRI)
{
	if (PRI == None || MessagingSpectator(PRI.Owner) != None)
	{
		return;
	}

	if (class'HoldoutPlayerSparseInfo'.static.GetHoldoutInfo(PRI) != None)
	{
		return;
	}

	Spawn(class'HoldoutPlayerSparseInfo', PRI.Owner);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (TurboPlayerReplicationInfo(Other) != None)
	{
		PendingPlayerReplicationInfoList[PendingPlayerReplicationInfoList.Length] = TurboPlayerReplicationInfo(Other);
		return true;
	}

	return true;
}

simulated function String GetHumanReadableName()
{
	return FriendlyName;
}

defaultproperties
{
    bAddToServerPackages=True
	GroupName="KF-KFTurboMode"
	FriendlyName="Killing Floor Turbo Holdout"
	Description="Mutator for the KFTurbo Holdout Game Type."
}