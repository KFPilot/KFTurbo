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

var array<int> UsedEarlyWaveLoadoutList;

var array<int> UsedFleshpoundLoadoutList;
var array<int> UsedScrakeLoadoutList;

var array<int> UsedMiscLoadoutList;
var array<int> UsedFunnyLoadoutList;

var array<int> UsedPatriarchTypeALoadoutList;
var array<int> UsedPatriarchTypeBLoadoutList;
var array<int> UsedPatriarchFunnyLoadoutList;

static final function RestoreLoadout(KFTurboRandomizerLoadoutCollection LoadoutCollection, out array<int> UsedIndexList)
{
    local int Index;
    LoadoutCollection.LoadoutList = LoadoutCollection.default.LoadoutList;
    for (Index = UsedIndexList.Length - 1; Index >= 0; Index--)
    {
        LoadoutCollection.LoadoutList.Remove(Index, 1);
    }

    //Consume used index list.
    UsedIndexList.Length = 0;
}

static final function KFTurboRandomizerLoadout TakeLoadout(int Index, KFTurboRandomizerLoadoutCollection LoadoutCollection, out array<int> IndexList)
{
    local KFTurboRandomizerLoadout Loadout;
    Loadout = LoadoutCollection.LoadoutList[Index];
    LoadoutCollection.LoadoutList.Remove(Index, 1);
    InsertIndexInOrder(Index, IndexList);
    return Loadout;
}

//Inserts indices from low to high order.
static final function InsertIndexInOrder(int NewIndex, out array<int> IndexList)
{
    local int Index;
    for (Index = 0; Index < IndexList.Length; Index++)
    {
        if (IndexList[Index] < NewIndex)
        {
            IndexList.Insert(Index, 1);
            IndexList[Index] = NewIndex;
            return;
        }
    }

    IndexList[IndexList.Length] = NewIndex;
}

function PrepareRandomization()
{
    RestoreLoadout(EarlyWaveLoadout, UsedEarlyWaveLoadoutList);

    RestoreLoadout(FleshpoundLoadout, UsedFleshpoundLoadoutList);
    RestoreLoadout(ScrakeLoadout,  UsedScrakeLoadoutList);
    
    RestoreLoadout(MiscLoadout, UsedMiscLoadoutList);
    RestoreLoadout(FunnyLoadout,  UsedFunnyLoadoutList);

    RestoreLoadout(PatriarchTypeALoadout, UsedPatriarchTypeALoadoutList);
    RestoreLoadout(PatriarchTypeBLoadout, UsedPatriarchTypeBLoadoutList);
    RestoreLoadout(PatriarchFunnyLoadout, UsedPatriarchFunnyLoadoutList);
}

function KFTurboRandomizerLoadout GetRandomFleshpoundLoadout()
{
    return TakeLoadout(FleshpoundLoadout.GetRandomIndex(), FleshpoundLoadout, UsedFleshpoundLoadoutList);
}

function KFTurboRandomizerLoadout GetRandomScrakeLoadout()
{
    return TakeLoadout(ScrakeLoadout.GetRandomIndex(), ScrakeLoadout, UsedScrakeLoadoutList);
}

function KFTurboRandomizerLoadout GetRandomEarlyWaveLoadout()
{
    return TakeLoadout(EarlyWaveLoadout.GetRandomIndex(), EarlyWaveLoadout, UsedEarlyWaveLoadoutList);
}

final function KFTurboRandomizerLoadout GetRandomMiscLoadout()
{
    return TakeLoadout(MiscLoadout.GetRandomIndex(), MiscLoadout, UsedMiscLoadoutList);
}

final function KFTurboRandomizerLoadout GetRandomFunnyLoadout()
{
    return TakeLoadout(FunnyLoadout.GetRandomIndex(), FunnyLoadout, UsedFunnyLoadoutList);
}

final function KFTurboRandomizerLoadout GetRandomPatriarchTypeALoadout()
{
    return TakeLoadout(PatriarchTypeALoadout.GetRandomIndex(), PatriarchTypeALoadout, UsedPatriarchTypeALoadoutList);
}

final function KFTurboRandomizerLoadout GetRandomPatriarchTypeBLoadout()
{
    return TakeLoadout(PatriarchTypeBLoadout.GetRandomIndex(), PatriarchTypeBLoadout, UsedPatriarchTypeBLoadoutList);
}

final function KFTurboRandomizerLoadout GetRandomPatriarchFunnyLoadout()
{
    return TakeLoadout(PatriarchFunnyLoadout.GetRandomIndex(), PatriarchFunnyLoadout, UsedPatriarchFunnyLoadoutList);
}

defaultproperties
{
    SingleWeaponClass=class'KFMod.Single'
    DualiesWeaponClass=class'KFMod.Dualies'
    FragWeaponClass=class'KFTurbo.W_Frag_Weap'
    SyringeWeaponClass=class'KFMod.Syringe'
    WelderWeaponClass=class'KFMod.Welder'
    KnifeWeaponClass=class'KFMod.Knife'

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