//Killing Floor Turbo KFTurboHoldoutMut
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboHoldoutMut extends Mutator;

#exec obj load file="..\Textures\TurboHoldout.utx" package=KFTurboHoldout

var array<WeaponPickup> WeaponPickupList;

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
}

function Timer()
{
	local int Index;
	local array<TurboPlayerController> PlayerList;
	local WeaponPickup Pickup;

	if (WeaponPickupList.Length == 0)
	{
		return;
	}

	while (WeaponPickupList.Length != 0)
	{
		Pickup = WeaponPickupList[0];
		WeaponPickupList.Remove(0, 1);
		
		if (Pickup != None && !Pickup.bThrown)
		{
			Pickup = None;
		}

		if (Pickup != None)
		{
			break;
		}
	}

	if (Pickup == None)
	{
		return;
	}

	Pickup.LifeSpan = 15.f;

	PlayerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level, true);
	for (Index = 0; Index < PlayerList.Length; Index++)
	{
		HoldoutPlayerController(PlayerList[Index]).ClientMarkPickupShortLived(Pickup);
	}

	if (WeaponPickupList.Length == 0)
	{
		SetTimer(0.25f, false);
	}
}

function Tick(float DeltaTime)
{
	class'KFTurboMut'.static.FindMutator(Level.Game).SetGameType(Self, "turboholdoutgame");
	Disable('Tick');
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (WeaponPickup(Other) != None)
	{
		if (WeaponPickupList.Length == 0)
		{
			SetTimer(0.25f, false);
		}

		WeaponPickupList[WeaponPickupList.Length] = WeaponPickup(Other);
	}

	return true;
}

function HandleWeaponPickup(WeaponPickup Pickup)
{
	if (!Pickup.bThrown)
	{
		return;
	}

	Pickup.Lifespan = 15.f;
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