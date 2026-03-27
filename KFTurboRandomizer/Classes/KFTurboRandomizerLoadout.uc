//Killing Floor Turbo KFTurboRandomizerLoadout
//Represents a perk and loadout a player can be given.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboRandomizerLoadout extends Object
    instanced;

var() float SelectionWeight;
var() class<KFVeterancyTypes> Perk;
var() array< class<KFWeapon> > WeaponList;
var() bool bSingle;
var() bool bSyringe;
var() bool bWelder;
var() bool bKnife;

var int DefaultIndex; //Index of this loadout in its loadout collection.

//Used to validate if two loadout objects are the same.
final function bool IsIdentical(KFTurboRandomizerLoadout Other)
{
    local int Index;

    if (Other == None)
    {
        return false;
    }

    if (WeaponList.Length != Other.WeaponList.Length)
    {
        return false;
    }

    for (Index = 0; Index < WeaponList.Length; Index++)
    {
        if (WeaponList[Index] != Other.WeaponList[Index])
        {
            return false;
        }
    }

    return SelectionWeight == Other.SelectionWeight
        && Perk == Other.Perk
        && bSingle == Other.bSingle
        && bSyringe == Other.bSyringe
        && bWelder == Other.bWelder
        && bKnife == Other.bKnife;
}

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