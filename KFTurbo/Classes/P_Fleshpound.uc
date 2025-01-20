//Killing Floor Turbo P_Fleshpound
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Fleshpound extends ZombieFleshpound
    abstract
    DependsOn(PawnHelper);

var PawnHelper.AfflictionData AfflictionData;

var(KFTurbo) bool bUnstunTimeReady;
var(KFTurbo) float UnstunTime;

var AI_Fleshpound ProAI;

simulated function PostNetBeginPlay()
{
	if (AvoidArea == None)
    {
        AvoidArea = Spawn(class'P_FleshPound_AvoidArea',self);
    }

	Super.PostNetBeginPlay();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	ProAI = AI_Fleshpound(Controller);

    class'PawnHelper'.static.InitializePawnHelper(self, AfflictionData);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	local int OldHealth;
	local Vector X,Y,Z;
	local bool bIsHeadShot;
	local float HeadShotCheckScale;
    local class<KFWeaponDamageType> WeaponDamageType;

	if (Role == ROLE_Authority)
	{
		class'PawnHelper'.static.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex, AfflictionData);
	}

    if (DamageType == class 'DamTypeVomit')
	{
		Damage = 0; // nulled
        Super(KFMonster).TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);

        if (Role == ROLE_Authority)
        {
            class'PawnHelper'.static.PostTakeDamage(Self, Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex, AfflictionData);
        }
        return;
	}

    WeaponDamageType = class<KFWeaponDamageType>(DamageType);

	GetAxes(Rotation, X,Y,Z);

	if( LastDamagedTime<Level.TimeSeconds )
    {
		TwoSecondDamageTotal = 0;
    }
	
    LastDamagedTime = Level.TimeSeconds + 2.f;
	OldHealth = Health;

    if (WeaponDamageType == None || !WeaponDamageType.default.bIsExplosive)
    {
        HeadShotCheckScale = 1.0;
        if( class<DamTypeMelee>(damageType) != none )
        {
            HeadShotCheckScale *= 1.25;
        }

        bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), HeadShotCheckScale);
        // Commando weapons don't get the damage reduction
		if (class'V_Commando'.static.IsPerkDamageType(WeaponDamageType))
        {
            // Do nothing
        }
		// Don't reduce the damage so much if its a high headshot damage weapon
        else if( (bIsHeadShot && WeaponDamageType.default.HeadShotDamageMult >= 1.5) || (class<DamTypeCrossbuzzsaw>(DamageType) != None))
		{
			Damage *= 0.75;
		}
		else if (class<DamTypeM99SniperRifle>(DamageType) != none)
		{
			Damage *= 0.525;
		}
		else if ( Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && class<DamTypeCrossbow>(DamageType) != none )
		{
			Damage *= 0.35; // was 0.3 in Balance Round 1, then 0.4 in Round 2, then 0.3 in Round 3/4, and 0.35 in Round 5
		}
		else
		{
			Damage *= 0.5;
		}
    }
    else if (WeaponDamageType != None && WeaponDamageType.default.bIsExplosive)
    {
        switch(DamageType)
        {
            case class'DamTypeFrag':
            case class'DamTypePipeBomb':
            case class'DamTypeMedicNade':
                Damage *= 2.0f;
                break;
            case class'DamTypeSeekerSixRocket':
                Damage *= 1.65f;
                break;
            default:
                Damage *= 1.25f;
                break;
        }
    }

	// Shut off his "Device" when dead
	if (Damage >= Health)
    {
		PostNetReceive();
    }

	Super(KFMonster).TakeDamage(Damage, instigatedBy, hitLocation, momentum, damageType,HitIndex) ;

	TwoSecondDamageTotal += OldHealth - Health; // Corrected issue where only the Base Health is counted toward the FP's Rage in Balance Round 6(second attempt)

	if (!bDecapitated && TwoSecondDamageTotal > RageDamageThreshold && !bChargingPlayer && !bZapped
        && (!(bCrispified && bBurnified) || bFrustrated))
    {
        StartCharging();
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
    class'PawnHelper'.static.PreTickAfflictionData(DeltaTime, self, AfflictionData);

    Super.Tick(DeltaTime);

    class'PawnHelper'.static.TickAfflictionData(DeltaTime, self, AfflictionData);

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
    local float BaseSpeed;

    BaseSpeed = class'PawnHelper'.static.GetOriginalGroundSpeed(self, AfflictionData);

    if (bFrustrated || bChargingPlayer)
    {
        return BaseSpeed * 2.3f;
    }

    return BaseSpeed;
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
    if( bFrustrated || bChargingPlayer )
    {
        return;
    }

    if(ProAI != None && ProAI.bForcedRage)
    {
        return;
    }

    class'PawnHelper'.static.SetBurningBehavior(self, AfflictionData);
}

simulated function UnSetBurningBehavior()
{
    class'PawnHelper'.static.UnSetBurningBehavior(self, AfflictionData);
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

simulated function SetZappedBehavior()
{
    if(ProAI != None && ProAI.bForcedRage)
        return;

    class'PawnHelper'.static.SetZappedBehavior(self, AfflictionData);
}

simulated function UnSetZappedBehavior()
{
    class'PawnHelper'.static.UnSetZappedBehavior(self, AfflictionData);
}

state RageCharging
{
Ignores StartCharging;

	function BeginState()
	{
        local float DifficultyModifier;

		if(bZapped && (ProAI == None || !ProAI.bForcedRage))
        {
            GoToState('');
        }
        else
        {
            bChargingPlayer = true;

    		if( Level.NetMode!=NM_DedicatedServer )
    			ClientChargingAnims();

            if(Level.Game.GameDifficulty < 2.0)
                DifficultyModifier = 0.85;
            else if(Level.Game.GameDifficulty < 4.0)
                DifficultyModifier = 1.0;
            else if(Level.Game.GameDifficulty < 5.0)
                DifficultyModifier = 1.25;
            else
                DifficultyModifier = 3.0;

        	if(ProAI != None && ProAI.bForcedRage)
        		DifficultyModifier *= 1000.f;

    		RageEndTime = (Level.TimeSeconds + 5 * DifficultyModifier) + (FRand() * 6 * DifficultyModifier);
    		NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

    function PlayDirectionalHit(Vector HitLoc)
    {
        if( !bShotAnim )
        {
            Global.PlayDirectionalHit(HitLoc);
        }
    }

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal,bWasEnemy;

		bWasEnemy = (Controller.Target==Controller.Enemy);
		RetVal = Super(ZombieFleshpoundBase).MeleeDamageTarget(hitdamage*1.75, pushdir*3);

		if(RetVal && bWasEnemy && ProAI != None && !ProAI.bForcedRage)
			GoToState('');
            
		return RetVal;
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
        HarpoonSpeedModifier=0.25f
    End Object

    AfflictionData=(Burn=AfflictionBurn'BurnAffliction',Zap=AfflictionZap'ZapAffliction',Harpoon=AfflictionHarpoon'HarpoonAffliction')

    EventClasses(0)="P_Fleshpound_DEF"
    ControllerClass=Class'KFTurbo.AI_Fleshpound'
}
