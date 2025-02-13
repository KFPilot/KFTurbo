//Killing Floor Turbo P_Crawler_STA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Crawler_STA extends P_Crawler;

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmCrawler'
     DetachedLegClass=Class'KFChar.SeveredLegCrawler'
     DetachedHeadClass=Class'KFChar.SeveredHeadCrawler'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'
     AmbientSound=Sound'KF_BaseCrawler.Crawler_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip.Crawler_Freak'
     Skins(0)=Combiner'KF_Specimens_Trip_T.crawler_cmb'
}
