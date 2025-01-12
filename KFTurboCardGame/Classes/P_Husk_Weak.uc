class P_Husk_Weak extends P_Husk_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}


function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;
	local KFMonsterController KFMonstControl;


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
		SavedFireProperties.MaxRange = 65535;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = true;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = True;
	}

    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);

	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);

	foreach DynamicActors(class'KFMonsterController', KFMonstControl)
	{
        if( KFMonstControl != Controller )
        {
            if( PointDistToLine(KFMonstControl.Pawn.Location, vector(FireRotation), FireStart) < 75 )
            {
                KFMonstControl.GetOutOfTheWayOfShot(vector(FireRotation),FireStart);
            }
        }
	}

    Spawn(HuskFireProjClass,,,FireStart,FireRotation);

	// Turn extra collision back on
	ToggleAuxCollision(true);
}

defaultproperties
{
     ColOffset=(Z=36.000000)
     ColRadius=24.000000
     ColHeight=10.000000    
     PrePivot=(Z=18.000000)
     CollisionRadius=22.000000
     CollisionHeight=26.000000
     HeadHealth=100.000000
     MeleeRange=23.000000
     HealthMax=300.000000
     Health=300
     MeleeDamage=7
     HuskFireProjClass=Class'KFTurboCardGame.P_Husk_Weak_Proj'
     OnlineHeadshotOffset=(X=18.000000,Z=40.000000)
     MenuName="Weak Husk"
}