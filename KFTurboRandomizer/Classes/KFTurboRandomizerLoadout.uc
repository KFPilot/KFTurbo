class KFTurboRandomizerLoadout extends Object
    editinlinenew;

var() float SelectionWeight;
var() class<KFVeterancyTypes> Perk;
var() array< class<KFWeapon> > WeaponList;
var() bool bSingle;
var() bool bSyringe;
var() bool bWelder;
var() bool bKnife;

final function bool HasWeapon(class<KFWeapon> WeaponClass)
{
    local int Index;
    for (Index = 0; Index < WeaponList.Length; Index++)
    {
        if (WeaponList[Index] == WeaponClass)
        {
            return true;
        }
    }

    return false;
}

final function int GetArmor(KFTurboRandomizerMut.ELoadoutType LoadoutType)
{
    switch(LoadoutType)
    {
        case LT_PatriarchTypeA:
        case LT_PatriarchTypeB:
        case LT_PatriarchFunny:
            return 100;
    }

    switch (Perk)
    {
        case class'V_Berserker':
        case class'V_FieldMedic':
            return 100;
        case class'V_Commando':
        case class'V_Demolitions':
            return Round(RandRange(75.f, 100.f));
    }
    
    return Round(RandRange(25.f, 75.f));
}

defaultproperties
{
    SelectionWeight = 1.f

    bSingle=true
    bSyringe=true
    bWelder=true
    bKnife=true
}