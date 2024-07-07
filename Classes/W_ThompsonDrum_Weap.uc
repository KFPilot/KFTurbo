//=============================================================================
// ThompsonDrumSMG
//=============================================================================
// A ThompsonDrum Sub Machine Gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class W_ThompsonDrum_Weap extends ThompsonDrumSMG;

defaultproperties
{
     MagCapacity=50
     ReloadRate=4.210000
     ReloadAnimRate=0.900000
     Weight=6.000000
     AppID=0
     FireModeClass(0)=Class'KFTurbo.W_ThompsonDrum_Fire'
     PickupClass=Class'KFTurbo.W_ThompsonDrum_Pickup'
}
