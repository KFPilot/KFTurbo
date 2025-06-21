//Killing Floor Turbo KFTurboRandomizerSettings
//Configures the randomizer. Allows for modular implementations for the randomizer.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboRandomizerSettings extends Object;

var editinline KFTurboRandomizerLoadoutCollection FleshpoundLoadout; //33% of lobby will have a loadout from this list (minimum of 1).
var editinline KFTurboRandomizerLoadoutCollection ScrakeLoadout; //33% of lobby will have a loadout from this list (minimum of 1).
var editinline KFTurboRandomizerLoadoutCollection EarlyWaveLoadout; //50% of lobby will have a loadout from this list (minimum of 1) (for the pre-fleshpound waves).
var editinline KFTurboRandomizerLoadoutCollection MiscLoadout; //Remainder of lobby will have a loadout from this list.
var editinline KFTurboRandomizerLoadoutCollection FunnyLoadout; //Randomly a Misc loadout will be swapped out for a funny one.

var editinline KFTurboRandomizerLoadoutCollection PatriarchTypeALoadout; //33% of lobby will receive a loadout from this list during Patriarch wave.
var editinline KFTurboRandomizerLoadoutCollection PatriarchTypeBLoadout; //33% of lobby will receive a loadout from this list during Patriarch wave
var editinline KFTurboRandomizerLoadoutCollection PatriarchFunnyLoadout; //Randomly a type A or B loadout will be swapped out for a funny one.

//Classes for starting equipment.
var class<KFWeapon> SingleWeaponClass;
var class<KFWeapon> DualiesWeaponClass;
var class<KFWeapon> FragWeaponClass;
var class<KFWeapon> SyringeWeaponClass;
var class<KFWeapon> WelderWeaponClass;
var class<KFWeapon> KnifeWeaponClass;

function InitializeCollection()
{
    EarlyWaveLoadout.InitializeCollection();

    FleshpoundLoadout.InitializeCollection();
    ScrakeLoadout.InitializeCollection();
    
    MiscLoadout.InitializeCollection();
    FunnyLoadout.InitializeCollection();

    PatriarchTypeALoadout.InitializeCollection();
    PatriarchTypeBLoadout.InitializeCollection();
    PatriarchFunnyLoadout.InitializeCollection();
}

function PrepareRandomization()
{

}

function KFTurboRandomizerLoadout GetRandomFleshpoundLoadout()
{
    return FleshpoundLoadout.GetRandomLoadout();
}

function KFTurboRandomizerLoadout GetRandomScrakeLoadout()
{
    return ScrakeLoadout.GetRandomLoadout();
}

function KFTurboRandomizerLoadout GetRandomEarlyWaveLoadout()
{
    return EarlyWaveLoadout.GetRandomLoadout();
}

final function KFTurboRandomizerLoadout GetRandomMiscLoadout()
{
    return MiscLoadout.GetRandomLoadout();
}

final function KFTurboRandomizerLoadout GetRandomFunnyLoadout()
{
    return FunnyLoadout.GetRandomLoadout();
}

final function KFTurboRandomizerLoadout GetRandomPatriarchTypeALoadout()
{
    return PatriarchTypeALoadout.GetRandomLoadout();
}

final function KFTurboRandomizerLoadout GetRandomPatriarchTypeBLoadout()
{
    return PatriarchTypeBLoadout.GetRandomLoadout();
}

final function KFTurboRandomizerLoadout GetRandomPatriarchFunnyLoadout()
{
    return PatriarchFunnyLoadout.GetRandomLoadout();
}

defaultproperties
{
    SingleWeaponClass=class'KFTurbo.W_9MM_Weap'
    DualiesWeaponClass=class'KFTurbo.W_Dual9MM_Weap'
    FragWeaponClass=class'KFTurbo.W_Frag_Weap'
    SyringeWeaponClass=class'KFTurbo.W_Syringe_Weap'
    WelderWeaponClass=class'KFMod.Welder'
    KnifeWeaponClass=class'KFTurbo.W_Knife_Weap'

    Begin Object Class=LoadoutCollection_Fleshpound Name=FleshpoundLoadoutCollection
    End Object
    FleshpoundLoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.FleshpoundLoadoutCollection'

    Begin Object Class=LoadoutCollection_Scrake Name=ScrakeLoadoutCollection
    End Object
    ScrakeLoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.ScrakeLoadoutCollection'

    Begin Object Class=LoadoutCollection_EarlyWave Name=EarlyWaveLoadoutCollection
    End Object
    EarlyWaveLoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.EarlyWaveLoadoutCollection'
    
    Begin Object Class=LoadoutCollection_Misc Name=MiscLoadoutCollection
    End Object
    MiscLoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.MiscLoadoutCollection'

    Begin Object Class=LoadoutCollection_Funny Name=FunnyLoadoutCollection
    End Object
    FunnyLoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.FunnyLoadoutCollection'

    Begin Object Class=LoadoutCollection_PatriarchA Name=PatriarchALoadoutCollection
    End Object
    PatriarchTypeALoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.PatriarchALoadoutCollection'

    Begin Object Class=LoadoutCollection_PatriarchB Name=PatriarchBLoadoutCollection
    End Object
    PatriarchTypeBLoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.PatriarchBLoadoutCollection'

    Begin Object Class=LoadoutCollection_PatriarchFunny Name=PatriarchFunnyLoadoutCollection
    End Object
    PatriarchFunnyLoadout=KFTurboRandomizerLoadoutCollection'KFTurboRandomizer.KFTurboRandomizerSettings.PatriarchFunnyLoadoutCollection'
}