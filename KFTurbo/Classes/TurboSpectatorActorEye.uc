//Killing Floor Turbo TurboSpectatorActorEye
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboSpectatorActorEye extends TurboSpectatorActor;

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        SetDrawScale(4.f);
        SetDrawType(EDrawType.DT_StaticMesh);
        SetStaticMesh(StaticMesh'kf_gore_trip_sm.gibbs.eyeball');
    }
}