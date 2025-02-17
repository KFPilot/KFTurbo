//Killing Floor Turbo W_LAW_WTF_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_LAW_WTF_Fire extends W_LAW_Fire;

function bool AllowFire()  // the user will not fire this gun more than once
{
    return true;
}

defaultproperties
{
     ProjPerFire=1
     ProjSpawnOffset=(X=12.000000,Y=5.000000,Z=-5.000000)
     AmmoPerFire=10
     KickMomentum=(X=-500.000000,Z=100.000000)
     ProjectileClass=Class'KFTurboRandomizer.W_LAW_WTF_Proj'
     Spread=4000.000000
}