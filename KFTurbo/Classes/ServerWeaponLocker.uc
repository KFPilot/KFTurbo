//Killing Floor Turbo ServerWeaponLocker
//Used to fix ShopVolume accessed none log warning.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class ServerWeaponLocker extends WeaponLocker;

simulated event PreBeginPlay()
{
	Super(Actor).PreBeginPlay();
}

simulated event PostBeginPlay()
{
	Super(Actor).PostBeginPlay();
    Disable('Tick');
}

function SetOpen(bool bToOpen) {}

simulated function AnimEnd( int Channel ) {}

defaultproperties
{
    bHidden=true
    DrawType=DT_None
    bReplicateAnimations=false
    RemoteRole=ROLE_None
    Mesh=None
    DrawScale=1.000000
    CollisionRadius=1.0
    CollisionHeight=1.0
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockKarma=false
    bBlockZeroExtentTraces=false
    bBlockNonZeroExtentTraces=false
    bNetInitialRotation=false
    bAlwaysRelevant=false
    NetUpdateFrequency=0.001
}