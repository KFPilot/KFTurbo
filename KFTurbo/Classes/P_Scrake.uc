//Killing Floor Turbo P_Scrake
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Scrake extends MonsterScrake
    abstract
    DependsOn(PawnHelper);

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

	bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), 1.0);

    if ( Level.Game.GameDifficulty >= 5.0  && (class<DamTypeFlareProjectileImpact>(DamageType) != none || class<DamTypeFlareRevolver>(DamageType) != none) )
    {
        Damage *= 0.75f;
    }

	if ( Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && (class<DamTypeCrossbow>(DamageType) != none || class<DamTypeCrossbowHeadShot>(DamageType) != none) )
	{
		Damage *= 0.5f;
	}

	Super(CoreMonster).TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);

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

/*
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
*/

simulated function SetBurningBehavior()
{
    Super.SetBurningBehavior();

    if (Level.NetMode != NM_DedicatedServer && !bHarpoonStunned)
    {
        PostNetReceive();
    }
}

simulated function UnSetBurningBehavior()
{
    Super.SetBurningBehavior();

    if (Level.NetMode != NM_DedicatedServer)
    {
        PostNetReceive();
    }    
}

function RangedAttack(Actor Target)
{
	if (bShotAnim || Physics == PHYS_Swimming)
    {
		return;
    }
	
    if (CanAttack(Target) && DoesAfflictionAllowAttack(Target, false))
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
        Super(CoreMonster).AnimEnd(Channel);

        if( Controller!=None && Controller.Enemy!=None && CanAttack(Controller.Enemy))
        {
            RangedAttack(Controller.Enemy);
        }
    }
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

defaultproperties
{
    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object
    MonsterBurnAffliction=CoreMonsterAffliction'BurnAffliction'

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object
    MonsterZapAffliction=CoreMonsterAffliction'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonStunnedSpeedModifier=0.75f
    End Object
    MonsterHarpoonAffliction=CoreMonsterAffliction'HarpoonAffliction'

    EventClasses(0)="KFTurbo.P_Scrake_DEF"
    ControllerClass=Class'KFTurbo.AI_Scrake'

    HealthRageThreshold=0.f
}
