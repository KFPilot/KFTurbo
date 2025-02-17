//Killing Floor Turbo W_LAW_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_LAW_Weap extends LAW;

simulated event StopFire(int Mode)
{
    if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
    Super.StopFire(Mode);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    class'WeaponHelper'.static.WeaponCheckForHint(Self, 19);
    class'WeaponHelper'.static.WeaponPulloutRemark(Self, 23);

    Super.BringUp(PrevWeapon);
}

simulated function ZoomIn(bool bAnimateTransition)
{
    if( Level.TimeSeconds < FireMode[0].NextFireTime )
    {
        return;
    }

    super.ZoomIn(bAnimateTransition);

    if( bAnimateTransition )
    {
        if( bZoomOutInterrupted )
        {
            PlayAnim('Raise',2.0,0.1);
        }
        else
        {
            PlayAnim('Raise',2.0,0.1);
        }
    }
}

defaultproperties
{
     ForceZoomOutOnFireTime=0.075000
     Weight=11.000000
     ZoomTime=0.175000
     FastZoomOutTime=0.150000
     FireModeClass(0)=Class'KFTurbo.W_LAW_Fire'
     PickupClass=Class'KFTurbo.W_LAW_Pickup'
}
