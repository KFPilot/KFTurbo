class P_Crawler_Jumper extends P_Crawler_SUM DependsOn(PawnHelper);

var float PounceWindupDuration;

function bool DoPounce()
{
    GotoState('PounceWindup');
    return true;
}

State PounceWindup
{
ignores AnimEnd, Trigger, Bump, HitWall, RangedAttack;

    function bool CanGetOutOfWay()
    {
        return false;
    }

    simulated function bool HitCanInterruptAction()
    {
        return false;
    }

	function Tick( float Delta )
	{
        Acceleration = vect(0,0,0);
        Velocity = vect(0,0,0);

        Global.Tick(Delta);
	}

    simulated function bool DoPounce()
    {
        return true;
    }

    simulated function PerformPounce()
    {
        if ( bZapped || bDecapitated || bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking) || VSize(Location - Controller.Target.Location) > (MeleeRange * 20) )
		{
            GotoState('');
            return;
        }

        Velocity = Normal(Controller.Target.Location-Location)*PounceSpeed;
        Velocity.Z = JumpZ;
        SetPhysics(PHYS_Falling);
        ZombieSpringAnim();
        bPouncing=true;
        GotoState('');
        return;
    }

Begin:
    Sleep(PounceWindupDuration);
    PerformPounce();
}

defaultproperties
{
    PounceWindupDuration=1.f
    PounceSpeed=1650.f

    Begin Object Class=A_Burn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object

    Begin Object Class=A_Zap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object

    Begin Object Class=A_Harpoon Name=HarpoonAffliction
        HarpoonSpeedModifier=0.5f
    End Object

    AfflictionData=(Burn=A_Burn'BurnAffliction',Zap=A_Zap'ZapAffliction',Harpoon=A_Harpoon'HarpoonAffliction')
    
    ControllerClass=class'KFTurbo.AI_Crawler_Jumper'
    MenuName="Raptor"
}
