//Killing Floor Turbo W_M79_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M79_Weap extends M79GrenadeLauncher;

simulated event StopFire(int Mode)
{
    if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
    Super.StopFire(Mode);
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_M79_Fire'
     PickupClass=Class'KFTurbo.W_M79_Pickup'
}
