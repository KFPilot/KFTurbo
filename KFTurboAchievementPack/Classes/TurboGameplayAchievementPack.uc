class TurboGameplayAchievementPack extends TurboAchievementPackImpl;

//Achievement IDs
const VLAD_STUN_SCRAKE_20 = 0;
const COMBATSHOTGUN_KILL_50 = 1;
const M99_XBOW_KILL_FATHEAD_5 = 2;

const MAGNUM_9_HEADSHOT_5 = 3;
const M14_HEADSHOT_20 = 4;
const BULLPUP_HEADSHOT_PIERCE_50 = 5;

const FNFAL_HUSK_HEADSHOT_20 = 6;
const M4203_BLUNT_SCRAKE_5 = 7;
const ORCA_3500_DAMAGE_3 = 8;

const M7A3_KILL_SCRAKE_10 = 9;
const TAKE_DAMAGE_10000 = 10;
const CHAINSAW_KILL_SCRAKE = 11;

const SCYTHE_4_KILL_5 = 12;
const MEDIC_GAME = 13;

const PAT_MELEE_KILL = 14;
const PAT_KNIFE_KILL = 15;
const CAROLER_HS_KILL = 16;

const MCZ_THROW_SCRAKE_20 = 17;
const STATIS_GRENADE_SIREN_15 = 18;
const SEAL_SQUEAL_3_PATRIARCH_5 = 19;
const HEAL_NEAR_DEATH = 20;
const PREVENT_DAMAGE_FIRE_500 = 21;
const IGNITE_ZEDS_3500 = 22;
const ZERK_CLASSY_KILL_25 = 23;
const JUMPER_AIRSHOT_KILL_5 = 24;

var Pawn LastVladStunnedScrake;

var int CombatShotgunKills;

struct HeadshotCache
{
    var int Count;
    var float LastHeadshotTime;
};

struct M14HeadshotData
{
    var HeadshotCache HeadshotData;
};

var M14HeadshotData M14Headshot;

struct MagnumHeadshotData
{
    var Pawn LastHitPawn;
    var HeadshotCache HeadshotData;
};
var MagnumHeadshotData MagnumHeadshot;

var float LastBullpupHeadshotTime;

var bool bCanEarnMedicGame;

var float LastOrcaDamageTime;

struct ScytheKillData
{
    var float LastDamageTime;
    var int HitCount;
};
var ScytheKillData ScytheKill;

var array<Pawn> PushedScrakeList;

var bool bPatriarchHarpoonCountNeedsReset;

//===============
// ACHIEVEMENT GAMEPLAY EVENTS

function MatchStarting()
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    bCanEarnMedicGame = class'VeterancyChecks'.static.isFieldMedic(KFPlayerReplicationInfo(OwnerController.PlayerReplicationInfo));
}

event MatchEnd(string mapname, float difficulty, int length, byte result, int waveNum)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (Result == 2 && bCanEarnMedicGame && !IsAchievementComplete(MEDIC_GAME))
    {
        achievementCompleted(MEDIC_GAME);
    }
}

event WaveStart(int waveNum)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    ResetCombatShotgunKills();
    ResetMagnumHeadshots();
    ResetM14Headshots();
    
    if (bCanEarnMedicGame && !class'VeterancyChecks'.static.isFieldMedic(KFPlayerReplicationInfo(OwnerController.PlayerReplicationInfo)))
    {
        bCanEarnMedicGame = false;
    }
}

event WaveEnd(int waveNum)
{

}

event PlayerDamaged(int Damage, Pawn Instigator, class<DamageType> DamageType)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (!IsAchievementComplete(TAKE_DAMAGE_10000))
    {
        addProgress(TAKE_DAMAGE_10000, Damage);
        return;
    }
}

event playerDied(Controller killer, class<DamageType> DamageType, int waveNum)
{

}

