//Killing Floor Turbo TurboClientModifierReplicationLink
//Linked list of client modifications. Forwards mutator-like events but for things only the client cares about.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboClientModifierReplicationLink extends ReplicationInfo
    abstract;

var TurboClientModifierReplicationLink NextClientModifierLink;
var TurboGameReplicationInfo OwnerGRI;

replication
{
    reliable if(Role == ROLE_Authority)
        NextClientModifierLink, OwnerGRI;
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    OwnerGRI = TurboGameReplicationInfo(Owner);
}

//Used to find a modifier of a specific class. Meant to be called as a static via the class that's being searched for.
simulated static final function TurboClientModifierReplicationLink GetClientModifier(Actor Actor)
{
    local TurboClientModifierReplicationLink CMRL;
    
    if (Actor == None)
    {
        return None;
    }

    if (TurboGameReplicationInfo(Actor.Level.GRI) == None)
    {
        return None;
    }

    CMRL = TurboGameReplicationInfo(Actor.Level.GRI).CustomTurboClientModifier;
    while (CMRL != None)
    {
        if (ClassIsChildOf(CMRL.Class, default.Class))
        {
            return CMRL;
        }

        CMRL = CMRL.NextClientModifierLink;
    }
    
    return None;
}

simulated function ModifyMonster(KFMonster Monster) { if (NextClientModifierLink != None) { NextClientModifierLink.ModifyMonster(Monster); } }

//Called right before a PendingWeapon becomes the equipped weapon.
simulated function OnWeaponChange(KFWeapon CurrentWeapon, KFWeapon PendingWeapon) { if (NextClientModifierLink != None) { NextClientModifierLink.OnWeaponChange(CurrentWeapon, PendingWeapon); } }

//Make NetUpdateTime want to update now.
simulated function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

defaultproperties
{
    NetUpdateFrequency=0.1f
}