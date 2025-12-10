//Killing Floor Turbo P_Crawler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Crawler extends MonsterCrawler;

var int MidAirAttackCounter;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);
}

function bool MeleeDamageTarget(int HitDamage, vector PushDirection)
{
    //Prevent too many hits in a row mid-air.
    if (Physics == PHYS_Falling)
    {
        if (MidAirAttackCounter <= 0)
        {
            return false;
        }

        MidAirAttackCounter--;
    }

    Super.MeleeDamageTarget(HitDamage, PushDirection);
}

function Bump(actor Other)
{
    local KFHumanPawn HitPawn;
    local float Damage;
    if (!bPouncing)
    {
        return;
    }

    HitPawn = KFHumanPawn(Other);

    if (HitPawn == None || HitPawn.Health <= 0)
    {
        return;
    }

    if (Physics == PHYS_Falling)
    {
        MidAirAttackCounter--;
    }
    
    Damage = (MeleeDamage - (MeleeDamage * 0.05f)) + (MeleeDamage * (FRand() * 0.1f));
	ApplyMeleeDamageTargetAfflictionModifiers(Damage);
    HitPawn.TakeDamage(Damage, Self, Location, Velocity, class'KFmod.ZombieMeleeDamage');
    
    if (HitPawn.Health <= 0)
    {
        HitPawn.SpawnGibs(HitPawn.Rotation, 1);
    }

    bPouncing = false;
}

event Landed(vector HitNormal)
{
    MidAirAttackCounter = default.MidAirAttackCounter;

    Super.Landed(HitNormal);
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
}

defaultproperties
{
    DoubleJumpAnims(0)="ZombieSpring"
    DoubleJumpAnims(1)="ZombieSpring"
    DoubleJumpAnims(2)="ZombieSpring"
    DoubleJumpAnims(3)="ZombieSpring"
    DodgeAnims(0)="ZombieSpring"
    DodgeAnims(1)="ZombieSpring"
    DodgeAnims(2)="ZombieSpring"
    DodgeAnims(3)="ZombieSpring"

    MidAirAttackCounter=2

    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
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
}
