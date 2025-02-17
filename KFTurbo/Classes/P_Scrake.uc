//Killing Floor Turbo P_Scrake
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Scrake extends ZombieScrake
    abstract
    DependsOn(PawnHelper);

var PawnHelper.AfflictionData AfflictionData;

var bool bUnstunTimeReady;
var float UnstunTime;

var AI_Scrake ProAI;

var float HealthRageThreshold;

simulated function PostBeginPlay()
{
    if (Level.Game != None && !bDiffAdjusted)
    {
        if (Level.Game.GameDifficulty < 5.0)
        {
            HealthRageThreshold = 0.5f;
        }
        else
        {
            HealthRageThreshold = 0.75f;
        }
    }

    Super.PostBeginPlay();
    
    ProAI = AI_Scrake(Controller);

    class'PawnHelper'.static.InitializePawnHelper(self, AfflictionData);
}

function bool ShouldRage()
{
    if (HealthRageThreshold <= 0.f)
    {
        return (float(Health) / HealthMax) < 0.75f;
    }
    
    return (float(Health) / HealthMax) < HealthRageThreshold;
}

function TryEnterRunningState()
{
    if (bShotAnim || bDecapitated)
    {
        return;
    }

    if ( ShouldRage() )
    {
        GoToState('RunningState');
    }
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{	
    local bool bIsHeadShot;
	local PlayerController PC;
	local KFSteamStatsAndAchievements Stats;

	if (Role == ROLE_Authority)
	{
		class'PawnHelper'.static.TakeDamage(Self, Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex, AfflictionData);
	}

	bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), 1.0);

    if ( Level.Game.GameDifficulty >= 5.0  && (class<DamTypeFlareProjectileImpact>(DamageType) != none || class<DamTypeFlareRevolver>(DamageType) != none) )
    {
        Damage *= 0.75f;
    }

	if ( Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && (class<DamTypeCrossbow>(DamageType) != none || class<DamTypeCrossbowHeadShot>(DamageType) != none) )
	{
		Damage *= 0.5f;
	}

	Super(KFMonster).TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);

	if (!IsInState('SawingLoop') && !IsInState('RunningState') && ShouldRage())
    {
		RangedAttack(InstigatedBy);
    }

    if( class<DamTypeDBShotgun>(DamageType) != None )
    {
    	PC = PlayerController( InstigatedBy.Controller );
    	if( PC != none )
    	{
    	    Stats = KFSteamStatsAndAchievements( PC.SteamStatsAndAchievements );
    	    if( Stats != none )
    	    {
    	        Stats.CheckAndSetAchievementComplete( Stats.KFACHIEVEMENT_PushScrakeSPJ );
    	    }
    	}
    }

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

function OldPlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> DamageType, vector Momentum, optional int HitIndex)
{    
    Super.OldPlayHit(Damage, InstigatedBy, HitLocation, DamageType, Momentum, HitIndex);
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

    if (Role == ROLE_Authority && Controller != None && !IsInState('SawingLoop'))
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

function RangedAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
    {
		return;
    }
	else if (CanAttack(A))
	{
		bShotAnim = true;
		SetAnimAction(MeleeAnims[Rand(2)]);
		CurrentDamType = ZombieDamType[0];
		GoToState('SawingLoop');
	}

    TryEnterRunningState();
}

State SawingLoop
{
	function BeginState()
	{
        local float ChargeChance, RagingChargeChance;

        if( Level.Game.GameDifficulty < 2.0 )
        {
            ChargeChance = 0.25;
            RagingChargeChance = 0.5;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ChargeChance = 0.5;
            RagingChargeChance = 0.70;
        }
        else if( Level.Game.GameDifficulty < 5.0 )
        {
            ChargeChance = 0.65;
            RagingChargeChance = 0.85;
        }
        else
        {
            ChargeChance = 0.95;
            RagingChargeChance = 1.0;
        }

        if ((ShouldRage() && FRand() <= RagingChargeChance) || FRand() <= ChargeChance)
		{
            SetGroundSpeed(OriginalGroundSpeed * AttackChargeRate);
    		bCharging = true;

    		if (Level.NetMode != NM_DedicatedServer)
            {
    			PostNetReceive();
            }

    		NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

    function AnimEnd( int Channel )
    {
        Super(KFMonster).AnimEnd(Channel);

        if( Controller!=None && Controller.Enemy!=None && CanAttack(Controller.Enemy))
        {
            RangedAttack(Controller.Enemy);
        }
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

simulated event SetHeadScale(float NewScale)
{
	HeadScale = NewScale;
    class'PawnHelper'.static.AdjustHeadScale(Self, NewScale);
	SetBoneScale(4, NewScale, 'head');
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

    HealthRageThreshold=0.f
}