event FiredWeapon(KFWeapon Weapon)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (W_Magnum44_Weap(Weapon) == None && W_Dual44_Weap(Weapon) == None)
    {
        //log("Magnum - Not a magnum reset");
        ResetMagnumHeadshots();
    }
    else if (MagnumHeadshot.HeadshotData.LastHeadshotTime + 0.1f < Level.TimeSeconds) //Detect misses.
    {
        //log("Magnum - Not a headshot reset");
        ResetMagnumHeadshots();
    }

    if (W_M14_Weap(Weapon) == None)
    {
        ResetM14Headshots();
    }
    else if (M14headshot.HeadshotData.LastHeadshotTime + 0.1f < Level.TimeSeconds)
    {
        ResetM14Headshots();
    }
}

event ReloadedWeapon(KFWeapon weapon)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (M14EBRBattleRifle(Weapon) != None)
    {
        ResetM14Headshots();
    }
    else if (W_Magnum44_Weap(Weapon) != None || W_Dual44_Weap(Weapon) != None)
    {
        //log("Magnum - Reload reset");
        ResetMagnumHeadshots();
    }
}

event KilledMonster(Pawn Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (bCanEarnMedicGame)
    {
        bCanEarnMedicGame = false;
    }

    if (class<DamTypeBenelli>(DamageType) != None)
    {
        IncrementCombatShotgunKills();
    }

    if (P_Scrake(Target) != None)
    {
        KilledScrake(P_Scrake(Target), DamageType, bHeadshot);
    }
    else if (P_Husk(Target) != None)
    {
        KilledHusk(P_Husk(Target), DamageType, bHeadShot);
    }
    else if (P_Siren(Target) != None)
    {
        KilledSiren(P_Siren(Target), DamageType, bHeadshot);
    }
    else if (P_Gorefast_Classy(Target) != None)
    {
        KilledClassyGorefast(P_Gorefast_Classy(Target), class<KFWeaponDamageType>(DamageType), bHeadshot);
    }
    else if (P_Crawler_Jumper(Target) != None)
    {
        KilledJumperCrawler(P_Crawler_Jumper(Target), class<KFWeaponDamageType>(DamageType), bHeadshot);
    }
    else if (P_ZombieBoss(Target) != None)
    {
        KilledBoss(P_ZombieBoss(Target), class<KFWeaponDamageType>(DamageType), bHeadshot);
    }
}

event DamagedMonster(int Damage, Pawn Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (bHeadshot)
    {
        if (class<DamTypeBullpup>(DamageType) != None)
        {
            AddPeircingBullpupHeadshot(Target);
        }

        if (class<DamTypeM14EBR>(DamageType) != None)
        {
            IncrementM14Headshots();
        }
    }

    if (P_Scrake(Target) != None)
    {
        DamagedScrake(Damage, P_Scrake(Target), DamageType, bHeadshot);
    }
    else if (P_Husk(Target) != None)
    {
        DamagedHusk(Damage, P_Husk(Target), DamageType, bHeadshot);
    }
    else if (P_Bloat_Fathead(Target) != None)
    {
        DamagedFathead(Damage, P_Bloat_Fathead(Target), DamageType, bHeadShot);
    }

    CheckScytheHit(DamageType);

    CheckOrcaDamage(Damage, Target, DamageType, bHeadShot);

    CheckMagnumReset(Target, DamageType, bHeadshot);
}

event OnPawnIgnited(Pawn Target, class<KFWeaponDamageType> DamageType, int BurnDamage)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (BurnDamage <= 0 || Target.Health <= 0)
    {
        return;
    }

    AddProgress(IGNITE_ZEDS_3500, 1);
}

event OnPawnZapped(Pawn Target, float ZapAmount, bool bCausedZapped)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }
    
    if (!bCausedZapped)
    {
        return;
    }

    if (!IsAchievementComplete(STATIS_GRENADE_SIREN_15) && P_Siren(Target) != None)
    {
        AddProgress(STATIS_GRENADE_SIREN_15, 1);
    }
}

event OnPawnHarpooned(Pawn Target, int CurrentHarpoonCount)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }
    
    if (!IsAchievementComplete(SEAL_SQUEAL_3_PATRIARCH_5) && ZombieBoss(Target) != None)
    {
        if (bPatriarchHarpoonCountNeedsReset && CurrentHarpoonCount <= 1)
        {
            bPatriarchHarpoonCountNeedsReset = false;
        }

        if (CurrentHarpoonCount >= 3)
        {
            bPatriarchHarpoonCountNeedsReset = true;
            AddProgress(SEAL_SQUEAL_3_PATRIARCH_5, 1);
        }
    }
}

