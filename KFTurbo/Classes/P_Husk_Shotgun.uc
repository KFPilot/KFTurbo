
//-------------------------------------------------------------------------------
// Shotgun Husk
//-------------------------------------------------------------------------------

class P_Husk_Shotgun extends P_Husk_SUM;

var int AttackRange; //Range in units from where the husk is allowed to initiate an attack.
var int AttackSpreadDegree; //Random deviation of the projectiles fired by the husk, in degrees.
var int AttackProjectileCount; //Count of projectiles fired by the husk.

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
	local KFMonsterController KFMonstControl;
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

        foreach DynamicActors(class'KFMonsterController', KFMonstControl)
        {
            if( KFMonstControl != Controller )
            {
                if( PointDistToLine(KFMonstControl.Pawn.Location, vector(AdjustedRotation), FireStart) < 75 )
                {
                    KFMonstControl.GetOutOfTheWayOfShot(vector(AdjustedRotation), FireStart);
                }
            }
        }

        // Spawn the projectile with the adjusted rotation
        Spawn(HuskFireProjClass, , , FireStart, AdjustedRotation);
    }

	// Turn extra collision back on
	ToggleAuxCollision(true);
}

defaultproperties
{
	AttackRange=700
	AttackSpreadDegree=15
	AttackProjectileCount=5
    ProjectileFireInterval=1.500000
    HuskFireProjClass=Class'KFTurbo.P_Husk_Shotgun_Proj'
    HeadHealth=270.000000
    HealthMax=800.000000
    Health=800
    MenuName="Scorcher"
}