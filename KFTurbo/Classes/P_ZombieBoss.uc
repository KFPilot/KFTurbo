//Killing Floor Turbo P_ZombieBoss
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_ZombieBoss extends MonsterBoss
    DependsOn(PawnHelper);

var AI_ZombieBoss ZombieBossAI;

var float LastCommandoSpotTime;
var float CommandoSpotDuration;

var int SneakFailureCount;
var int ChargeDurationIncreaseFailureCount; //How many failures (when trying to cloak charge) do we need before we start increasing charge duration?
var int ChargeSpeedIncreaseFailureCount; //How many failures (when trying to cloak charge) do we need before we start increasing charge speed?

var float BossHealthMax, LowestHealth;

replication
{
	reliable if (Role == ROLE_Authority)
		BossHealthMax, LowestHealth;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

	ZombieBossAI = AI_ZombieBoss(Controller);

	if (Role == ROLE_Authority)
	{
		BossHealthMax = HealthMax;
		LowestHealth = HealthMax;
	}
}

simulated function PostNetBeginPlay()
{
	local TurboHUDWaveInfo WaveInfoOverlay;
	Super.PostNetBeginPlay();

	if (Level.GetLocalPlayerController() != None)
	{
		WaveInfoOverlay = class'TurboHUDWaveInfo'.static.FindWaveInfoOverlay(Level.GetLocalPlayerController());

		if (WaveInfoOverlay != None)
		{
			WaveInfoOverlay.RegisterZombieBoss(Self);
		}
	}
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	local class<KFWeaponDamageType> WeaponDamageType;
	WeaponDamageType = class<KFWeaponDamageType>(DamageType);

	//M99 is very weak compared to Crossbow. Buff the damage.
	if (WeaponDamageType != None && (class<DamTypeM99SniperRifle>(damageType) != None || class<DamTypeM99HeadShot>(damageType) != None))
    {
    	Damage = int(float(Damage) * 1.5f);
    }

	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);

	//Did we get hit by something that wasn't just an explosion and from very far away? Long distance charge!
	if (WeaponDamageType != None && ZombieBossAI != None && !WeaponDamageType.default.bIsExplosive && class<DamTypeBurned>(WeaponDamageType) == None)
	{
		if (ShouldChargeFromDamage() && ChargeDamage > 100 && (FRand() > 0.5f) && ZombieBossAI.ShouldLongDistanceCharge(InstigatedBy))
		{
			SetAnimAction('transition');
			ChargeDamage = 0;
			LastForceChargeTime = Level.TimeSeconds;
			ZombieBossAI.StrafingAbility = 10.f;
			ZombieBossAI.bAdvancedTactics = true;
			GoToState('LongDistanceSneakAround');
		}
	}

    if (Role == ROLE_Authority)
    { 
		if (Health < LowestHealth)
		{
			LowestHealth = Health;
		}
	}
}

//Stop boss cinematic and end game from occurring if multiple bosses are alive.
function Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local array<Monster> MonsterPawnList;
	MonsterPawnList = class'TurboGameplayHelper'.static.GetMonsterPawnList(Level, class'MonsterBoss');

	//If we were the last one alive, do the cinematic.
	if (MonsterPawnList.Length == 0 || (MonsterPawnList.Length == 1 && MonsterPawnList[0] == Self))
	{
		Super.Died(Killer, DamageType, HitLocation);
		return;
	}

	Super(KFMonster).Died(Killer, DamageType, HitLocation);
}

function ClawDamageTarget()
{
	if (Controller == None)
	{
		return;
	}

	Super.ClawDamageTarget();
}

simulated function Tick(float DeltaTime)
{
    TickCloak(DeltaTime);

    Super.Tick(DeltaTime);
}

simulated function SpotBoss()
{
	LastCommandoSpotTime = Level.TimeSeconds;
}

//We do our own cloak check. Setting LastCheckTimes means ZombieBoss:Tick will never perform its cloak behaviour.
simulated function TickCloak(float DeltaTime)
{
    local bool bNewSpotted;

    if( Level.NetMode == NM_DedicatedServer )
	{
		bSpotted = bCloaked && (LastCommandoSpotTime + CommandoSpotDuration > Level.TimeSeconds);
		return;
	}

    if (!bCloaked || Level.TimeSeconds < LastCheckTimes)
    {
        return;
    }

    LastCheckTimes = Level.TimeSeconds + 0.25f;

    bNewSpotted = bCloaked && LastCommandoSpotTime + CommandoSpotDuration > Level.TimeSeconds;

    if (bNewSpotted != bSpotted)
    {
        bSpotted = bNewSpotted;
        
        if (!bSpotted)
        {
            bUnlit = false;
        }

        CloakBoss();
    }
}

