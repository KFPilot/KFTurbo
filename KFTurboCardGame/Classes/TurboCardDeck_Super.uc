//Killing Floor Turbo TurboCardDeck_Super
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck_Super extends TurboCardDeck;

var bool bCanUseCleanse, bHasUsedCleanse;
var TurboCard CleanseCard;

function InitializeDeck()
{
    local int Index;

    Super.InitializeDeck();

    Index = DeckCardObjectList.Length;

    InitializeCard(CleanseCard, Index);
    Index++;
}

static function TurboCard GetCardFromReference(TurboCardReplicationInfo.CardReference Reference)
{
    if (Reference.Deck != default.Class)
    {
        return None;
    }

    if (Reference.CardIndex == default.DeckCardObjectList.Length)
    {
        return default.CleanseCard;
    }

    return Super.GetCardFromReference(Reference);
}

function TurboCard DrawRandomCard()
{
    local int EffectiveDeckSize;
    EffectiveDeckSize = DeckCardObjectList.Length;

    if (!bCanUseCleanse && bHasUsedCleanse)
    {
        EffectiveDeckSize++;
    }

    if (!bCanUseCleanse && bHasUsedCleanse && FRand() < (1.f / float(EffectiveDeckSize)))
    {
        bHasUsedCleanse = true;
        return CleanseCard;
    }

    return Super.DrawRandomCard();
}

function OnDeckDraw(TurboCardReplicationInfo TCRI)
{
    local int GoodCardCount, SuperCardCount, ProConCardCount, EvilCardCount;
    TCRI.GetActiveCardCounts(GoodCardCount, SuperCardCount, ProConCardCount, EvilCardCount);
    bCanUseCleanse = EvilCardCount >= 2;
}

function ActivateBerserker(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerBerserkerFireRateModifier.AddModifier(3.f, Card);
    }
    else
    {
        GameplayManager.PlayerBerserkerFireRateModifier.RemoveModifier(Card);
    }
}

function ActivateCommando(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerCommandoMagazineAmmoModifier.AddModifier(2.f, Card);
        GameplayManager.PlayerCommandoReloadRateModifier.AddModifier(1.2f, Card);
        GameplayManager.PlayerCommandoMaxAmmoModifier.AddModifier(1.2f, Card);
    }
    else
    {
        GameplayManager.PlayerCommandoMagazineAmmoModifier.RemoveModifier(Card);
        GameplayManager.PlayerCommandoReloadRateModifier.RemoveModifier(Card);
        GameplayManager.PlayerCommandoMaxAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateFirebug(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFireDamageModifier.AddModifier(1.5f, Card);
        GameplayManager.PlayerFirebugFireRateModifier.AddModifier(2.f, Card);
    }
    else
    {
        GameplayManager.PlayerFireDamageModifier.RemoveModifier(Card);
        GameplayManager.PlayerFirebugFireRateModifier.RemoveModifier(Card);
    }
}

function ActivateUberMedic(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMedicGrenadeDamageModifier.AddModifier(10.f, Card);
        GameplayManager.PlayerMedicMagazineAmmoModifier.AddModifier(2.f, Card);
        GameplayManager.PlayerMedicHealPotencyModifier.AddModifier(1.5f, Card);
        GameplayManager.PlayerMedicMaxAmmoModifier.AddModifier(1.25f, Card);
    }
    else
    {
        GameplayManager.PlayerMedicGrenadeDamageModifier.RemoveModifier(Card);
        GameplayManager.PlayerMedicMagazineAmmoModifier.RemoveModifier(Card);
        GameplayManager.PlayerMedicHealPotencyModifier.RemoveModifier(Card);
        GameplayManager.PlayerMedicMaxAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateFleshpoundDamage(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFleshpoundDamageModifier.AddModifier(1.5f, Card);
    }
    else
    {
        GameplayManager.PlayerFleshpoundDamageModifier.RemoveModifier(Card);
    }
}

function ActivateScrakeDamage(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerScrakeDamageModifier.AddModifier(1.5f, Card);
    }
    else
    {
        GameplayManager.PlayerScrakeDamageModifier.RemoveModifier(Card);
    }
}

function ActivateMaxHealth(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMaxHealthModifier.AddModifier(2.f, Card);
    }
    else
    {
        GameplayManager.PlayerMaxHealthModifier.RemoveModifier(Card);
    }
}

