class P_ZombieBoss extends ZombieBoss
    DependsOn(PawnHelper);

var PawnHelper.AfflictionData AfflictionData;

var array<Material> CloakedSkinList;
var Sound HelpMeSound;

var float LastCommandoSpotTime;
var float CommandoSpotDuration;

var int SneakFailureCount;
var int ChargeDurationIncreaseFailureCount; //How many failures (when trying to cloak charge) do we need before we start increasing charge duration?
var int ChargeSpeedIncreaseFailureCount; //How many failures (when trying to cloak charge) do we need before we start increasing charge speed?

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

     class'PawnHelper'.static.InitializePawnHelper(self, AfflictionData);
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (Role == ROLE_Authority)
	{
		class'PawnHelper'.static.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex, AfflictionData);
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
	if( Controller.Target!=None && Controller.Target.IsA('NetKActor') )
    {
        PushDirection = Normal(Controller.Target.Location-Location) * 100000.f;
    }

    return class'PawnHelper'.static.MeleeDamageTarget(Self, HitDamage, PushDirection, AfflictionData);
}

simulated function Tick(float DeltaTime)
{
    class'PawnHelper'.static.PreTickAfflictionData(DeltaTime, self, AfflictionData);

    TickCloak(DeltaTime);

    Super.Tick(DeltaTime);

    class'PawnHelper'.static.TickAfflictionData(DeltaTime, self, AfflictionData);
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

simulated function CloakBoss()
{
	local Controller C;
	local int Index;

    if( bZapped )
    {
        return;
    }

	if( bSpotted )
	{
		Visibility = 120;

		if( Level.NetMode==NM_DedicatedServer )
        {
			Return;
        }
		
        Skins[0] = Finalblend'KFX.StalkerGlow';
		Skins[1] = Finalblend'KFX.StalkerGlow';
		bUnlit = true;
		return;
	}

	Visibility = 1;
	bCloaked = true;

	if( Level.NetMode!=NM_Client )
	{
		for( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.bIsPlayer && C.Enemy==Self )
            {
				C.Enemy = None; // Make bots lose sight with me.
            }
		}
	}
	
    if( Level.NetMode==NM_DedicatedServer )
    {
        return;
    }	

    Skins = CloakedSkinList;

	if(PlayerShadow != none)
    {
        PlayerShadow.bShadowActive = false;
    }
    
	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors = false;
    SetOverlayMaterial(FinalBlend'KF_Specimens_Trip_T.patriarch_fizzle_FB', 1.0, true);

	// Randomly send out a message about Patriarch going invisible(10% chance)
	if ( FRand() < 0.10 )
	{
		// Pick a random Player to say the message
		Index = Rand(Level.Game.NumPlayers);

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( PlayerController(C) != none )
			{
				if ( Index == 0 )
				{
					PlayerController(C).Speech('AUTO', 8, "");
					break;
				}

				Index--;
			}
		}
	}
}

simulated function UnCloakBoss()
{
    if( bZapped )
    {
        return;
    }

	Visibility = default.Visibility;
	bCloaked = false;
	bSpotted = False;
	bUnlit = False;
	
    if( Level.NetMode == NM_DedicatedServer )
    {
		return;
    }

	Skins = Default.Skins;

	if (PlayerShadow != none)
    {
        PlayerShadow.bShadowActive = true;
    }

	bAcceptsProjectors = true;
    SetOverlayMaterial( none, 0.0, true );
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

function float NumPlayersHealthModifer()
{
    return class'PawnHelper'.static.GetBodyHealthModifier(self, Level);
}

function float NumPlayersHeadHealthModifer()
{
    return class'PawnHelper'.static.GetHeadHealthModifier(self, Level);
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
    CommandoSpotDuration=2.f

	SneakFailureCount=0
	ChargeDurationIncreaseFailureCount=1
	ChargeSpeedIncreaseFailureCount=4

    //NOTE: Affliction move speed modifiers are not used by the boss. They exist, but are not used.
    Begin Object Class=AfflictionBurn Name=BurnAffliction
    End Object

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeDelay=2.f
        ZapDischargeRate=0.25f
    End Object

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
    End Object

    AfflictionData=(Burn=AfflictionBurn'BurnAffliction',Zap=AfflictionZap'ZapAffliction',Harpoon=AfflictionHarpoon'HarpoonAffliction')

	CloakedSkinList(0) = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun'
	CloakedSkinList(1) = Shader'KF_Specimens_Trip_T.patriarch_invisible'
    HelpMeSound=Sound'KF_EnemiesFinalSnd.Patriarch.Kev_SaveMe'
}