event OnPawnHealed(Pawn Target, int HealingAmount)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }
    
    if (IsAchievementComplete(HEAL_NEAR_DEATH) || Target.Health > 1)
    {
        return;
    }

    AddProgress(HEAL_NEAR_DEATH, 1);
}

event OnBurnMitigatedDamage(Pawn Target, int Damage, int MitigatedDamage)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }
    
    if (IsAchievementComplete(PREVENT_DAMAGE_FIRE_500) || Target.Health <= 0)
    {
        return;
    }

    AddProgress(PREVENT_DAMAGE_FIRE_500, MitigatedDamage);
}

event OnPawnPushedWithMCZThrower(Pawn Target, Vector VelocityAdded)
{
    local int Index;
    
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    if (!IsAchievementComplete(MCZ_THROW_SCRAKE_20) && P_Scrake(Target) != None)
    {
        for (Index = PushedScrakeList.Length - 1; Index >= 0; Index--)
        {
            if (PushedScrakeList[Index] == None)
            {
                PushedScrakeList.Remove(Index, 1);
            }
            else if (PushedScrakeList[Index] == Target)
            {
                return;
            }
        }

        PushedScrakeList[PushedScrakeList.Length] = Target;
        AddProgress(MCZ_THROW_SCRAKE_20, 1);
    }
}

//===============
// Zed-Specific Kill Events

function KilledScrake(P_Scrake Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (class<W_M4203_Impact_DT>(DamageType) != None)
    {
        IncrementM4203BluntKills(Target);
    }
    else if (class<DamTypeM7A3M>(DamageType) != None)
    {
        if (!IsAchievementComplete(M7A3_KILL_SCRAKE_10) && bHeadshot)
        {
            AddProgress(M7A3_KILL_SCRAKE_10, 1);
        }
    }
}
function KilledHusk(P_Husk Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (bHeadshot && class<W_FNFAL_DT>(DamageType) != None)
    {
        AddHuskFNFALKill();
    }
}

function KilledSiren(P_Siren Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (!IsAchievementComplete(CAROLER_HS_KILL) && bHeadshot && P_Siren_Caroler(Target) != None )
    {
        addProgress(CAROLER_HS_KILL, 1);
    }
}

function KilledBoss(P_ZombieBoss Target, class<KFWeaponDamageType> DamageType, bool bHeadshot)
{
    if (DamageType != None && DamageType.default.bIsMeleeDamage)
    {
        if (!IsAchievementComplete(PAT_MELEE_KILL))
        {
            achievementCompleted(PAT_MELEE_KILL);
        }

        if (!IsAchievementComplete(PAT_KNIFE_KILL) && class<DamTypeKnife>(DamageType) != None)
        {
            achievementCompleted(PAT_KNIFE_KILL);
        }
    }
}

function KilledClassyGorefast(P_Gorefast_Classy Target, class<KFWeaponDamageType> DamageType, bool bHeadshot)
{
    if (IsAchievementComplete(ZERK_CLASSY_KILL_25) || DamageType == None || !DamageType.default.bIsMeleeDamage || !bHeadshot)
    {
        return;
    }
    
    if (ownerController == None || ownerController.PlayerReplicationInfo == None || KFPlayerReplicationInfo(ownerController.PlayerReplicationInfo) == None)
    {
        return;
    }

    if (KFPlayerReplicationInfo(ownerController.PlayerReplicationInfo).ClientVeteranSkill != class'V_Berserker')
    {
        return;
    }

    AddProgress(ZERK_CLASSY_KILL_25, 1);
}

function KilledJumperCrawler(P_Crawler_Jumper Target, class<KFWeaponDamageType> DamageType, bool bHeadshot)
{
    if (IsAchievementComplete(JUMPER_AIRSHOT_KILL_5))
    {
        return;
    }

    if (Target.Physics != PHYS_Falling)
    {
        return;
    }

    AddProgress(JUMPER_AIRSHOT_KILL_5, 1);
}

//===============
// Zed-Specific Damage Events

