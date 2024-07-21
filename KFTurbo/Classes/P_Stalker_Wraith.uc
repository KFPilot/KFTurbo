
//-------------------------------------------------------------------------------
// Wraith Stalker - WIP
// to test the behavior go to 
// https://www.desmos.com/calculator/zji10eiyip
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
// TODO: Allow Shotguns to deal *some* damage (add a delay before teleporting)
// TODO: Test it on Dedicated servers
// MAYBE: Make it so the only way they uncloak is by teleporting
// MAYBE: Allow teleportation while spotted by commando - probably not
//-------------------------------------------------------------------------------

class P_Stalker_Wraith extends P_Stalker_XMA;

var float CloakDelay;
var float TPDistanceSelfMinSquared;
var float TPDistanceAttackerMinSquared;
var float TPDistanceAttackerMaxSquared;

simulated event SetAnimAction(name NewAction)
{	
    if ( NewAction == 'Claw' || NewAction == MeleeAnims[0] || NewAction == MeleeAnims[1] || NewAction == MeleeAnims[2] )
	{
		UncloakStalker();
        CloakDelay=1.2;
	}
	super(KFMonster).SetAnimAction(NewAction);
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (class<KFWeaponDamageType>(damageType).default.bIsExplosive)
	{
		Damage *= 0.5f;
	}
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);

	if(!(Health <= 0) && !bDecapitated && bCloaked)
	{
		InitiateStalkerTeleport(InstigatedBy);
		UncloakStalker();
		CloakDelay=default.CloakDelay;
	}
}

function InitiateStalkerTeleport(Pawn Attacker)
{
    local int i;
    local Vector ProposedDest;
	local Vector FallbackDest;
    local bool bFoundLocation;
	local float DistanceToAttackerSquared;

    bFoundLocation = false;
	DistanceToAttackerSquared = VSizeSquared(Attacker.Location - self.Location);

	// Strict Teleport
	for( i = 0 ; i < 20 ; i++ )
	{
        ProposedDest = self.Controller.FindRandomDest().Location;

		// If a valid point is found that is not next to the player at any point, save it as a fallback location
		// If a fallback location is already saved, ignore.
		if(FallbackDest != vect(0, 0, 0) && VSizeSquared(ProposedDest - Attacker.Location) >= TPDistanceAttackerMinSquared)
		{
			FallbackDest = ProposedDest;
		}

    	// Try to find a location within strict criteria, behind the attacker.
        if (VSizeSquared(ProposedDest - Attacker.Location) >= TPDistanceAttackerMinSquared &&
            VSizeSquared(ProposedDest - Attacker.Location) <= TPDistanceAttackerMaxSquared &&
            VSizeSquared(ProposedDest - self.Location) >= Max(TPDistanceSelfMinSquared, DistanceToAttackerSquared))
        {
            bFoundLocation = true;
			Log("Strict criteria met: ProposedDest = " $ ProposedDest);
            break;
        }
	}

	// Loose Teleport if Strict Teleport failed
	if (!bFoundLocation)
	{
		for ( i = 0 ; i < 9 ; i++ )
		{
			ProposedDest = self.Controller.FindRandomDest().Location;
				
			// If a valid point is found that is not next to the player at any point, save it as a fallback location
			// If a fallback location is already saved, ignore.
			if(FallbackDest != vect(0, 0, 0) && VSizeSquared(ProposedDest - Attacker.Location) >= TPDistanceAttackerMinSquared)
			{
				FallbackDest = ProposedDest;
			}

			// Try to find a location outside TPDistanceSelfMinSquared only, outside the attacker's view.
			if (VSizeSquared(ProposedDest - Attacker.Location) >= TPDistanceAttackerMinSquared &&
				VSizeSquared(ProposedDest - self.Location) >= Max(TPDistanceSelfMinSquared, DistanceToAttackerSquared))
			{
				bFoundLocation = true;
				Log("Loose criteria met: ProposedDest = " $ ProposedDest);
				break;
			}
		}
	}
	// If still not found, go to the Fallback Destination
	if (!bFoundLocation)
	{
		if(FallbackDest != vect(0, 0, 0))
		{
			ProposedDest = FallbackDest;
			Log("Failed to meet criteria: FallbackDest = " $ ProposedDest);
		}
		// If all else fails, pick a random destination
		ProposedDest = self.Controller.FindRandomDest().Location;
		Log("Lost to RNG, lmao. ProposedDest = " $ ProposedDest);
	}
	// Set the location to the chosen destination
	SetLocation(ProposedDest);
	Log("Teleporting to: " $ ProposedDest);
}

simulated function TickCloak(float DeltaTime)
{
    if( Level.NetMode==NM_DedicatedServer )
		return; // Servers aren't intrested in this info.

    if( bZapped )
    {
        // Make sure we check if we need to be cloaked as soon as the zap wears off
        NextCheckTime = Level.TimeSeconds;
    }
	else if( Level.TimeSeconds > NextCheckTime && Health > 0 )
	{
		NextCheckTime = Level.TimeSeconds + 0.5;

		if( LocalKFHumanPawn != none && LocalKFHumanPawn.Health > 0 && LocalKFHumanPawn.ShowStalkers() &&
			VSizeSquared(Location - LocalKFHumanPawn.Location) < LocalKFHumanPawn.GetStalkerViewDistanceMulti() * 640000.0 ) // 640000 = 800 Units
		{
			bSpotted = True;
		}
		else
		{
			bSpotted = false;
		}

		if ( !bSpotted && !bCloaked && Skins[0] != DefaultSkin[0] )
		{
			UncloakStalker();
            CloakDelay=1.2;
		}
		else if ( Level.TimeSeconds - LastUncloakTime > CloakDelay )
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
	GroundSpeed=250.000000
	WaterSpeed=200.000000
	Health=140
	MenuName="Wraith"
	CloakDelay=10.0 // After teleporting, for this many seconds the stalker loses its cloak, or until attacking
	TPDistanceAttackerMinSquared=90000.0 // Never teleport right next to the Attacker.
	TPDistanceAttackerMaxSquared=4000000.0 // Strict Teleport: Within this distance to the Attacker should it teleport to.
	TPDistanceSelfMinSquared=2250000.0 // Loose Teleport: Always teleport at least this distance away from its original location.
}