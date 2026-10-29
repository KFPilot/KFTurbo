//Killing Floor Turbo VinylAugmentBunkerSix
//Increase counter at the start of each wave held, reaching full strength after RampWaveCount waves.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBunkerSix extends VinylAugmentBasicScaled;

var int WaveCount;
var const int RampWaveCount;

replication
{
	reliable if (Role == ROLE_Authority)
		WaveCount;
}

function NotifyWaveStarted(int Wave)
{
    if (WaveCount >= RampWaveCount)
    {
        return;
    }

    WaveCount++;
    ForceNetUpdate();

    if (bWantsPlayerMaxHealthMultiplier && TurboGameReplicationInfo(Level.GRI) != None)
    {
        TurboGameReplicationInfo(Level.GRI).NotifyPlayerMaxHealthChanged();
    }
}

simulated function float GetScaleRatio()
{
    if (RampWaveCount <= 0)
    {
        return 1.f;
    }

    return FClamp(float(WaveCount) / float(RampWaveCount), 0.f, 1.f);
}

defaultproperties
{
    bWantsWaveStartedEvents=true
    RampWaveCount=5
}