function DamagedScrake(int Damage, P_Scrake Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (class<W_NailGun_DT>(DamageType) != None)
    {
        AddVladStuns(Target, Damage, bHeadshot);
    }
    else if (class<DamTypeMagnum44Pistol>(DamageType) != None)
    {
        if (!IsAchievementComplete(MAGNUM_9_HEADSHOT_5) && bHeadshot)
        {
            AddMagnumHeadshot(Target);
        }
    }
}

function DamagedHusk(int Damage, P_Husk Target, class<DamageType> DamageType, bool bHeadshot)
{

}

function DamagedFathead(int Damage, P_Bloat_FatHead Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (bHeadshot && Target.Health >= int(Target.HealthMax) && Target.Health <= Damage && (class<DamTypeM99HeadShot>(DamageType) != None
        || class<DamTypeCrossbowHeadShot>(DamageType) != None))
    {
        IncrementFatHeadKills();
    }
}

//===============
// Achievement Code

function IncrementCombatShotgunKills()
{
    if (!IsAchievementComplete(COMBATSHOTGUN_KILL_50))
    {
        CombatShotgunKills++;

        if (CombatShotgunKills >= 50)
        {
            AchievementCompleted(COMBATSHOTGUN_KILL_50);
        }
    }
}

function ResetCombatShotgunKills()
{
    CombatShotgunKills = 0;
}

function IncrementM4203BluntKills(Pawn Target)
{
    if (IsAchievementComplete(M4203_BLUNT_SCRAKE_5))
    {
        return;
    }

    if (OwnerController.Pawn == None || (VSizeSquared(OwnerController.Pawn.Location - Target.Location)) > (96.f * 96.f))
    {
        return;
    }
    
    AddProgress(M4203_BLUNT_SCRAKE_5, 1);
}

function IncrementM14Headshots()
{
    if (IsAchievementComplete(M14_HEADSHOT_20))
    {
        return;
    }

    M14Headshot.HeadshotData.LastHeadshotTime = Level.TimeSeconds;
    M14Headshot.HeadshotData.Count++;

    if (M14Headshot.HeadshotData.Count >= 20)
    {
        AddProgress(M14_HEADSHOT_20, 1);
        ResetM14Headshots();
    }
}

function ResetM14Headshots()
{
    if (IsAchievementComplete(M14_HEADSHOT_20))
    {
        return;
    }

    M14Headshot.HeadshotData.Count = 0;
}

function IncrementFatHeadKills()
{
    if (IsAchievementComplete(M99_XBOW_KILL_FATHEAD_5))
    {
        return;
    }

    AddProgress(M99_XBOW_KILL_FATHEAD_5, 1);
}

function AddVladStuns(Pawn Target, int Damage, bool bHeadshot)
{
    if (IsAchievementComplete(VLAD_STUN_SCRAKE_20))
    {
        return;
    }

    if (LastVladStunnedScrake == Target)
    {
        return;
    }

    if (!bHeadshot)
    {
        return;
    }

    if (Damage > Target.Health || (Damage < (float(Target.default.Health) / 1.5f)))
    {
        return;
    }

    LastVladStunnedScrake = Target;
    AddProgress(VLAD_STUN_SCRAKE_20, 1);
}

function AddMagnumHeadshot(Pawn Target)
{
    if (MagnumHeadshot.LastHitPawn != Target)
    {
        MagnumHeadshot.LastHitPawn = Target;
        MagnumHeadshot.HeadshotData.Count = 0;
    }
    
    //log("Increment Magnum");
    MagnumHeadshot.HeadshotData.Count++;
    MagnumHeadshot.HeadshotData.LastHeadshotTime = Level.TimeSeconds;

    if (MagnumHeadshot.HeadshotData.Count >= 9)
    {
        AddProgress(MAGNUM_9_HEADSHOT_5, 1);
        MagnumHeadshot.HeadshotData.Count = 0;
    }
}

function ResetMagnumHeadshots()
{
    if (IsAchievementComplete(MAGNUM_9_HEADSHOT_5))
    {
        return;
    }

    MagnumHeadshot.LastHitPawn = None;
    MagnumHeadshot.HeadshotData.Count = 0;
}

