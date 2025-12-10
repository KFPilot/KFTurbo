//Killing Floor Turbo P_Siren
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Siren extends MonsterSiren;

var bool bUnstunTimeReady;
var float UnstunTime;

var float ScreamAftershockDelay;
var float ScreamAftershockTime;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

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

simulated function HurtRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
    //HurtRadius uses instigator??? Update this so Sirens correctly disintegrate projectiles.
    local Pawn PreviousInstigator;
    PreviousInstigator = Instigator;
    Instigator = Self;
    Super.HurtRadius(DamageAmount, DamageRadius, DamageType, Momentum, HitLocation);
    Instigator = PreviousInstigator;
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

defaultproperties
{
    ScreamDamageType=Class'P_SirenScream_DT'

    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
        BurnSkinIndexList=(1)
    End Object
    MonsterBurnAffliction=CoreMonsterAffliction'BurnAffliction'

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object
    MonsterZapAffliction=CoreMonsterAffliction'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonStunnedSpeedModifier=0.5f
    End Object
    MonsterHarpoonAffliction=CoreMonsterAffliction'HarpoonAffliction'

    ScreamAftershockDelay=0.15f
    ScreamAftershockTime=-1.f
}
