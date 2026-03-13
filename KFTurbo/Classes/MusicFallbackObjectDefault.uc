//Killing Floor Turbo MusicFallbackObjectDefault
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MusicFallbackObjectDefault extends MusicFallbackObject;

defaultproperties
{
    //Departed
    Begin Object name=MusicPackOne class=MusicFallbackPack
        PackName="Departed"
        CombatMusicList=("KF_Containment","KF_Pathogen","KF_WPrevention","KF_Infectious_Cadaver","KF_WPrevention","KF_Pathogen","KF_Infectious_Cadaver","KF_Pathogen","KF_Infectious_Cadaver","KF_Containment")
        CalmMusicList=("KF_Peripheral")
    End object

    //BioticsLab
    Begin Object name=MusicPackTwo class=MusicFallbackPack
        PackName="BioticsLab"
        CombatMusicList=("KFSIN6")
        CalmMusicList=("KF_Mutagen")
    End Object

    //Biohazard
    Begin Object name=MusicPackThree class=MusicFallbackPack
        PackName="Biohazard"
        CombatMusicList=("DirgeRepulse1","KF_Pathogen","DirgeDefective2","KF_Containment","KF_Abandon","DirgeRepulse2","KF_Pathogen","DirgeDefective1","KF_Containment","DirgeRepulse1","KF_AbandonV3")
        CalmMusicList=("KF_Defection","KF_Defection","KF_Defection","KF_Defection","KF_Defection","KF_Defection","KF_Defection","KF_Defection","KF_Defection","KF_Defection","KF_Insect")
    End Object

    //Aperture
    Begin Object name=MusicPackFour class=MusicFallbackPack
        PackName="Aperture"
        CombatMusicList=("KF_BledDry","KF_BledDry","DirgeDefective1","DirgeDisunion1","DirgeDisunion2","DirgeRepulse1","DirgeRepulse2","DirgeDefective1","DirgeDefective1","DirgeDisunion1","DirgeDisunion1","DirgeDisunion1")
        CalmMusicList=("KF_SinSoma","KF_SinSoma","KF_SinSoma","KF_SinSoma","KF_TheStitches","KF_TheStitches","KF_TheStitches","KF_TheStitches","KF_TheStitches","KF_TheStitches","KF_TheStitches","KF_TheStitches")
    End Object
    
    //Wyre
    Begin Object name=MusicPackFive class=MusicFallbackPack
        PackName="Wyre"
        CombatMusicList=("KF_Defection")
        CalmMusicList=("KF_Mutagen")
    End Object
    
    //HospitalHorrors
    Begin Object name=MusicPackSix class=MusicFallbackPack
        PackName="HospitalHorrors"
        CombatMusicList=("DirgeRepulse1","KF_Pathogen","DirgeDefective2","KF_Containment","KF_Abandon","DirgeRepulse2","KF_Pathogen","DirgeDefective1","KF_Containment","DirgeRepulse1")
        CalmMusicList=("KF_Treatments")
    End Object

    PackList(0)=MusicFallbackPack'MusicPackOne'
    PackList(1)=MusicFallbackPack'MusicPackTwo'
    PackList(2)=MusicFallbackPack'MusicPackThree'
    PackList(3)=MusicFallbackPack'MusicPackFour'
    PackList(4)=MusicFallbackPack'MusicPackFive'
    PackList(5)=MusicFallbackPack'MusicPackSix'
}
