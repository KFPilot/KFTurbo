//Killing Floor Turbo W_M99_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M99_Weap extends WeaponM99SniperRifle;

simulated event StopFire(int Mode)
{
    if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
    Super.StopFire(Mode);
}

defaultproperties
{
     Weight=12.000000
     FireModeClass(0)=Class'KFTurbo.W_M99_Fire'
     PickupClass=Class'KFTurbo.W_M99_Pickup'
}
