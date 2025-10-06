//Killing Floor Turbo P_Stalker
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Stalker extends MonsterStalker DependsOn(PawnHelper);

var bool bUnstunTimeReady;
var float UnstunTime;

var float LastCommandoSpotTime;
var float CommandoSpotDuration;

simulated function SetZappedBehavior()
{
    Super.SetZappedBehavior();

    bUnlit = false;

    if( Level.Netmode != NM_DedicatedServer )
	{
        Skins[0] = DefaultSkin[0];
        Skins[1] = DefaultSkin[1];

		if (PlayerShadow != none)
			PlayerShadow.bShadowActive = true;

		bAcceptsProjectors = true;
		SetOverlayMaterial(Material'KFZED_FX_T.Energy.ZED_overlay_Hit_Shdr', 999, true);
	}
}

simulated function UnSetZappedBehavior()
{
    Super.UnSetZappedBehavior();
    
    if( Level.Netmode != NM_DedicatedServer )
	{
        NextCheckTime = Level.TimeSeconds;
        SetOverlayMaterial(None, 0.0f, true);
	}
}

simulated function SpotStalker()
{
	LastCommandoSpotTime = Level.TimeSeconds;
}

//Fixing up Stalker material issues;
simulated function TickCloak(float DeltaTime)
{
    if( Level.NetMode == NM_DedicatedServer )
	{
		bSpotted = bCloaked && (LastCommandoSpotTime + CommandoSpotDuration > Level.TimeSeconds);
		if (!bCloaked && Level.TimeSeconds - LastUncloakTime > 1.2 )
		{
			CloakStalker();
		}
		return;
	}

    if( bZapped )
    {
        NextCheckTime = Level.TimeSeconds + 0.5;
		return;
    }

	if( Level.TimeSeconds > NextCheckTime && Health > 0 )
	{
		NextCheckTime = Level.TimeSeconds + 0.5;
		bSpotted = bCloaked && (LastCommandoSpotTime + CommandoSpotDuration > Level.TimeSeconds);

		if ( !bSpotted && !bCloaked && Skins[0] != DefaultSkin[0] )
		{
			UncloakStalker();
		}
		else if ( Level.TimeSeconds - LastUncloakTime > 1.2 )
		{
			// if we're uberbrite, turn down the light
			if( bSpotted && Skins[0] != Finalblend'KFX.StalkerGlow' )
			{
				bUnlit = false;
				CloakStalker();
			}
			else if ( Skins[0] != CloakedSkin[0] )
			{
				CloakStalker();
			}
		}
	}
}

defaultproperties
{
	CommandoSpotDuration=2.f

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
