//Killing Floor Turbo CardGameVinylActor
//Purchasable vinyl spawned outside the trader during trader time. Displays the vinyl its replicated VinylReference resolves to.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameVinylActor extends Actor
	dependson(CardGameVinylLabel);

//Reference to vinyl this actor represents.
var CardGameVinylLabel.VinylReference VinylReference, LastKnownVinylReference;
//Server holds the label instance's vinyl object.
var TurboVinyl VinylInstance;

var int VinylPrice;
var bool bIsPurchased;

var float SpinRate; //Spin about the facing axis in rotator units per second.

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		VinylReference, VinylPrice;
}

function SetVinyl(TurboVinyl NewVinyl)
{
	VinylInstance = NewVinyl;
	VinylReference = class'CardGameVinylLabel'.static.MakeVinylReference(NewVinyl);

	if (NewVinyl != None)
	{
		VinylPrice = NewVinyl.VinylPrice;
	}

	NetUpdateTime = Level.TimeSeconds - 1.f;

	PostNetReceive();
}

simulated event PostNetReceive()
{
	Super.PostNetReceive();

	if (class'CardGameVinylLabel'.static.AreVinylReferencesEqual(VinylReference, LastKnownVinylReference))
	{
	    return;
	}

	LastKnownVinylReference = VinylReference;

	if (VinylReference.Label == None)
	{
	    return;
	}

	if (Level.NetMode != NM_DedicatedServer)
	{
	    VinylReference.Label.static.ConfigureVinylActor(VinylReference, Self);
	}
}

//Billboard toward the local player while spinning about the facing axis. Runs client-side.
simulated function Tick(float DeltaTime)
{
	local PlayerController LocalPlayer;
	local Vector AxisX, AxisY, AxisZ;
	local Rotator Spin;

	if (Level.NetMode == NM_DedicatedServer)
	{
		Disable('Tick');
		return;
	}

	LocalPlayer = Level.GetLocalPlayerController();

	if (LocalPlayer == None)
	{
		return;
	}

	//Mesh's positive Z axis yaws toward the player's view - no pitch, the disk stays upright.
	AxisZ = LocalPlayer.CalcViewLocation - Location;
	AxisZ.Z = 0.f;

	//Degenerate when the player is directly above/below - keep the current rotation.
	if (VSize(AxisZ) < 1.f)
	{
		return;
	}

	AxisZ = Normal(AxisZ);
	AxisX = vect(0, 0, 1) cross AxisZ;
	AxisY = AxisZ cross AxisX;

	Spin.Yaw = int(SpinRate * Level.TimeSeconds);
	SetRotation(class'TurboCardOverlay'.static.ComposeRotations(OrthoRotation(AxisX, AxisY, AxisZ), Spin));
}

//Use key pressed by a touching pawn.
function UsedBy(Pawn User)
{
	AttemptPurchase(User);
}

function AttemptPurchase(Pawn User)
{
	local TurboPlayerCardCustomInfo CardInfo;
	local TurboPlayerReplicationInfo PRI;
	local float Cost;

	if (bIsPurchased || VinylPrice == -1 || VinylInstance == None || User == None || User.Health <= 0 || User.PlayerReplicationInfo == None)
	{
		return;
	}

	//This vinyl was offered to a specific player - only they can buy it.
	if (User.Controller != Owner)
	{
		return;
	}

	PRI = TurboPlayerReplicationInfo(User.PlayerReplicationInfo);
	CardInfo = TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(PRI));

	if (CardInfo == None || CardInfo.AuthVinyl == VinylInstance || !CardInfo.CanPurchaseVinyl())
	{
		return;
	}

    Cost = GetVinylPrice(PRI);

	if (int(PRI.Score) < Cost)
	{
		return;
	}

	PRI.Score -= Cost;
	CardInfo.SetVinyl(VinylInstance);
	CardInfo.MarkVinylPurchased();
	bIsPurchased = true;
	LifeSpan = 0.1f;
}

simulated function float GetVinylPrice(TurboPlayerReplicationInfo PRI)
{
    local float Price;
    Price = VinylPrice;

	if (PRI != None && PRI.ClientVeteranSkill != None)
	{
	    Price *= PRI.ClientVeteranSkill.static.GetCostScaling(PRI, class'CardGameVinylPickup');
	}

	return int(Price);
}

defaultproperties
{
	VinylReference=(PerkIndex=255,VinylIndex=-1)
	LastKnownVinylReference=(PerkIndex=255,VinylIndex=-1)
	VinylPrice=-1

	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'KFTurboCardGame.Song.Vinyl'
	DrawScale=0.5f
	bUnlit=true

	SpinRate=12000.f

	bCollideActors=true
	bCollideWorld=false
	bBlockActors=false
	bBlockPlayers=false
	bUseCylinderCollision=true
	CollisionRadius=72.f
	CollisionHeight=48.f

	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
	bNetNotify=true
	NetUpdateFrequency=1.f
}
