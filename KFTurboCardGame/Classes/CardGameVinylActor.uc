//Killing Floor Turbo CardGameVinylActor
//Purchasable vinyl spawned outside the trader during trader time. Displays the vinyl its replicated
//VinylReference resolves to.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameVinylActor extends Actor
	dependson(CardGameVinylLabel);

//Replicated VinylReference (kept as raw fields - foreign struct types can't be used in var declarations).
var class<CardGameVinylLabel> VinylLabel;
var int VinylIndex;
var TurboVinyl Vinyl; //Server holds the label instance's vinyl object; clients resolve the label CDO's from the reference.
var bool bIsPurchased;

var float SpinRate; //Spin about the facing axis in rotator units per second.

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		VinylLabel, VinylIndex;
}

function SetVinyl(TurboVinyl NewVinyl)
{
	local CardGameVinylLabel.VinylReference Reference;

	Vinyl = NewVinyl;
	Reference = class'CardGameVinylLabel'.static.MakeVinylReference(NewVinyl);
	VinylLabel = Reference.Label;
	VinylIndex = Reference.VinylIndex;
	ApplyVinylDisplay();
	NetUpdateTime = Level.TimeSeconds - 1.f;
}

simulated event PostNetReceive()
{
	local CardGameVinylLabel.VinylReference Reference;
	local TurboVinyl ResolvedVinyl;

	Super.PostNetReceive();

	Reference.Label = VinylLabel;
	Reference.VinylIndex = VinylIndex;
	ResolvedVinyl = class'CardGameVinylLabel'.static.ResolveVinyl(Reference);

	if (ResolvedVinyl != Vinyl)
	{
		Vinyl = ResolvedVinyl;
		ApplyVinylDisplay();
	}
}

simulated function ApplyVinylDisplay()
{
	local int Index;

	if (Vinyl == None)
	{
		return;
	}

	SetStaticMesh(Vinyl.VinylMesh);

	Skins.Length = Vinyl.SkinList.Length;
	for (Index = 0; Index < Vinyl.SkinList.Length; Index++)
	{
		Skins[Index] = Vinyl.SkinList[Index];
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
	local PlayerReplicationInfo PRI;

	if (bIsPurchased || Vinyl == None || User == None || User.Health <= 0 || User.PlayerReplicationInfo == None)
	{
		return;
	}

	PRI = User.PlayerReplicationInfo;
	CardInfo = TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(PRI)));

	if (CardInfo == None || CardInfo.AuthVinyl == Vinyl || !CardInfo.CanPurchaseVinyl())
	{
		return;
	}

	if (int(PRI.Score) < Vinyl.VinylPrice)
	{
		return;
	}

	PRI.Score -= float(Vinyl.VinylPrice);
	CardInfo.SetVinyl(Vinyl);
	CardInfo.MarkVinylPurchased();
	bIsPurchased = true;
	LifeSpan = 0.1f;
}

defaultproperties
{
	VinylIndex=-1

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
	bAlwaysRelevant=true
	bNetNotify=true
	NetUpdateFrequency=1.f
}
