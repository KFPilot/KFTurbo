class W_ThompsonSMG_Weap extends ThompsonSMG;

defaultproperties
{
     ReloadRate=3.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.200000

     Weight=6.000000

     MagCapacity=25
     FireModeClass(0)=Class'KFTurbo.W_ThompsonSMG_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     InventoryGroup=3
     PickupClass=Class'KFTurbo.W_ThompsonSMG_Pickup'
     ItemName="Thompson Incendiary SMG"
}