state KnockDown
{
	function bool ShouldChargeFromDamage()
	{
		return false;
	}

Begin:
	if ( Health > 0 )
	{
		Sleep(GetAnimDuration('KnockDown'));
		CloakBoss();
		PlaySound(HelpMeSound, SLOT_Misc, 2.0,,500.0);

		if ( KFGameType(Level.Game).FinalSquadNum == SyringeCount )
		{
		   KFGameType(Level.Game).AddBossBuddySquad();
		}

		GotoState('Escaping');
	}
	else
	{
	   GotoState('');
	}
}

state SneakAround
{
	function Tick( float Delta )
	{
    	if( Role == ROLE_Authority && bShotAnim)
    	{
    		if( bChargingPlayer )
    		{
                bChargingPlayer = false;

        		if( Level.NetMode!=NM_DedicatedServer )
				{
        			PostNetReceive();
				}
    		}

            SetGroundSpeed(GetOriginalGroundSpeed());
        }
        else
        {
    		if( !bChargingPlayer )
    		{
                bChargingPlayer = true;

        		if( Level.NetMode!=NM_DedicatedServer )
				{
        			PostNetReceive();
				}
    		}

			SetGroundSpeed(OriginalGroundSpeed * GetSneakSpeedMultiplier());
        }

		Global.Tick(Delta);
	}

Begin:
	CloakBoss();
	While( true )
	{
		Sleep(0.5);

		if( Level.TimeSeconds - SneakStartTime > GetSneakDuration() )
		{
			OnSneakFailed();
            GoToState('');
		}

		if( !bCloaked && !bShotAnim )
		{
			CloakBoss();
		}

		if( !Controller.IsInState('ZombieHunt') && !Controller.IsInState('WaitForAnim') )
		{
        	Controller.GoToState('ZombieHunt');
        }
	}
}

state LongDistanceSneakAround extends SneakAround
{
	function BeginState()
	{
		Super.BeginState();
	}
	
	function EndState()
	{
		ZombieBossAI.bAdvancedTactics = ZombieBossAI.default.bAdvancedTactics;
		ZombieBossAI.StrafingAbility = ZombieBossAI.default.StrafingAbility;
		Super.EndState();
	}

	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);
		ZombieBossAI.StrafingAbility = FMax(ZombieBossAI.StrafingAbility - (DeltaTime * 2.f), ZombieBossAI.default.StrafingAbility);
	}

	function float GetSneakDuration()
	{
		return Global.GetSneakDuration() * 2.f;
	}
}

function float GetSneakDuration()
{
	return 10.f * GetSneakDurationMultiplier();
}

function float GetSneakDurationMultiplier()
{
	return 1.f + (float(Max(SneakFailureCount - ChargeDurationIncreaseFailureCount, 0)) * 0.25f);
}

function float GetSneakSpeedMultiplier()
{
	if (bZapped)
	{
		return 1.5f + (float(Max(SneakFailureCount - ChargeSpeedIncreaseFailureCount, 0)) * 0.1f);
	}
	
	return 2.5f + (float(Max(SneakFailureCount - ChargeSpeedIncreaseFailureCount, 0)) * 0.1f);
}

function OnSneakFailed()
{
	SneakFailureCount++;
}

defaultproperties
{
	bAlwaysRelevant=true

    CommandoSpotDuration=2.f

	SneakFailureCount=0
	ChargeDurationIncreaseFailureCount=1
	ChargeSpeedIncreaseFailureCount=4

    //NOTE: Affliction move speed modifiers are not used by the boss. They exist, but are not used.
    Begin Object Class=AfflictionBurn Name=BurnAffliction
		FirePriorityList=()
    End Object
    MonsterBurnAffliction=CoreMonsterAffliction'BurnAffliction'

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeDelay=2.f
        ZapDischargeRate=0.25f
    End Object
    MonsterZapAffliction=CoreMonsterAffliction'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
	HarpoonStunnedSpeedModifier=1.f
    End Object
    MonsterHarpoonAffliction=CoreMonsterAffliction'HarpoonAffliction'

	CloakedSkinList(0) = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun'
	CloakedSkinList(1) = Shader'KF_Specimens_Trip_T.patriarch_invisible'
    HelpMeSound=Sound'KF_EnemiesFinalSnd.Patriarch.Kev_SaveMe'

	ControllerClass=class'KFTurbo.AI_ZombieBoss'
}
