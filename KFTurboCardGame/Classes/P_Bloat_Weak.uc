class P_Bloat_Weak extends P_Bloat_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}

function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;

	if( Controller!=None && KFDoorMover(Controller.Target)!=None )
	{
		Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = Location+(vect(30,0,64) >> Rotation)*DrawScale;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = Class'P_Bloat_Weak_Proj';
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 500;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = False;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = True;
		SavedFireProperties.bInitialized = True;
	}

    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);
	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
	Spawn(Class'P_Bloat_Weak_Proj',,,FireStart,FireRotation);

	FireStart-=(0.5*CollisionRadius*Y);
	FireRotation.Yaw -= 1200;
	spawn(Class'P_Bloat_Weak_Proj',,,FireStart, FireRotation);

	FireStart+=(CollisionRadius*Y);
	FireRotation.Yaw += 2400;
	spawn(Class'P_Bloat_Weak_Proj',,,FireStart, FireRotation);
	// Turn extra collision back on
	ToggleAuxCollision(true);
}

defaultproperties
{
     ColOffset=(Z=30.000000)
     ColRadius=24.000000
     ColHeight=20.000000
     PrePivot=(Z=-10.000000)
     CollisionRadius=24.000000
     CollisionHeight=34.000000
     MeleeRange=23.000000
     HealthMax=265.000000
     Health=265
     HeadScale=1.300000
     HeadRadius=6.000000
     HeadHealth=25.000000
     MeleeDamage=7
}