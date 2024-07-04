class P_Crawler_Raptor extends P_Crawler_SUM;

function bool DoPounce()
{
	if ( bZapped || bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking) || VSize(Location - Controller.Target.Location) > (MeleeRange * 20) )
		return false;

	Velocity = Normal(Controller.Target.Location-Location)*PounceSpeed;
	Velocity.Z = JumpZ;
	SetPhysics(PHYS_Falling);
	ZombieSpringAnim();
	bPouncing=true;
	return true;
}

defaultproperties
{
     PounceSpeed=1650.000000
     MenuName="Raptor"
     ControllerClass=Class'KFTurbo.AI_Crawler_Raptor'
}