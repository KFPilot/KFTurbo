//Killing Floor Turbo P_Husk
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk extends ZombieHusk DependsOn(PawnHelper);

var float ProjectileMaxRange;
var float ProjectileIntervalVariance;
var bool bOnlyProjectileAttackWhenGrounded;
var bool bTriggerGetOutOfTheWayOfShot;

var float NextAimHitTime;
var const float AimHitTimeDurtation;

var PawnHelper.AfflictionData AfflictionData;

var bool bUnstunTimeReady;
var float UnstunTime;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    class'PawnHelper'.static.InitializePawnHelper(self, AfflictionData);

    if (class'KFTurboGameType'.static.StaticIsHighDifficulty(Self))
    {
        bOnlyProjectileAttackWhenGrounded = true;
        bTriggerGetOutOfTheWayOfShot = false;
    }
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (Role == ROLE_Authority)
	{
		class'PawnHelper'.static.TakeDamage(Self, Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex, AfflictionData);
	}

	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);

    if (Role == ROLE_Authority)
    {
        class'PawnHelper'.static.PostTakeDamage(Self, Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex, AfflictionData);

        if (Damage > 70)
        {
            NextAimHitTime = Level.TimeSeconds + AimHitTimeDurtation;
        }
    }
}

function TakeFireDamage(int Damage, pawn DamageInstigator)
{
    class'PawnHelper'.static.TakeFireDamage(Self, Damage, DamageInstigator, AfflictionData);
}

function bool MeleeDamageTarget(int HitDamage, vector PushDirection)
{
    return class'PawnHelper'.static.MeleeDamageTarget(Self, HitDamage, PushDirection, AfflictionData);
}

simulated function Tick(float DeltaTime)
{
    class'PawnHelper'.static.PreTickAfflictionData(Self, DeltaTime, self, AfflictionData);

    Super.Tick(DeltaTime);

    class'PawnHelper'.static.TickAfflictionData(Self, DeltaTime, self, AfflictionData);

    if(bSTUNNED && bUnstunTimeReady && UnstunTime < Level.TimeSeconds)
    {
        bSTUNNED = false;
        bUnstunTimeReady = false;
    }
}

function float NumPlayersHealthModifer()
{
    return class'PawnHelper'.static.GetBodyHealthModifier(self, Level);
}

function float NumPlayersHeadHealthModifer()
{
    return class'PawnHelper'.static.GetHeadHealthModifier(self, Level);
}

simulated function float GetOriginalGroundSpeed()
{
    return class'PawnHelper'.static.GetOriginalGroundSpeed(self, AfflictionData);
}

function PlayDirectionalHit(Vector HitLoc)
{
    local int LastStunCount;

    LastStunCount = StunsRemaining;

    if(class'PawnHelper'.static.ShouldPlayHit(self, AfflictionData))
        Super.PlayDirectionalHit(HitLoc);

    if(LastStunCount != StunsRemaining)
    {
        UnstunTime = Level.TimeSeconds + StunTime;
        bUnstunTimeReady = true;
    }
}

simulated function SetBurningBehavior()
{
    class'PawnHelper'.static.SetBurningBehavior(self, AfflictionData);
}

simulated function UnSetBurningBehavior()
{
    class'PawnHelper'.static.UnSetBurningBehavior(self, AfflictionData);
}

simulated function SetZappedBehavior()
{
    class'PawnHelper'.static.SetZappedBehavior(self, AfflictionData);
}

simulated function UnSetZappedBehavior()
{
    class'PawnHelper'.static.UnSetZappedBehavior(self, AfflictionData);
}

simulated function ZombieCrispUp()
{
}

simulated function Timer()
{
}

