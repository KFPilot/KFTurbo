//Killing Floor Turbo W_SeekerSix_Seeking_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SeekerSix_Seeking_Proj extends W_SeekerSix_Proj;

var Actor Seeking;
var vector InitialDir;

replication
{
    reliable if( bNetInitial && (Role==ROLE_Authority) )
        Seeking, InitialDir;
}

simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;

    if ( InitialDir == vect(0,0,0) )
        InitialDir = Normal(Velocity);

	Acceleration = vect(0,0,0);
    Super.Timer();
    if ( (Seeking != None) && (Seeking != Instigator) )
    {
		// Do normal guidance to target.
		ForceDir = Normal((Seeking.Location + (vect(0.f,0.f,1.f) * Seeking.CollisionHeight)) - Location);

		if( (ForceDir Dot InitialDir) > 0 )
		{
			VelMag = VSize(Velocity);
            // Increase the multiplier that is currently 0.8 to make the rocket track better if you need to
			ForceDir = Normal(ForceDir * 0.8 * VelMag + Velocity);
			Velocity =  VelMag * ForceDir;
			Acceleration += 5 * ForceDir;
		}
		// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
    }
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.1, true);
}

defaultproperties
{
}