function AddPeircingBullpupHeadshot(Pawn Target)
{
    if (LastBullpupHeadshotTime != Level.TimeSeconds)
    {
        LastBullpupHeadshotTime = Level.TimeSeconds;
        return;
    }
    
    AddProgress(BULLPUP_HEADSHOT_PIERCE_50, 1);
}

function CheckOrcaDamage(int Damage, Pawn Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (LastOrcaDamageTime < Level.TimeSeconds && Damage >= 3500 && class<DamTypeSPGrenade>(DamageType) != None)
    {
        if (!IsAchievementComplete(ORCA_3500_DAMAGE_3))
        {
            LastOrcaDamageTime = Level.TimeSeconds + 1.f;
            AddProgress(ORCA_3500_DAMAGE_3, 1);
        }
    }
}

function CheckMagnumReset(Pawn Target, class<DamageType> DamageType, bool bHeadshot)
{
    if (IsAchievementComplete(MAGNUM_9_HEADSHOT_5))
    {
        return;
    }

    //If not headshot, not scrake, or not magnum damage, reset Magnum headshot.
    if (!bHeadshot)
    {
        //log("Magnum - Not a magnum reset");
        ResetMagnumHeadshots();
    }
    else if (P_Scrake(Target) == None)
    {
        ResetMagnumHeadshots();
    }
    else if (class<DamTypeMagnum44Pistol>(DamageType) == None && class<DamTypeDual44Magnum>(DamageType) == None)
    {
        ResetMagnumHeadshots();
    }
}

function AddHuskFNFALKill()
{
    if (IsAchievementComplete(FNFAL_HUSK_HEADSHOT_20))
    {
        return;
    }

    AddProgress(FNFAL_HUSK_HEADSHOT_20, 1);
}

function CheckScytheHit(class<DamageType> DamageType)
{
    if (IsAchievementComplete(SCYTHE_4_KILL_5))
    {
        return;
    }

    if (class<W_Scythe_DT>(DamageType) == None)
    {
        return;
    }

    if (ScytheKill.LastDamageTime != Level.TimeSeconds)
    {
        ScytheKill.LastDamageTime = Level.TimeSeconds;
        ScytheKill.HitCount = 0;
    }

    ScytheKill.HitCount++;

    if (ScytheKill.HitCount >= 4)
    {
        ScytheKill.LastDamageTime = 0.f;
        AddProgress(SCYTHE_4_KILL_5, 1);
    }
}