function RangedAttack(Actor A)
{
    local float TargetDistance;

	if (bShotAnim)
    {
		return;
    }

	if (Physics == PHYS_Swimming)
	{
		SetAnimAction('Claw');
		bShotAnim = true;
        return;
	}

	if (VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
	{
		bShotAnim = true;
		SetAnimAction('Claw');
        
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
        return;
	}

    if (bDecapitated || bZapped || bHarpoonStunned)
    {
        return;
    }

    if (KFDoorMover(A) == None)
    {
        if (bOnlyProjectileAttackWhenGrounded && Physics != PHYS_Walking)
        {
            return;
        }

        TargetDistance = VSize(A.Location - Location);
        if (TargetDistance >= ProjectileMaxRange || (!Region.Zone.bDistanceFog && TargetDistance >= Region.Zone.DistanceFogEnd * 0.8f))
        {
            return;
        }
    }

    bShotAnim = true;
    SetAnimAction('ShootBurns');

    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);

    NextFireProjectileTime = Level.TimeSeconds + ProjectileFireInterval + (FRand() * ProjectileIntervalVariance);
}

final function bool CanPerformAdvancedAim()
{
    if (Controller != None && Controller.Target != None && Controller.Target.Physics == PHYS_Falling)
    {
        return false;
    }

    return Level.TimeSeconds > NextAimHitTime;
}

function SpawnTwoShots()
{
	local vector X, Y, Z, FireStart;
	local rotator FireRotation;
    local KFMonster NearbyMonster;

	if (Controller != None && KFDoorMover(Controller.Target) != None)
	{
		Controller.Target.TakeDamage(22, Self, Location, vect(0,0,0), class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation, X, Y, Z);
	FireStart = GetBoneCoords('Barrel').Origin;
	HuskFireProjClass = Class'HuskFireProjectile';

	if (!SavedFireProperties.bInitialized || CanPerformAdvancedAim() != SavedFireProperties.bTrySplash)
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = HuskFireProjClass;
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 65535;
		SavedFireProperties.bTossed = false;
		SavedFireProperties.bInstantHit = false;
		SavedFireProperties.bInitialized = true;
        
        //These can now be made worse by shooting the husk right before it fires.
		SavedFireProperties.bTrySplash = CanPerformAdvancedAim();
		SavedFireProperties.bLeadTarget = SavedFireProperties.bTrySplash;
	}

    ToggleAuxCollision(false);

	FireRotation = Controller.AdjustAim(SavedFireProperties, FireStart, 600);

    if (bTriggerGetOutOfTheWayOfShot)
    {
        foreach CollidingActors(class'KFMonster', NearbyMonster, 640.f)
        {
            if (NearbyMonster == Self || NearbyMonster.Health <= 0 || KFMonsterController(NearbyMonster.Controller) == None)
            {
                continue;
            }

            if (PointDistToLine(NearbyMonster.Location, Vector(FireRotation), FireStart) < 75)
            {
                KFMonsterController(NearbyMonster.Controller).GetOutOfTheWayOfShot(Vector(FireRotation), FireStart);
            }
        }
    }

    Spawn(HuskFireProjClass,,, FireStart, FireRotation);

	// Turn extra collision back on
	ToggleAuxCollision(true);
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    class'PawnHelper'.static.MonsterDied(Self, AfflictionData);

    Super.PlayDying(DamageType, HitLoc);
}

state ZombieDying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack, SpawnTwoShots;

    simulated function BeginState()
    {
        class'PawnHelper'.static.MonsterDied(Self, AfflictionData);
        Super.BeginState();
    }
}

simulated event SetHeadScale(float NewScale)
{
	HeadScale = NewScale;
    class'PawnHelper'.static.AdjustHeadScale(Self, NewScale);
	SetBoneScale(4, NewScale, 'head');
}

defaultproperties
{
    ProjectileIntervalVariance=2.f
    ProjectileMaxRange=65535.f
    bOnlyProjectileAttackWhenGrounded=false
    bTriggerGetOutOfTheWayOfShot=true

    AimHitTimeDurtation=1.f

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonSpeedModifier=0.2f //Slower for now to make the buggy movement look a little funnier.
    End Object

    AfflictionData=(Burn=None,Zap=AfflictionZap'ZapAffliction',Harpoon=AfflictionHarpoon'HarpoonAffliction')
}
