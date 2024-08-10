class P_Scrake extends ZombieScrake
    abstract
    DependsOn(PawnHelper);

var PawnHelper.AfflictionData AfflictionData;

var bool bUnstunTimeReady;
var float UnstunTime;

var AI_Scrake ProAI;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    ProAI = AI_Scrake(Controller);

    class'PawnHelper'.static.InitializePawnHelper(self, AfflictionData);
}

function TryEnterRunningState()
{
    if (bShotAnim || bDecapitated)
    {
        return;
    }

    if ( Level.Game.GameDifficulty < 5.0 )
    {
        if ( float(Health)/HealthMax < 0.5 )
        {
            GoToState('RunningState');
        }
    }
    else
    {
        if ( float(Health)/HealthMax < 0.75 )
        {
            GoToState('RunningState');
        }
    }
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (Role == ROLE_Authority)
	{
		class'PawnHelper'.static.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex, AfflictionData);

        if ( Level.Game.GameDifficulty >= 5.0  && (class<DamTypeFlareProjectileImpact>(damageType) != none || class<DamTypeFlareRevolver>(damageType) != none) )
        {
            Damage *= 0.75;
        }
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
    class'PawnHelper'.static.PreTickAfflictionData(DeltaTime, self, AfflictionData);
    
    Super.Tick(DeltaTime);

    class'PawnHelper'.static.TickAfflictionData(DeltaTime, self, AfflictionData);

    TickStunTime();
}

simulated function TickStunTime()
{
    if(bSTUNNED && bUnstunTimeReady && UnstunTime < Level.TimeSeconds)
    {
        bSTUNNED = false;
        bUnstunTimeReady = false;

        if (CanAttack(Controller.Enemy))
        {
            GotoState('SawingLoop');
        }
        else
        {
            TryEnterRunningState();
        }
    }
}

simulated function AnimEnd(int Channel)
{
    local name  Sequence;
	local float Frame, Rate;
    
	GetAnimParams(0, Sequence, Frame, Rate);

    Super.AnimEnd(Channel);

    if (Sequence != 'KnockDown')
    {
        return;
    }

    TryEnterRunningState();
}

simulated function PostNetReceive()
{
    if (!bHarpoonStunned)
    {
        if (bCharging)
        {
            MovementAnims[0]='ChargeF';
        }
        else
        {
            MovementAnims[0]=default.MovementAnims[0];
        }
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
    return Super.GetOriginalGroundSpeed() * class'PawnHelper'.static.GetSpeedMultiplier(AfflictionData);
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	if( Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims )
    {
		return;
    }

    if (class'PawnHelper'.static.ShouldPlayHit(Self, AfflictionData))
    {
        if((Level.Game.GameDifficulty < 5.0 || StunsRemaining != 0) && Damage >= 150)
        {
            PlayDirectionalHit(HitLocation);
        }

        LastPainAnim = Level.TimeSeconds;
    }

	if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
		return;

	LastPainSound = Level.TimeSeconds;
	PlaySound(HitSound[0], SLOT_Pain,1.25,,400);
}

function PlayDirectionalHit(Vector HitLoc)
{
    local int LastStunCount;
    LastStunCount = StunsRemaining;

    if(!bUnstunTimeReady)
    {
        Super.PlayDirectionalHit(HitLoc);
    }

	bUnstunTimeReady = class'PawnHelper'.static.UpdateStunProperties(self, LastStunCount, UnstunTime, bUnstunTimeReady);
}

simulated function SetBurningBehavior()
{
    class'PawnHelper'.static.SetBurningBehavior(self, AfflictionData);

    if( Level.NetMode != NM_DedicatedServer && !bHarpoonStunned)
        PostNetReceive();
}

simulated function UnSetBurningBehavior()
{
    class'PawnHelper'.static.UnSetBurningBehavior(self, AfflictionData);

    if (!IsInState('SawingLoop'))
    {
        if (CanAttack(Controller.Enemy))
        {
            GoToState('SawingLoop');
        }
        else
        {
            TryEnterRunningState();
        }
    }

    if( Level.NetMode != NM_DedicatedServer )
        PostNetReceive();    
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

State SawingLoop
{
    function AnimEnd( int Channel )
    {
        Super(KFMonster).AnimEnd(Channel);

        if( Controller!=None && Controller.Enemy!=None && CanAttack(Controller.Enemy))
            RangedAttack(Controller.Enemy);
    }
}

simulated function SetZappedBehavior()
{
    class'PawnHelper'.static.SetZappedBehavior(self, AfflictionData);
}

simulated function UnSetZappedBehavior()
{
    class'PawnHelper'.static.UnSetZappedBehavior(self, AfflictionData);
}


state RunningState
{
    simulated function Tick(float DeltaTime)
    {
        Global.Tick(DeltaTime);

        //Keep reminding us how fast we're supposed to be. For some reason we forget to.
        SetGroundSpeed(GetOriginalGroundSpeed());
    }

    simulated function SetBurningBehavior()
    {
		Global.SetBurningBehavior();
    }

    simulated function UnSetBurningBehavior()
    {
		Global.UnSetBurningBehavior();
    }

    simulated function SetZappedBehavior()
    {
		Global.SetZappedBehavior();
    }

    simulated function UnSetZappedBehavior()
    {
		Global.UnSetZappedBehavior();
    }

    simulated function float GetOriginalGroundSpeed()
    {
        return Global.GetOriginalGroundSpeed() * 3.5f;
    }

	function BeginState()
	{
		if(bZapped)
        {
            GoToState('');
        }
        else
        {
    		SetGroundSpeed(GetOriginalGroundSpeed());
    		bCharging = true;
    		if( Level.NetMode!=NM_DedicatedServer )
    			PostNetReceive();

    		NetUpdateTime = Level.TimeSeconds - 1;
		}
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

defaultproperties
{
    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonSpeedModifier=0.75f
    End Object

    AfflictionData=(Burn=AfflictionBurn'BurnAffliction',Zap=AfflictionZap'ZapAffliction',Harpoon=AfflictionHarpoon'HarpoonAffliction')

    EventClasses(0)="KFTurbo.P_Scrake_DEF"
    ControllerClass=Class'KFTurbo.AI_Scrake'
}
