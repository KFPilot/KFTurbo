
//-------------------------------------------------------------------------------
// Shotgun Husk
//-------------------------------------------------------------------------------

class P_Husk_Shotgun extends P_Husk_SUM;

var int AttackRange; // Minimum distance in units from the target when the husk is allowed to initiate an attack.
var int AttackSpreadDegree; // Random deviation of the projectiles fired by the husk, in degrees.
var int AttackProjectileCount; // Count of projectiles fired by the husk.
var class<Emitter> SteamEmitterClass; // Emitter for the whistle stream
var class<Emitter> SteamPuffEmitterClass; // Emitter for the steam puff

simulated function PostBeginPlay()
{
    local Emitter AttachedEmitter;
    local Emitter AttachedEmitter2;
    local vector BoneLocation;
    local vector AttachOffset;

    super.PostBeginPlay();

    BoneLocation = GetBoneCoords('CHR_Ribcage').Origin;
	// Attach steam stream emitter
    AttachOffset = vect(13, -1, 9); // X = height, Z = distance

    if (SteamEmitterClass != None)
    {
		AttachedEmitter = Spawn(SteamEmitterClass, , , BoneLocation, rot(0, 0, 0));

        if (AttachToBone(AttachedEmitter, 'CHR_Ribcage'))
        {
            AttachedEmitter.SetRelativeLocation(AttachOffset);
        }
		else
        {
            log("Failed to attach emitter to bone.", 'Error');
            AttachedEmitter.Destroy();
        }
    }
	// Attach steam puff emitter
    AttachOffset = vect(18.5, -1, 19); // X = height, Z = distance

	if (SteamPuffEmitterClass != None)
    {
		AttachedEmitter2 = Spawn(SteamPuffEmitterClass, , , BoneLocation, rot(0, 0, 0));

        if (AttachToBone(AttachedEmitter2, 'CHR_Ribcage'))
        {
            AttachedEmitter2.SetRelativeLocation(AttachOffset);
        }
		else
        {
            log("Failed to attach emitter to bone.", 'Error');
            AttachedEmitter2.Destroy();
        }
    }
}

function RangedAttack(Actor A)
{
	if ( bShotAnim )
    {
		return;
    }

	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('Claw');
		bShotAnim = true;
        return;
	}

	if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		bShotAnim = true;
		SetAnimAction('Claw');
        
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
        return;
	}

	// We do not care about fog in this case because the range is short to begin with.
	if ( (KFDoorMover(A) != none || VSize(A.Location-Location) <= AttackRange) && !bDecapitated && !bZapped && !bHarpoonStunned)
	{
        bShotAnim = true;
		SetAnimAction('ShootBurns');

		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);

		NextFireProjectileTime = Level.TimeSeconds + ProjectileFireInterval + (FRand() * 2.0);
	}
}

function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation, AdjustedRotation;
    local int i;


	if( Controller!=None && KFDoorMover(Controller.Target)!=None )
	{
		Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = GetBoneCoords('Barrel').Origin;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = HuskFireProjClass;
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = AttackRange;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = true;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = True;
	}

    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);

    // Get the base aim
    FireRotation = Controller.AdjustAim(SavedFireProperties, FireStart, 600);

    for (i = 0; i < AttackProjectileCount; i++)
    {
        // Create a random deviation within a cone
        AdjustedRotation.Pitch = FireRotation.Pitch + RandRange(-AttackSpreadDegree * 182, AttackSpreadDegree * 182);  // Convert degrees to Unreal's rotation units
        AdjustedRotation.Yaw = FireRotation.Yaw + RandRange(-AttackSpreadDegree * 182, AttackSpreadDegree * 182);    // Convert degrees to Unreal's rotation units
        AdjustedRotation.Roll = FireRotation.Roll;

        // Spawn the projectile with the adjusted rotation
        Spawn(HuskFireProjClass, , , FireStart, AdjustedRotation);
    }

	// Turn extra collision back on
	ToggleAuxCollision(true);
}

defaultproperties
{
	AttackRange=2100
	AttackSpreadDegree=15
	AttackProjectileCount=5
    ProjectileFireInterval=2.500000
	SteamEmitterClass=Class'KFTurbo.P_Husk_Shotgun_SteamEmitter'
	SteamPuffEmitterClass=Class'KFTurbo.P_Husk_Shotgun_SteamPuffEmitter'
    HuskFireProjClass=Class'KFTurbo.P_Husk_Shotgun_Proj'
    OnlineHeadshotOffset=(X=25.000000,Z=45.000000)
    OnlineHeadshotScale=1.100000
	HeadHeight=-5.000000
    HeadHealth=270.000000
    HealthMax=800.000000
    Health=800
    MenuName="Scorcher"
}