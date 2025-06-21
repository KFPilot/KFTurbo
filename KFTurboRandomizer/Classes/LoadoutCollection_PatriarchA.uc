//Killing Floor Turbo LoadoutCollection_PatriarchA
//Represents Patriarch melee locking loadouts
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class LoadoutCollection_PatriarchA extends KFTurboRandomizerLoadoutCollection;

defaultproperties
{
    Begin Object Class=LoadoutCollection_Scrake Name=ForceImportScrakeLoadout
    End Object

    Begin Object Class=LoadoutCollection_Misc Name=ForceImportMiscLoadout
    End Object

    Begin Object Class=KFTurboRandomizerLoadout Name=PatriarchALoadout0
        Perk=class'V_Berserker'
        WeaponList(0)=class'KFTurbo.W_Katana_Weap'
        WeaponList(1)=class'KFTurbo.W_FlareRevolver_Weap'
    End Object
    
    Begin Object Class=KFTurboRandomizerLoadout Name=PatriarchALoadout1
        Perk=class'V_FieldMedic'
        WeaponList(0)=class'KFTurbo.W_MP7M_Weap'
        WeaponList(1)=class'KFMod.Machete'
    End Object
    
    Begin Object Class=KFTurboRandomizerLoadout Name=PatriarchALoadout2
        Perk=class'V_Berserker'
        WeaponList(0)=class'KFMod.Machete'
        WeaponList(1)=class'KFTurbo.W_FlareRevolver_Weap'
    End Object

    Begin Object Class=KFTurboRandomizerLoadout Name=PatriarchALoadout3
        Perk=class'V_FieldMedic'
        WeaponList(0)=class'KFTurbo.W_MP7M_Weap'
        WeaponList(1)=class'KFTurbo.W_Katana_Weap'
    End Object

    Begin Object Class=KFTurboRandomizerLoadout Name=PatriarchALoadout4
        Perk=class'V_Berserker'
        WeaponList(0)=class'KFTurbo.W_Crossbuzzsaw_Weap'
        WeaponList(1)=class'KFMod.Machete'
    End Object

    LoadoutList(0)=KFTurboRandomizerLoadout'KFTurboRandomizer.LoadoutCollection_Misc.MiscLoadout14'
    LoadoutList(1)=KFTurboRandomizerLoadout'KFTurboRandomizer.LoadoutCollection_PatriarchA.PatriarchALoadout0'
    LoadoutList(2)=KFTurboRandomizerLoadout'KFTurboRandomizer.LoadoutCollection_PatriarchA.PatriarchALoadout1'
    LoadoutList(3)=KFTurboRandomizerLoadout'KFTurboRandomizer.LoadoutCollection_PatriarchA.PatriarchALoadout2'
    LoadoutList(4)=KFTurboRandomizerLoadout'KFTurboRandomizer.LoadoutCollection_PatriarchA.PatriarchALoadout3'
    LoadoutList(5)=KFTurboRandomizerLoadout'KFTurboRandomizer.LoadoutCollection_PatriarchA.PatriarchALoadout4'
}