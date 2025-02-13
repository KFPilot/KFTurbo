//Killing Floor Turbo P_ZombieBoss_XMAS
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_ZombieBoss_XMAS extends P_ZombieBoss;

// Speech notifies called from the anims
function PatriarchKnockDown()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_KnockedDown', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchEntrance()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Entrance', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchVictory()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Victory', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchMGPreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_WarnGun', SLOT_Misc, 2.0,true,1000.0);
}

function PatriarchMisslePreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_WarnRocket', SLOT_Misc, 2.0,true,1000.0);
}

// Taunt to use when doing the melee exploit radial attack
function PatriarchRadialTaunt()
{
    if( NumNinjas > 0 && NumNinjas > NumLumberJacks )
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_TauntNinja', SLOT_Misc, 2.0,true,500.0);
    }
    else if( NumLumberJacks > 0 && NumLumberJacks > NumNinjas )
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_TauntLumberJack', SLOT_Misc, 2.0,true,500.0);
    }
    else
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_TauntRadial', SLOT_Misc, 2.0,true,500.0);
    }
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.gatling_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gatling_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.gatling_D');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.PatGungoInvisible_cmb');

	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_Santa_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.patriarch_Santa_Diff');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible_gun');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_fizzle_FB');
    //myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.Patriarch_Gore_Limbs_Diff');
    //myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.Patriarch_Gore_Limbs_Spec');
 }

defaultproperties
{
	CloakedSkinList(0) = Shader'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_santa_invisible_shdr';
    CloakedSkinList(1) = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';
    HelpMeSound=Sound'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_SaveMe'

    RocketFireSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_FireRocket'
    MiniGunFireSound=Sound'KF_BasePatriarch_xmas.Attack.Kev_MG_GunfireLoop'
    MiniGunSpinSound=Sound'KF_BasePatriarch_xmas.Attack.Kev_MG_TurbineFireLoop'
    MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_HitPlayer_Impale'
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_HitPlayer_Fist'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Jump'
    DetachedArmClass=Class'KFChar.SeveredArmPatriarch_XMas'
    DetachedLegClass=Class'KFChar.SeveredLegPatriarch_XMas'
    DetachedHeadClass=Class'KFChar.SeveredHeadPatriarch_XMas'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Death'
    MenuName="Christmas Patriarch"
    AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_IdleLoop'
    Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.SantaClause_Patriarch'
    Skins(0)=Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_Santa_cmb'
    Skins(1)=Combiner'KF_Specimens_Trip_XMAS_T.gatling_cmb'
}
