class W_LAW_Weap extends LAW;

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
