//Killing Floor Turbo W_Magnum44_bigiron_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Magnum44_bigiron_Fire extends W_M99_Fire;

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
    	if( Level.TimeSeconds - LastClickTime>FireRate )
    	{
    		LastClickTime = Level.TimeSeconds;
    	}

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

	return Super.AllowFire();
}

defaultproperties
{
     KickMomentum=(X=-325.000000,Z=100.000000)
     FireRate=0.250000
     AmmoClass=Class'KFTurboRandomizer.W_Magnum44_bigiron_Ammo'
     ProjectileClass=Class'KFTurboRandomizer.W_Magnum44_bigiron_Proj'
}