function ActivateMovementSpeed(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMovementSpeedModifier.AddModifier(1.3f, Card);
    }
    else
    {
        GameplayManager.PlayerMovementSpeedModifier.RemoveModifier(Card);
    }
}

function ActivateReloadSpeed(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerReloadRateModifier.AddModifier(1.5f, Card);
    }
    else
    {
        GameplayManager.PlayerReloadRateModifier.RemoveModifier(Card);
    }
}

function ActivateSirenScreemNullify(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterSirenScreamDamageModifier.AddModifier(0.f, Card);
    }
    else
    {
        GameplayManager.MonsterSirenScreamDamageModifier.RemoveModifier(Card);
    }
}

function ActivateCheatDeath(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.CheatDeathFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.CheatDeathFlag.ClearFlag();
    }
}

function ActivateUnshakeable(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerExplosiveDamageTakenModifier.AddModifier(0.f, Card);
    }
    else
    {
        GameplayManager.PlayerExplosiveDamageTakenModifier.RemoveModifier(Card);
    }
}

function ActivateBigHeadMode(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterHeadSizeModifier.AddModifier(1.5f, Card);
    }
    else
    {
        GameplayManager.MonsterHeadSizeModifier.RemoveModifier(Card);
    }
}

function ActivateHypersonicAmmo(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerPenetrationModifier, 3.f, bActivate);
}

function ActivateStrongArm(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerCarryCapacityDelta.AddDelta(3, Card);
    }
    else
    {
        GameplayManager.PlayerCarryCapacityDelta.RemoveDelta(Card);
    }
}

function ActivateDiazepam(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerSpreadRecoilModifier.AddModifier(0.2f, Card);
    }
    else
    {
        GameplayManager.PlayerSpreadRecoilModifier.RemoveModifier(Card);
    }
}

function ActivateMaximumPayne(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerDualWeaponMagazineAmmoModifier, 1.5f, bActivate);

    Card.UpdateDelta(GameplayManager.PlayerDualWeaponZedTimeExtensionDelta, 100, bActivate);

    Card.UpdateModifier(GameplayManager.PlayerZedTimeDualWeaponFireRateModifier, 2.f, bActivate);
    Card.UpdateModifier(GameplayManager.PlayerZedTimeDualWeaponReloadRateModifier, 10.f, bActivate);
    Card.UpdateModifier(GameplayManager.PlayerZedTimeDualWeaponEquipRateModifier, 0.1f, bActivate);
}

function ActivatePackedShells(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerShotgunPelletModifier.AddModifier(1.5f, Card);
    }
    else
    {
        GameplayManager.PlayerShotgunPelletModifier.RemoveModifier(Card);
    }
}

function ActivateSuperGrenades(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerGrenadeMaxAmmoModifier.AddModifier(2.f, Card);
        GameplayManager.SuperGrenadesFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.PlayerGrenadeMaxAmmoModifier.RemoveModifier(Card);
        GameplayManager.SuperGrenadesFlag.ClearFlag();
    }
}

function ActivateSubstitute(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerDamageSubstituteFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.PlayerDamageSubstituteFlag.ClearFlag();
    }
}

function ActivateDeepestAmmoPockets(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMaxAmmoModifier.AddModifier(1.35f, Card);
    }
    else
    {
        GameplayManager.PlayerMaxAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateFastHands(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerEquipRateModifier.AddModifier(0.33f, Card);
    }
    else
    {
        GameplayManager.PlayerEquipRateModifier.RemoveModifier(Card);
    }
}

function ActivateMassDetonation(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMassDetonationFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.PlayerMassDetonationFlag.ClearFlag();
    }
}

function ActivateEverythingMustGo(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.TraderPriceModifier.AddModifier(0.25f, Card);
    }
    else
    {
        GameplayManager.TraderPriceModifier.RemoveModifier(Card);
    }
}

function ActivateSuppressiveFire(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFireRateModifier.AddModifier(1.66f, Card);
    }
    else
    {
        GameplayManager.PlayerFireRateModifier.RemoveModifier(Card);
    }
}

function ActivateCleanse(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.RemoveRandomEvilCard();
    }
}

function ActivateLargerBlind(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateDelta(GameplayManager.CardSelectionCountDelta, 1, bActivate);
}

function ActivateCriticalHit(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateFlag(GameplayManager.CriticalShotFlag, bActivate);
}

function ActivateTooMuchForZBlock(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerAirControlModifier, 10000.f, bActivate);
}

