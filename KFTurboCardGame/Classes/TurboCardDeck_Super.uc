//Killing Floor Turbo TurboCardDeck_Super
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck_Super extends TurboCardDeck;

function ActivateBerserker(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyBerserkerWeaponFireRate(3.f);
}

function ActivateCommando(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyCommandoWeaponMagazineAmmo(2.f);
    CGRI.ModifyCommandoWeaponReloadRate(1.2f);
    CGRI.ModifyCommandoWeaponMaxAmmo(1.2f);
}

function ActivateFirebug(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyFireDamage(1.5f);
    CGRI.ModifyFirebugWeaponFireRate(2.5f);
}

function ActivateUberMedic(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyMedicGrenadeDamage(10.f);
    CGRI.ModifyMedicWeaponMagazineAmmo(2.f);
    CGRI.ModifyMedicHealPotency(1.5f);
    CGRI.ModifyMedicWeaponMaxAmmo(1.25f);
}

function ActivateFleshpoundDamage(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerFleshpoundDamage(1.5f);
}

function ActivateScrakeDamage(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerScrakeDamage(1.5f);
}

function ActivateDeEvolution(TurboCardReplicationInfo CGRI)
{
    class'TurboWaveSpawnEventHandler'.static.RegisterWaveHandler(CGRI, class'DeEvolutionWaveEventHandler');
}

function ActivateMaxHealth(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerMaxHealth(2.f);
}

function ActivateMovementSpeed(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerSpeed(1.3f);
}

function ActivateReloadSpeed(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyWeaponReloadRate(1.5f);
}

function ActivateSirenScreemNullify(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifySirenScreamDamage(0.f);
}

function ActivateCheatDeath(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableCheatingDeath();
}

function ActivateUnshakeable(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyExplosiveDamageTaken(0.f);
}

function ActivateBigHeadMode(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyZombieHeadSize(1.5f);
}

function ActivateHypersonicAmmo(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyWeaponPenetration(2.f);
}

function ActivateStrongArm(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerMaxCarryWeight(3);
}

function ActivateDiazepam(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyWeaponSpreadAndRecoil(0.2f);
}

function ActivateMaximumPayne(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyWeaponZedTimeDualPistolFireRate(2.f);
    CGRI.ModifyWeaponZedTimeDualPistolExtensions(100);
    CGRI.ModifyDualWeaponMagazineAmmo(1.5f);
    CGRI.ModifyDualWeaponReloadRate(2.f);
}

function ActivatePackedShells(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyShotgunPelletCount(1.66f);
}

function ActivateSuperGrenades(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyGrenadeMaxAmmo(2.f);
    CGRI.EnableSuperGrenades();
}

function ActivateSubstitute(TurboCardReplicationInfo CGRI)
{
    class'TurboWaveEventHandler'.static.RegisterWaveHandler(CGRI, class'NegateDamageWaveEventHandler');
}

function ActivateDeepestAmmoPockets(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyWeaponMaxAmmo(1.35f);
}

function ActivateFastHands(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyWeaponEquipSpeed(0.33f);
}

function ActivateMassDetonation(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableMassDetonation();
}

