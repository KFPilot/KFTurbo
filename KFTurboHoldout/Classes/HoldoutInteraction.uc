//Killing Floor Turbo HoldoutInteraction
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutInteraction extends Engine.Interaction;

var float ShiftHoldTime;
var bool bIsShiftPressed;
var float DecayRate;
var const float ReadyHoldDuration;
var const float MaxDecayRate;
var const float MaxDecayBuildRate;

final function HoldoutPlayerSparseInfo FindHoldoutSRI()
{
    if (ViewportOwner == None || ViewportOwner.Actor == None)
    {
        return None;
    }

	return class'HoldoutPlayerSparseInfo'.static.GetHoldoutInfo(ViewportOwner.Actor.PlayerReplicationInfo);
}

simulated function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (Key == IK_Shift)
	{
		if (Action == IST_Press)
		{
            bIsShiftPressed = true;
		}
		else if (Action == IST_Release)
		{
            bIsShiftPressed = false;
		}
	}

	return false;
}

simulated final function float GetReadyHoldPercent()
{
    local HoldoutPlayerSparseInfo SRI;
    SRI = FindHoldoutSRI();

    if (SRI != None && SRI.IsReady())
    {
        return 1.f;
    }

	if (ShiftHoldTime < 0.f)
	{
		return 0.f;
	}

	return FClamp(ShiftHoldTime / ReadyHoldDuration, 0.f, 1.f);
}

simulated function Tick(float DeltaTime)
{
	local HoldoutPlayerSparseInfo SRI;

    if (!bIsShiftPressed)
    {
        if (ShiftHoldTime <= 0.f)
        {
            return;
        }

        DecayRate = Lerp(DeltaTime * MaxDecayBuildRate, DecayRate, MaxDecayRate);
        ShiftHoldTime = FMax(0.f, ShiftHoldTime - (DeltaTime * DecayRate));
        return;
    }

    DecayRate = 0.f;
	ShiftHoldTime = FMax(0.f, ShiftHoldTime);
	ShiftHoldTime += DeltaTime;
	ShiftHoldTime = FMin(ShiftHoldTime, ReadyHoldDuration);

	if (ShiftHoldTime < ReadyHoldDuration)
	{
		return;
	}

	ShiftHoldTime = 0.f;

	SRI = FindHoldoutSRI();
    if (SRI != None)
	{
		SRI.ReadyUp();
	}
}

defaultproperties
{
	ShiftHoldTime=-1.f
	ReadyHoldDuration=2.f
    MaxDecayRate=1.f
    MaxDecayBuildRate=0.25f
	bRequiresTick=true
}
