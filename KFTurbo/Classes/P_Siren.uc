//Killing Floor Turbo P_Siren
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Siren extends MonsterSiren DependsOn(PawnHelper);

var PawnHelper.AfflictionData AfflictionData;

var bool bUnstunTimeReady;
var float UnstunTime;

var float ScreamAftershockDelay;
var float ScreamAftershockTime;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    class'PawnHelper'.static.InitializePawnHelper(self, AfflictionData);
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

    if (ScreamAftershockTime > 0.f && ScreamAftershockTime < Level.TimeSeconds)
    {
        PerformAftershock();
        ScreamAftershockTime = -1.f;
    }
}

simulated function AnimEnd(int Channel)
{
    local name  Sequence;
	local float Frame, Rate;
    
	GetAnimParams(1, Sequence, Frame, Rate);

    Super.AnimEnd(Channel);

    if (!bShotAnim || Sequence != 'Siren_Scream')
    {
        return;
    }
    
    //If the anim that ended was Siren_Scream, make sure we set this to false.
    bShotAnim = false;
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

	bUnstunTimeReady = class'PawnHelper'.static.UpdateStunProperties(self, LastStunCount, UnstunTime, bUnstunTimeReady);
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
    class'PawnHelper'.static.ZombieCrispUp(self);
}

simulated function Timer()
{
    if (BurnDown > 0)
    {
        TakeFireDamage(LastBurnDamage + rand(2) + 3 , LastDamagedBy);
        SetTimer(1.0,false);
    }
    else
    {
        UnSetBurningBehavior();

        RemoveFlamingEffects();
        StopBurnFX();
        SetTimer(0, false);
    }
}

function RangedAttack(Actor A)
{
    local int LastFireTime;
    local float Dist;

    if ( bShotAnim )
    {
        return;
    }

    Dist = VSize(A.Location - Location);

    if ( Physics == PHYS_Swimming )
    {
        SetAnimAction('Claw');
        bShotAnim = true;
        LastFireTime = Level.TimeSeconds;
    }
    else if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        bShotAnim = true;
        LastFireTime = Level.TimeSeconds;
        SetAnimAction('Claw');
        //PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else if( Dist <= ScreamRadius && !bDecapitated && !bZapped && !bHarpoonStunned)
    {
        bShotAnim=true;
        SetAnimAction('Siren_Scream');
        // Only stop moving if we are close
        if( Dist < ScreamRadius * 0.25 )
        {
            Controller.bPreparingMove = true;
            Acceleration = vect(0,0,0);
        }
        else
        {
            Acceleration = AccelRate * Normal(A.Location - Location);
        }
    }
}

simulated function SpawnTwoShots()
{
    if ( bDecapitated || bZapped || bHarpoonStunned )
    {
        return;
    }

    DoShakeEffect();

    if ( Role != ROLE_Authority )
    {
        return;
    }

    if ( Controller != None && KFDoorMover(Controller.Target) != None )
    {
        Controller.Target.TakeDamage(ScreamDamage*0.6, Self, Location, vect(0,0,0), ScreamDamageType);
    }
    else
    {
        HurtRadius(ScreamDamage, ScreamRadius, ScreamDamageType, ScreamForce, Location);
    }

    ScreamAftershockTime = Level.TimeSeconds + ScreamAftershockDelay;
}

//Make it a little more likely siren screams actually disintegrate projectiles.
function PerformAftershock()
{
	local Projectile Projectile;
	local float DamageScale, Distance;
	local vector Direction;

    if( bDecapitated || bZapped || bHarpoonStunned )
    {
        return;
    }

	foreach VisibleCollidingActors(class'Projectile', Projectile, ScreamRadius, Location)
	{
        Direction = Projectile.Location - Location;
        Distance = FMax(1, VSize(Direction));
        Direction = Direction / Distance;
        DamageScale = 1.f - FMax(0, (Distance - Projectile.CollisionRadius) / ScreamRadius);

        if (DamageScale <= 0.f)
        {
            continue;
        }

        Projectile.TakeDamage(DamageScale * ScreamDamage, Instigator, Projectile.Location - 0.5 * (Projectile.CollisionHeight + Projectile.CollisionRadius) * Direction, (DamageScale * ScreamForce * Direction), ScreamDamageType);
	}
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    //HurtRadius uses instigator??? Update this so Sirens correctly disintegrate projectiles.
    local Pawn PreviousInstigator;
    PreviousInstigator = Instigator;
    Instigator = Self;
    Super.HurtRadius(DamageAmount, DamageRadius, DamageType, Momentum, HitLocation);
    Instigator = PreviousInstigator;
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    class'PawnHelper'.static.MonsterDied(Self, AfflictionData);

    Super.PlayDying(DamageType, HitLoc);
}

simulated function CleanUpScreamEffect()
{
    local int Index;
    local SirenScream ScreamEffect;
    for (Index = 0; Index < Attached.Length; Index++)
    {
        ScreamEffect = SirenScream(Attached[Index]);

        if (ScreamEffect != None)
        {
            ScreamEffect.Kill();
        }
    }
}

state ZombieDying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack, SpawnTwoShots, PerformAftershock;

    simulated function BeginState()
    {
        CleanUpScreamEffect();
        class'PawnHelper'.static.MonsterDied(Self, AfflictionData);

        Super.BeginState();
    }

    simulated function Timer()
    {
        CleanUpScreamEffect();

        Super.Timer();
    }
}

simulated function Destroyed()
{
    CleanUpScreamEffect();

    Super.Destroyed();
}

simulated event SetHeadScale(float NewScale)
{
	HeadScale = NewScale;
    class'PawnHelper'.static.AdjustHeadScale(Self, NewScale);
	SetBoneScale(4, NewScale, 'head');
}

defaultproperties
{
    ScreamDamageType=Class'P_SirenScream_DT'

    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonSpeedModifier=0.5f
    End Object

    AfflictionData=(Burn=AfflictionBurn'BurnAffliction',Zap=AfflictionZap'ZapAffliction',Harpoon=AfflictionHarpoon'HarpoonAffliction')

    ScreamAftershockDelay=0.15f
    ScreamAftershockTime=-1.f
}
