//Killing Floor Turbo MusicFallbackPack
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MusicFallbackPack extends Object;

var string PackName;
var array<string> CombatMusicList;
var array<string> CalmMusicList;
var array<string> BossMusicList;
var float MusicFadeInTime;
var float MusicFadeOutTime;

defaultproperties
{
    MusicFadeInTime=3.f
    MusicFadeOutTime=3.f

    BossMusicList=("KF_Abandon","KF_AbandonV3","KF_BledDry","KF_Containment")
}