defaultproperties
{
    Begin Object Name=Berserker Class=TurboCard_Super
        CardName(0)="Fist of the"
        CardName(1)="North London"
        CardDescriptionList(0)="Increases Berserker"
        CardDescriptionList(1)="on-perk melee"
        CardDescriptionList(2)="weapon firerate"
        CardDescriptionList(3)="by 200%."
        OnActivateCard=ActivateBerserker
    End Object
    DeckCardObjectList(0)=TurboCard'Berserker'
    
    Begin Object Name=Commando Class=TurboCard_Super
        CardName(0)="Commando"
        CardName(1)="Firing"
        CardName(2)="Extension"
        CardDescriptionList(0)="Increases"
        CardDescriptionList(1)="Commando on-perk"
        CardDescriptionList(2)="weapon magazine"
        CardDescriptionList(3)="size by 200%,"
        CardDescriptionList(4)="reload speed by"
        CardDescriptionList(5)="20% and max"
        CardDescriptionList(6)="ammo by 20%."
        OnActivateCard=ActivateCommando
    End Object
    DeckCardObjectList(1)=TurboCard'Commando'
    
    Begin Object Name=Firebug Class=TurboCard_Super
        CardName(0)="Fire Hazard"
        CardDescriptionList(0)="Increases Firebug"
        CardDescriptionList(1)="on-perk weapon fire"
        CardDescriptionList(2)="damage by 50%"
        CardDescriptionList(3)="and firerate by 150%."
        OnActivateCard=ActivateFirebug
    End Object
    DeckCardObjectList(2)=TurboCard'Firebug'
    
    Begin Object Name=UberMedic Class=TurboCard_Super
        CardName(0)="Uber Medic"
        CardDescriptionList(0)="Increases Field"
        CardDescriptionList(1)="Medic grenade"
        CardDescriptionList(2)="damage by 900%,"
        CardDescriptionList(3)="on-perk weapon"
        CardDescriptionList(4)="magazine size by"
        CardDescriptionList(5)="100%, and heal"
        CardDescriptionList(6)="potency by 50%."
        OnActivateCard=ActivateUberMedic
    End Object
    DeckCardObjectList(3)=TurboCard'UberMedic'
    
    Begin Object Name=FleshpoundDamage Class=TurboCard_Super
        CardName(0)="Weakened"
        CardName(1)="Fleshpounds"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="dealt to"
        CardDescriptionList(2)="Fleshpounds by 50%."
        OnActivateCard=ActivateFleshpoundDamage
    End Object
    DeckCardObjectList(4)=TurboCard'FleshpoundDamage'
    
    Begin Object Name=ScrakeDamage Class=TurboCard_Super
        CardName(0)="Anti-Chainsaw"
        CardName(1)="Coalition"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="dealt to"
        CardDescriptionList(2)="Scrakes by 50%."
        OnActivateCard=ActivateScrakeDamage
    End Object
    DeckCardObjectList(5)=TurboCard'ScrakeDamage'
    
    Begin Object Name=SuperGrenades Class=TurboCard_Super
        CardName(0)="Super Grenades"
        CardDescriptionList(0)="Increases grenade"
        CardDescriptionList(1)="carry capacity by"
        CardDescriptionList(2)="100% and increases"
        CardDescriptionList(3)="power of all"
        CardDescriptionList(4)="grenades by 100%."
        OnActivateCard=ActivateSuperGrenades
    End Object
    DeckCardObjectList(6)=TurboCard'SuperGrenades'
    
    Begin Object Name=MaxHealth Class=TurboCard_Super
        CardName(0)="Overheal"
        CardDescriptionList(0)="Increase max"
        CardDescriptionList(1)="health for all"
        CardDescriptionList(2)="players by 100%."
        OnActivateCard=ActivateMaxHealth
    End Object
    DeckCardObjectList(7)=TurboCard'MaxHealth'
    
    Begin Object Name=MovementSpeed Class=TurboCard_Super
        CardName(0)="Adrenaline"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="movement speed for"
        CardDescriptionList(2)="all players by 30%."
        OnActivateCard=ActivateMovementSpeed
    End Object
    DeckCardObjectList(8)=TurboCard'MovementSpeed'
    
    Begin Object Name=ReloadSpeed Class=TurboCard_Super
        CardName(0)="Strategic"
        CardName(1)="Reload"
        CardDescriptionList(0)="Increases all"
        CardDescriptionList(1)="weapon reload"
        CardDescriptionList(2)="speed by 50%."
        OnActivateCard=ActivateReloadSpeed
    End Object
    DeckCardObjectList(9)=TurboCard'ReloadSpeed'
    
    Begin Object Name=SirenScreemNullify Class=TurboCard_Super
        CardName(0)="Earplugs"
        CardDescriptionList(0)="Completely nullify"
        CardDescriptionList(1)="scream damage."
        OnActivateCard=ActivateSirenScreemNullify
    End Object
    DeckCardObjectList(10)=TurboCard'SirenScreemNullify'
    
    Begin Object Name=CheatDeath Class=TurboCard_Super
        CardName(0)="Cheating Death"
        CardDescriptionList(0)="All players can"
        CardDescriptionList(1)="cheat death once."
        OnActivateCard=ActivateCheatDeath
    End Object
    DeckCardObjectList(11)=TurboCard'CheatDeath'

    Begin Object Name=Unshakeable Class=TurboCard_Super
        CardName(0)="Unshakeable"
        CardDescriptionList(0)="Explosive damage"
        CardDescriptionList(1)="nullified for"
        CardDescriptionList(2)="all players."
        OnActivateCard=ActivateUnshakeable
    End Object
    DeckCardObjectList(12)=TurboCard'Unshakeable'

    Begin Object Name=BigHeadMode Class=TurboCard_Super
        CardName(0)="Big Head Mode"
        CardDescriptionList(0)="Increases the"
        CardDescriptionList(1)="size of zeds"
        CardDescriptionList(2)="heads by 100%."
        OnActivateCard=ActivateBigHeadMode
    End Object
    DeckCardObjectList(13)=TurboCard'BigHeadMode'

    Begin Object Name=HypersonicAmmo Class=TurboCard_Super
        CardName(0)="Hypersonic"
        CardName(1)="Ammunition"
        CardDescriptionList(0)="Weapon bullet"
        CardDescriptionList(1)="penetration"
        CardDescriptionList(2)="is doubled."
        OnActivateCard=ActivateHypersonicAmmo
    End Object
    DeckCardObjectList(14)=TurboCard'HypersonicAmmo'

    Begin Object Name=StrongArm Class=TurboCard_Super
        CardName(0)="Strong Arm"
        CardDescriptionList(0)="Increases max"
        CardDescriptionList(1)="carry weight"
        CardDescriptionList(2)="by 3 for all."
        CardDescriptionList(3)="players."
        OnActivateCard=ActivateStrongArm
    End Object
    DeckCardObjectList(15)=TurboCard'StrongArm'

    Begin Object Name=Diazepam Class=TurboCard_Super
        CardName(0)="Diazepam"
        CardDescriptionList(0)="Reduces spread"
        CardDescriptionList(1)="and recoil for all"
        CardDescriptionList(2)="players by 80%."
        OnActivateCard=ActivateDiazepam
    End Object
    DeckCardObjectList(16)=TurboCard'Diazepam'

    Begin Object Name=MaximumPayne Class=TurboCard_Super
        CardName(0)="Maximum Payne"
        CardDescriptionList(0)="Increases dual"
        CardDescriptionList(1)="pistol's magazine"
        CardDescriptionList(2)="size by 50% and"
        CardDescriptionList(3)="firerate/reload"
        CardDescriptionList(4)="speed during zed"
        CardDescriptionList(5)="time by 100%."
        OnActivateCard=ActivateMaximumPayne
    End Object
    DeckCardObjectList(17)=TurboCard'MaximumPayne'

    Begin Object Name=PackedShells Class=TurboCard_Super
        CardName(0)="Packed Shells"
        CardDescriptionList(0)="Increases shotgun"
        CardDescriptionList(1)="pellet count"
        CardDescriptionList(2)="by 66%."
        OnActivateCard=ActivatePackedShells
    End Object
    DeckCardObjectList(18)=TurboCard'PackedShells'

    Begin Object Name=NegateDamage Class=TurboCard_Super
        CardName(0)="Substitute"
        CardDescriptionList(0)="Negates the first"
        CardDescriptionList(1)="10 times a player"
        CardDescriptionList(2)="receives damage"
        CardDescriptionList(3)="each wave."
        OnActivateCard=ActivateSubstitute
    End Object
    DeckCardObjectList(19)=TurboCard'NegateDamage'

    Begin Object Name=DeepestAmmoPockets Class=TurboCard_Super
        CardName(0)="The Deepest of"
        CardName(1)="Ammo Pockets"
        CardDescriptionList(0)="Increases max"
        CardDescriptionList(1)="ammo by 35%."
        OnActivateCard=ActivateDeepestAmmoPockets
    End Object
    DeckCardObjectList(20)=TurboCard'DeepestAmmoPockets'

    Begin Object Name=FastHands Class=TurboCard_Super
        CardName(0)="Fastest Hands"
        CardName(1)="In The West"
        CardDescriptionList(0)="Increases weapon"
        CardDescriptionList(1)="swap speed by 66%."
        OnActivateCard=ActivateFastHands
    End Object
    DeckCardObjectList(21)=TurboCard'FastHands'

    Begin Object Name=MassDetonation Class=TurboCard_Super
        CardName(0)="Mass"
        CardName(1)="Detonation"
        CardDescriptionList(0)="Explosive kills"
        CardDescriptionList(1)="have a 10% chance"
        CardDescriptionList(2)="to trigger explosions"
        CardDescriptionList(3)="that deal 50% of"
        CardDescriptionList(4)="the killed zed's"
        CardDescriptionList(5)="max health."
        OnActivateCard=ActivateMassDetonation
    End Object
    DeckCardObjectList(22)=TurboCard'MassDetonation'

    Begin Object Name=DeEvolution Class=TurboCard_Super
        CardName(0)="De-Evolution"
        CardDescriptionList(0)="All zeds have"
        CardDescriptionList(1)="a chance to be"
        CardDescriptionList(2)="replaced with"
        CardDescriptionList(3)="weaker versions"
        CardDescriptionList(4)="of themselves."
        OnActivateCard=ActivateDeEvolution
    End Object
    DeckCardObjectList(22)=TurboCard'DeEvolution'
}