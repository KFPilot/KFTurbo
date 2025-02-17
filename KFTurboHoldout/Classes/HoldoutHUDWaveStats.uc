//Killing Floor Turbo HoldoutHUDWaveStats
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutHUDWaveStats extends TurboHUDWaveStats;

simulated function Timer()
{
	if (ProcessingWave < 0)
	{
		return;
	}

    DisplayDuration = default.DisplayDuration; //Refresh state duration here in case we're already in DisplayWaveStats state.
	GotoState('DisplayWaveStats');
}

state DisplayWaveStats
{
	simulated function BeginState()
	{
		DisplayRatio = 0.f;
		DisplayDuration = default.DisplayDuration;
	}

	simulated function Render(Canvas C)
	{
		Global.Render(C);

		class'TurboHUDKillingFloor'.static.ResetCanvas(C);

		DrawStats(C);
	}

	simulated function Tick(float DeltaTime)
	{
		if (DisplayDuration <= 0.f)
		{
			DisplayRatio = Lerp(FadeOutRate * DeltaTime, DisplayRatio, 0.f);

			if (DisplayRatio <= 0.001f)
			{
				DisplayRatio = 0.f;
                GotoState('');
			}
			return;
		}
		
		DisplayDuration = FMax(DisplayDuration - DeltaTime, 0.f);

		if (DisplayRatio < 1.f)
		{
			DisplayRatio = Lerp(FadeInRate * DeltaTime, DisplayRatio, 1.f);

			if (DisplayRatio > 0.999f)
			{
				DisplayRatio = 1.f;
			}
			return;
		}
	}	
}

defaultproperties
{
	DisplayDuration = 15.f;
}