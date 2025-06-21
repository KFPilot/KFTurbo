//Killing Floor Turbo W_NailGun_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_NailGun_Weap extends NailGun;

var         LaserDot                    Spot;                       // The first person laser site dot
var()       float                       SpotProjectorPullback;      // Amount to pull back the laser dot projector from the hit location
var         bool                        bLaserActive;               // The laser site is active
var         LaserBeamEffect             Beam;                       // Third person laser beam effect

var()		class<InventoryAttachment>	LaserAttachmentClass;      // First person laser attachment class
var 		Actor 						LaserAttachment;           // First person laser attachment

replication
{
	reliable if (Role < ROLE_Authority)
		ServerSetLaserActive;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		if (Beam == None)
		{
			Beam = Spawn(class'W_NailGun_LaserBeamEffect');
		}
	}
}

simulated function Destroyed()
{
	if (Spot != None)
		Spot.Destroy();

	if (Beam != None)
		Beam.Destroy();

	if (LaserAttachment != None)
		LaserAttachment.Destroy();

	super.Destroyed();
}

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

simulated function WeaponTick(float dt)
{
	local Vector StartTrace, EndTrace, X, Y, Z;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector MyEndBeamEffect;
	local coords C;

	Super.WeaponTick(dt);

	if (Role == ROLE_Authority && Beam != none)
	{
		if (bIsReloading && WeaponAttachment(ThirdPersonActor) != none)
		{
			C = WeaponAttachment(ThirdPersonActor).GetBoneCoords('tip');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}
		else
		{
			GetViewAxes(X, Y, Z);
		}

		// the to-hit trace always starts right in front of the eye
		StartTrace = Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator)
		{
			MyEndBeamEffect = HitLocation;
		}
		else
		{
			MyEndBeamEffect = EndTrace;
		}

		Beam.EndBeamEffect = MyEndBeamEffect;
		Beam.EffectHitNormal = HitNormal;
	}
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (Role == ROLE_Authority)
	{
		if (Beam == None)
		{
			Beam = Spawn(class'W_NailGun_LaserBeamEffect');
		}
	}
}

simulated function DetachFromPawn(Pawn P)
{
	TurnOffLaser();

	Super.DetachFromPawn(P);

	if (Beam != None)
	{
		Beam.Destroy();
	}
}

simulated function bool PutDown()
{
	if (Beam != None)
	{
		Beam.Destroy();
	}

	TurnOffLaser();

	return super.PutDown();
}

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
	if (ReadyToFire(0))
	{
		ToggleLaser();
	}
}

// Toggle the laser on and off
simulated function ToggleLaser()
{
	if (Instigator.IsLocallyControlled())
	{
		if (Role < ROLE_Authority)
		{
			ServerSetLaserActive(!bLaserActive);
		}

		bLaserActive = !bLaserActive;

		if (Beam != none)
		{
			Beam.SetActive(bLaserActive);
		}

		if (bLaserActive)
		{
			if (LaserAttachment == none)
			{
				LaserAttachment = Spawn(LaserAttachmentClass, , , , );
				AttachToBone(LaserAttachment, 'LightBone');
			}
			LaserAttachment.bHidden = false;

			if (Spot == None)
			{
				Spot = Spawn(class'W_NailGun_LaserDot', self);
			}
		}
		else
		{
			LaserAttachment.bHidden = true;
			if (Spot != None)
			{
				Spot.Destroy();
			}
		}
	}
}

simulated function TurnOffLaser()
{
	if (Instigator.IsLocallyControlled())
	{
		if (Role < ROLE_Authority)
		{
			ServerSetLaserActive(false);
		}

		bLaserActive = false;
		LaserAttachment.bHidden = true;

		if (Beam != none)
		{
			Beam.SetActive(false);
		}

		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

// Set the new fire mode on the server
function ServerSetLaserActive(bool bNewWaitForRelease)
{
	if (Beam != none)
	{
		Beam.SetActive(bNewWaitForRelease);
	}

	if (bNewWaitForRelease)
	{
		bLaserActive = true;
		if (Spot == None)
		{
			Spot = Spawn(class'W_NailGun_LaserDot', self);
		}
	}
	else
	{
		bLaserActive = false;
		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

simulated event RenderOverlays(Canvas Canvas)
{
	local int m;
	local Vector StartTrace, EndTrace;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector X, Y, Z;
	local coords C;

	if (Instigator == None)
		return;

	if (Instigator.Controller != None)
		Hand = Instigator.Controller.Handedness;

	if ((Hand < -1.0) || (Hand > 1.0))
		return;

	// draw muzzleflashes/smoke for all fire modes so idle state won't
	// cause emitters to just disappear
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m] != None)
		{
			FireMode[m].DrawMuzzleFlash(Canvas);
		}
	}

	SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
	SetRotation(Instigator.GetViewRotation() + ZoomRotInterp);

	// Handle drawing the laser beam dot
	if (Spot != None)
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		GetViewAxes(X, Y, Z);

		if (bIsReloading && Instigator.IsLocallyControlled())
		{
			C = GetBoneCoords('LightBone');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator)
		{
			EndBeamEffect = HitLocation;
		}
		else
		{
			EndBeamEffect = EndTrace;
		}

		Spot.SetLocation(EndBeamEffect - X*SpotProjectorPullback);

		if (Pawn(Other) != none)
		{
			Spot.SetRotation(Rotator(X));
			Spot.SetDrawScale(Spot.default.DrawScale * 0.5);
		}
		else if (HitNormal == vect(0, 0, 0))
		{
			Spot.SetRotation(Rotator(-X));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
		else
		{
			Spot.SetRotation(Rotator(-HitNormal));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
	}

	//PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)

	bDrawingFirstPerson = true;
	Canvas.DrawActor(self, false, false, DisplayFOV);
	bDrawingFirstPerson = false;
}

defaultproperties
{
	SpotProjectorPullback=1.000000
	LaserAttachmentClass=Class'KFTurbo.W_NailGun_LaserAttachment1st'
	MagCapacity=3
	Weight=11.000000
	FireModeClass(0)=Class'KFTurbo.W_NailGun_Fire'
	FireModeClass(1)=Class'KFMod.NoFire'
	InventoryGroup=4
	PickupClass=Class'KFTurbo.W_NailGun_Pickup'
	AttachmentClass=Class'KFTurbo.W_NailGun_Attachment'
	SkinRefs(0)="KF_Weapons8_Trip_T.Weapons.Vlad_9000_cmb"

	ReloadRate=2.000000
	ReloadAnimRate=1.400000
}
