//Killing Floor Turbo W_Frag_Proj_Shrapnel
//Custom shrapnel class - does no damage.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Frag_Proj_Shrapnel extends KFMod.KFShrapnel;

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    if ( (FlakChunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator)) )
    {
        Destroy();
    }
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    if (!Wall.bStatic && !Wall.bWorldGeometry && ((Mover(Wall) == None) || Mover(Wall).bDamageTriggered))
    {
        Destroy();
        return;
    }

    SetPhysics(PHYS_Falling);
    
	if (Bounces > 0)
    {
		if (!Level.bDropDetail && (FRand() < 0.4f))
        {
			Playsound(ImpactSounds[Rand(6)]);
        }

        Velocity = 0.65f * (Velocity - 2.f * HitNormal * (Velocity dot HitNormal));
        Bounces = Bounces - 1;
        return;
    }

	bBounce = false;

    if (Trail != None)
    {
        Trail.mRegen=False;
        Trail.SetPhysics(PHYS_None);
    }
}

defaultproperties
{
    Damage=0.000000
}
