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