function ActivateDeEvolution(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateFlag(GameplayManager.WeakMonsterReplacementFlag, bActivate);
}

function ActivatePestExterminator(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerNonEliteDamageModifier, 1.66f, bActivate);
}

function ActivateBreakTime(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.TraderTimeModifier, 2.f, bActivate);
}

defaultproperties
{
    Begin Object Name=Cleanse Class=TurboCard_Super
        CardName(0)="Cleanse"
        CardDescriptionList(0)="Removes a random"
        CardDescriptionList(1)="Evil card."
        CardID="SUPER_CLEANSE"
        OnActivateCard=ActivateCleanse
    End Object
    CleanseCard=TurboCard'Cleanse'

    Begin Object Name=Berserker Class=TurboCard_Super
        CardName(0)="Fist of the"
        CardName(1)="North London"
        CardDescriptionList(0)="Increases Berserker"
        CardDescriptionList(1)="on-perk melee"
        CardDescriptionList(2)="weapon firerate"
        CardDescriptionList(3)="by 200%."
        OnActivateCard=ActivateBerserker
        CardID="SUPER_FISTOFNORTH"
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
        CardID="SUPER_CMDOFIRINGEXT"
    End Object
    DeckCardObjectList(1)=TurboCard'Commando'
    
    Begin Object Name=Firebug Class=TurboCard_Super
        CardName(0)="Fire Hazard"
        CardDescriptionList(0)="Increases Firebug"
        CardDescriptionList(1)="on-perk weapon fire"
        CardDescriptionList(2)="damage by 50%"
        CardDescriptionList(3)="and firerate by 100%."
        OnActivateCard=ActivateFirebug
        CardID="SUPER_FIREHAZARD"
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
        CardID="SUPER_UBERMEDIC"
    End Object
    DeckCardObjectList(3)=TurboCard'UberMedic'
    
    Begin Object Name=FleshpoundDamage Class=TurboCard_Super
        CardName(0)="Weakened"
        CardName(1)="Fleshpounds"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="dealt to"
        CardDescriptionList(2)="Fleshpounds by 50%."
        OnActivateCard=ActivateFleshpoundDamage
        CardID="SUPER_WEAKFP"
    End Object
    DeckCardObjectList(4)=TurboCard'FleshpoundDamage'
    
    Begin Object Name=ScrakeDamage Class=TurboCard_Super
        CardName(0)="Anti-Chainsaw"
        CardName(1)="Coalition"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="dealt to"
        CardDescriptionList(2)="Scrakes by 50%."
        OnActivateCard=ActivateScrakeDamage
        CardID="SUPER_WEAKSC"
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
        CardID="SUPER_SUPERNADES"
    End Object
    DeckCardObjectList(6)=TurboCard'SuperGrenades'
    
    Begin Object Name=MaxHealth Class=TurboCard_Super
        CardName(0)="Overheal"
        CardDescriptionList(0)="Increase max"
        CardDescriptionList(1)="health for all"
        CardDescriptionList(2)="players by 100%."
        OnActivateCard=ActivateMaxHealth
        CardID="SUPER_OVERHEAL"
    End Object
    DeckCardObjectList(7)=TurboCard'MaxHealth'
    
    Begin Object Name=MovementSpeed Class=TurboCard_Super
        CardName(0)="Adrenaline"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="movement speed for"
        CardDescriptionList(2)="all players by 30%."
        OnActivateCard=ActivateMovementSpeed
        CardID="SUPER_ADRENALINE"
    End Object
    DeckCardObjectList(8)=TurboCard'MovementSpeed'
    
    Begin Object Name=ReloadSpeed Class=TurboCard_Super
        CardName(0)="Strategic"
        CardName(1)="Reload"
        CardDescriptionList(0)="Increases all"
        CardDescriptionList(1)="weapon reload"
        CardDescriptionList(2)="speed by 50%."
        OnActivateCard=ActivateReloadSpeed
        CardID="SUPER_STRATRELOAD"
    End Object
    DeckCardObjectList(9)=TurboCard'ReloadSpeed'
    
    Begin Object Name=SirenScreemNullify Class=TurboCard_Super
        CardName(0)="Earplugs"
        CardDescriptionList(0)="Completely nullify"
        CardDescriptionList(1)="scream damage."
        OnActivateCard=ActivateSirenScreemNullify
        CardID="SUPER_EARPLUGS"
    End Object
    DeckCardObjectList(10)=TurboCard'SirenScreemNullify'
    
    Begin Object Name=CheatDeath Class=TurboCard_Super
        CardName(0)="Cheating Death"
        CardDescriptionList(0)="All players can"
        CardDescriptionList(1)="cheat death once."
        OnActivateCard=ActivateCheatDeath
        CardID="SUPER_CHEATDEATH"
    End Object
    DeckCardObjectList(11)=TurboCard'CheatDeath'

    Begin Object Name=Unshakeable Class=TurboCard_Super
        CardName(0)="Unshakeable"
        CardDescriptionList(0)="Explosive damage"
        CardDescriptionList(1)="nullified for"
        CardDescriptionList(2)="all players."
        OnActivateCard=ActivateUnshakeable
        CardID="SUPER_UNSHAKEABLE"
    End Object
    DeckCardObjectList(12)=TurboCard'Unshakeable'

    Begin Object Name=BigHeadMode Class=TurboCard_Super
        CardName(0)="Big Head Mode"
        CardDescriptionList(0)="Increases the"
        CardDescriptionList(1)="size of zeds"
        CardDescriptionList(2)="heads by 100%."
        CardID="SUPER_BIGHEADMODE"
        OnActivateCard=ActivateBigHeadMode
    End Object
    DeckCardObjectList(13)=TurboCard'BigHeadMode'

    Begin Object Name=HypersonicAmmo Class=TurboCard_Super
        CardName(0)="Hypersonic"
        CardName(1)="Ammunition"
        CardDescriptionList(0)="All weapon bullet"
        CardDescriptionList(1)="penetration"
        CardDescriptionList(2)="is tripled."
        OnActivateCard=ActivateHypersonicAmmo
        CardID="SUPER_HYPERSONICAMMO"
    End Object
    DeckCardObjectList(14)=TurboCard'HypersonicAmmo'

    Begin Object Name=StrongArm Class=TurboCard_Super
        CardName(0)="Strong Arm"
        CardDescriptionList(0)="Increases max"
        CardDescriptionList(1)="carry weight"
        CardDescriptionList(2)="by 3 for all."
        CardDescriptionList(3)="players."
        OnActivateCard=ActivateStrongArm
        CardID="SUPER_STRONGARM"
    End Object
    DeckCardObjectList(15)=TurboCard'StrongArm'

    Begin Object Name=Diazepam Class=TurboCard_Super
        CardName(0)="Diazepam"
        CardDescriptionList(0)="Reduces spread"
        CardDescriptionList(1)="and recoil for all"
        CardDescriptionList(2)="players by 80%."
        OnActivateCard=ActivateDiazepam
        CardID="SUPER_DIAZEPAM"
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
        CardID="SUPER_MAXIMUMPAYNE"
    End Object
    DeckCardObjectList(17)=TurboCard'MaximumPayne'

    Begin Object Name=PackedShells Class=TurboCard_Super
        CardName(0)="Packed Shells"
        CardDescriptionList(0)="Increases shotgun"
        CardDescriptionList(1)="pellet count"
        CardDescriptionList(2)="by 50%."
        OnActivateCard=ActivatePackedShells
        CardID="SUPER_PACKEDSHELLS"
    End Object
    DeckCardObjectList(18)=TurboCard'PackedShells'

    Begin Object Name=NegateDamage Class=TurboCard_Super
        CardName(0)="Substitute"
        CardDescriptionList(0)="Negates the first"
        CardDescriptionList(1)="10 times a player"
        CardDescriptionList(2)="receives damage"
        CardDescriptionList(3)="each wave."
        OnActivateCard=ActivateSubstitute
        CardID="SUPER_SUBSTITUTE"
    End Object
    DeckCardObjectList(19)=TurboCard'NegateDamage'

    Begin Object Name=DeepestAmmoPockets Class=TurboCard_Super
        CardName(0)="The Deepest of"
        CardName(1)="Ammo Pockets"
        CardDescriptionList(0)="Increases max"
        CardDescriptionList(1)="ammo by 35%."
        OnActivateCard=ActivateDeepestAmmoPockets
        CardID="SUPER_DEEPESTAMMOPOCKET"
    End Object
    DeckCardObjectList(20)=TurboCard'DeepestAmmoPockets'

    Begin Object Name=FastHands Class=TurboCard_Super
        CardName(0)="Fastest Hands"
        CardName(1)="In The West"
        CardDescriptionList(0)="Increases weapon"
        CardDescriptionList(1)="swap speed by 66%."
        OnActivateCard=ActivateFastHands
        CardID="SUPER_FASTHANDS"
    End Object
    DeckCardObjectList(21)=TurboCard'FastHands'

    Begin Object Name=MassDetonation Class=TurboCard_Super
        CardName(0)="Mass"
        CardName(1)="Detonation"
        CardDescriptionList(0)="Explosive kills"
        CardDescriptionList(1)="have a 25% chance"
        CardDescriptionList(2)="to trigger explosions"
        CardDescriptionList(3)="that deal 25% of"
        CardDescriptionList(4)="the killed zed's"
        CardDescriptionList(5)="max health."
        OnActivateCard=ActivateMassDetonation
        CardID="SUPER_MASSDETONATION"
    End Object
    DeckCardObjectList(22)=TurboCard'MassDetonation'

    Begin Object Name=EverythingMustGo Class=TurboCard_Super
        CardName(0)="Everything"
        CardName(1)="Must Go"
        CardDescriptionList(0)="All ammo and"
        CardDescriptionList(1)="weapons receive"
        CardDescriptionList(2)="a 75% discount."
        OnActivateCard=ActivateEverythingMustGo
        CardID="SUPER_EVERYTHINGMUSTGO"
    End Object
    DeckCardObjectList(23)=TurboCard'EverythingMustGo'

    Begin Object Name=SuppressiveFire Class=TurboCard_Super
        CardName(0)="Suppressive"
        CardName(1)="Fire"
        CardDescriptionList(0)="Increases"
        CardDescriptionList(1)="firerate of all"
        CardDescriptionList(2)="weapons by 66%."
        OnActivateCard=ActivateSuppressiveFire
        CardID="SUPER_SUPPRESSFIRE"
    End Object
    DeckCardObjectList(24)=TurboCard'SuppressiveFire'

    Begin Object Name=LargerBlind Class=TurboCard_Super
        CardName(0)="Larger Blind"
        CardDescriptionList(0)="Increases card"
        CardDescriptionList(1)="selection by 1."
        CardID="SUPER_LARGEBLIND"
        OnActivateCard=ActivateLargerBlind
    End Object
    DeckCardObjectList(25)=TurboCard'LargerBlind'

    Begin Object Name=CriticalHit Class=TurboCard_Super
        CardName(0)="Critical Hit"
        CardDescriptionList(0)="Players' 10th shots"
        CardDescriptionList(1)="and swings deal"
        CardDescriptionList(2)="150% more damage."
        CardID="SUPER_CRITICAL"
        OnActivateCard=ActivateCriticalHit
    End Object
    DeckCardObjectList(26)=TurboCard'CriticalHit'

    Begin Object Name=TooMuchForZBlock Class=TurboCard_Super
        CardName(0)="Too Much"
        CardName(1)="For zBlock"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="air control"
        CardDescriptionList(2)="significantly."
        CardID="SUPER_ZBLOCK"
        OnActivateCard=ActivateTooMuchForZBlock
    End Object
    DeckCardObjectList(27)=TurboCard'TooMuchForZBlock'

    Begin Object Name=DeEvolution Class=TurboCard_Super
        CardName(0)="De-Evolution"
        CardDescriptionList(0)="All zeds have"
        CardDescriptionList(1)="a chance to be"
        CardDescriptionList(2)="replaced with"
        CardDescriptionList(3)="weaker versions"
        CardDescriptionList(4)="of themselves."
        OnActivateCard=ActivateDeEvolution
        CardID="SUPER_DEEVOLUTION"
    End Object
    DeckCardObjectList(28)=TurboCard'DeEvolution'

    Begin Object Name=PestExterminator Class=TurboCard_Super
        CardName(0)="Pest"
        CardName(1)="Control"
        CardDescriptionList(0)="Trash zeds take"
        CardDescriptionList(1)="66% more damage."
        OnActivateCard=ActivatePestExterminator
        CardID="SUPER_EXTERMINATOR"
    End Object
    DeckCardObjectList(29)=TurboCard'PestExterminator'

    Begin Object Name=BreakTime Class=TurboCard_Super
        CardName(0)="Break Time"
        CardDescriptionList(0)="Increases trader"
        CardDescriptionList(1)="time by 100%."
        OnActivateCard=ActivateBreakTime
        CardID="SUPER_BREAKTIME"
    End Object
    DeckCardObjectList(30)=TurboCard'BreakTime'
}