defaultproperties
{
    packName="KFTurbo Gameplay Achievements"

    Achievements(0)=(title="Vlad 9000 Stunner",Description="Stun 20 Scrakes with the Vlad 9000",MaxProgress=20,NotifyIncrement=0.25f,image=Texture'KFTurbo.Achievement.VLADSTUN_D')
    Achievements(1)=(title="Combat Shotgun Expert",Description="Kill 50 zeds with the Combat Shotgun within a single wave",image=Texture'KFTurbo.Achievement.COMBATSHOTGUNKILL_D')
    Achievements(2)=(title="Fathead Destroyer",Description="Kill a Fathead with one hit using the M99 or XBow 5 times",MaxProgress=5,image=Texture'KFTurbo.Achievement.FATHEADKILL_D')

    Achievements(3)=(title="Double Six Shooter",Description="Land 9 consecutive headshots on a Scrake with the Magnum 5 times",MaxProgress=5,image=Texture'KFTurbo.Achievement.MAGNUMHEADSHOT_D')
    Achievements(4)=(title="M14 Professional",Description="Land 20 headshots with the M14 without reloading 5 times",MaxProgress=5,NotifyIncrement=1.5f,image=Texture'KFTurbo.Achievement.M14PRO_D')
    Achievements(5)=(title="Precise Piercing Bullpup",Description="Land 100 piercing headshots with the Bullpup",MaxProgress=100,NotifyIncrement=0.2f,image=Texture'KFTurbo.Achievement.BULLPUPPIERCE_D')

    Achievements(6)=(title="Husk Hunter",Description="Kill 20 Husks with the FNFAL",MaxProgress=20,NotifyIncrement=0.25f,image=Texture'KFTurbo.Achievement.FNFALHUSK_D')
    Achievements(7)=(title="M4203 Blunt Shot Pro",Description="Kill a Scrake with an unexploded grenade from the M4203 grenade launcher 5 times",MaxProgress=5,image=Texture'KFTurbo.Achievement.M4203SCRAKE_D')
    Achievements(8)=(title="Orca Trickshot",Description="Deal 3500 damage with a single bomb with the Orca Bomb Propeller 3 times",MaxProgress=3,image=Texture'KFTurbo.Achievement.ORCADAMAGE_D')

    Achievements(9)=(title="M7A3 Professional",Description="Kill a Scrake with a headshot from the M7A3 10 times.",MaxProgress=10,NotifyIncrement=0.5f,image=Texture'KFTurbo.Achievement.M7A7SCRAKE_D')
    Achievements(10)=(title="Tanker",Description="Receive 10000 damage",MaxProgress=10000,NotifyIncrement=0.05f,image=Texture'KFTurbo.Achievement.TANKER_D')
    Achievements(11)=(title="Chainsaw of Irony",Description="Kill a Scrake with only chainsaw headshots",image=Texture'KFTurbo.Achievement.CHAINSAW_SCRAKE_D')

    Achievements(12)=(title="Wide Reception",Description="Kill 4 zeds with a single Sycthe swing 5 times",MaxProgress=5,NotifyIncrement=1.5f,image=Texture'KFTurbo.Achievement.SCYTHEMULTI_D')
    Achievements(13)=(title="Field Medic Enjoyer",Description="Play a game as Field Medic without killing a single zed",image=Texture'KFTurbo.Achievement.MEDICGAME_D')

    Achievements(14)=(title="Solving disputes in (West) London",Description="Land the killing blow on the Patriarch with a melee weapon",image=Texture'KFTurbo.Achievement.MELEEPAT_D')
    Achievements(15)=(title="Are you kidding me?",Description="Land the killing blow on the Patriarch with the Knife",image=Texture'KFTurbo.Achievement.KNIFEPAT_D')
    Achievements(16)=(title="I hate Christmas",Description="Kill 10 Caroler Sirens with headshots",MaxProgress=10,NotifyIncrement=0.5f,image=Texture'KFTurbo.Achievement.CAROLERKILLS_D')

    Achievements(17)=(title="Scrake Pusher",Description="Push 20 Scrakes with the MCZ Thrower",MaxProgress=20,NotifyIncrement=0.25f,image=Texture'KFTurbo.Achievement.MCZ_SCRAKE_D')
    Achievements(18)=(title="Performance Anxiety",Description="Inflict a Siren with Statis 15 times",MaxProgress=15,NotifyIncrement=0.2f,image=Texture'KFTurbo.Achievement.ZAPSIREN_D')
    Achievements(19)=(title="Patriarch Pin Cusion",Description="Stick a Patriarch with 3 Seal Squeal projectiles 5 times",MaxProgress=5,image=Texture'KFTurbo.Achievement.SEALSQUEALPAT_D')
    Achievements(20)=(title="Life Saver",Description="Heal a player with 1HP remaining",image=Texture'KFTurbo.Achievement.HEALNEARDEAD_D')
    Achievements(21)=(title="Fire is for Friends",Description="Mitigate 500 damage taken by others by setting zeds on fire",MaxProgress=500,NotifyIncrement=0.2f,image=Texture'KFTurbo.Achievement.PREVENTDAMAGEFIRE_D')
    Achievements(22)=(title="Ignition",Description="Ignite 3500 zeds",MaxProgress=3500,NotifyIncrement=0.15f,image=Texture'KFTurbo.Achievement.IGNITE_D')
    Achievements(23)=(title="The Sword is Mightier than The Hat",Description="Kill 25 Classy Gorefasts as Berserker",MaxProgress=25,NotifyIncrement=0.2f,image=Texture'KFTurbo.Achievement.ZERKCLASSYKILL_D')
    Achievements(24)=(title="Duck Hunt",Description="Kill a Raptor Crawler while it is airborne 5 times",MaxProgress=5,image=Texture'KFTurbo.Achievement.JUMPERAIRSHOT_D')
}