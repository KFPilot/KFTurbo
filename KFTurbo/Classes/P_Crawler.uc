//Killing Floor Turbo P_Crawler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Crawler extends ZombieCrawler DependsOn(PawnHelper);

var PawnHelper.AfflictionData AfflictionData;

var bool bUnstunTimeReady;
var float UnstunTime;

var int MidAirAttackCounter;

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
    //Prevent too many hits in a row mid-air.
    if (Physics == PHYS_Falling)
    {
        if (MidAirAttackCounter <= 0)
        {
            return false;
        }

        MidAirAttackCounter--;
    }

    return class'PawnHelper'.static.MeleeDamageTarget(Self, HitDamage, PushDirection, AfflictionData);
}

event Landed(vector HitNormal)
{
    MidAirAttackCounter = default.MidAirAttackCounter;

    Super.Landed(HitNormal);
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
    //BurnRatio = 0.f;
}

simulated function UnSetBurningBehavior()
{
    class'PawnHelper'.static.UnSetBurningBehavior(self, AfflictionData);
    //BurnRatio = 0.f;
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

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonSpeedModifier=0.5f
    End Object

    AfflictionData=(Burn=AfflictionBurn'BurnAffliction',Zap=AfflictionZap'ZapAffliction',Harpoon=AfflictionHarpoon'HarpoonAffliction')
}
