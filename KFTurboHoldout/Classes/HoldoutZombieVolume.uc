//Killing Floor Turbo HoldoutZombieVolume
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutZombieVolume extends ZombieVolume;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Tag == 'Default')
	{
		bVolumeIsEnabled = true;
	}
	else
	{
		bVolumeIsEnabled = false;
	}
}

function NotifyNewWave(int CurWave) {}

defaultproperties
{
	bVolumeIsEnabled = false
}
