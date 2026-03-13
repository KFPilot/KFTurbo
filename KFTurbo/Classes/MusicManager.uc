//Killing Floor Turbo MusicManager
//Used to allow for different ways of selecting music without needing to subclass GameInfo.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MusicManager extends Object;

var MusicFallbackObject MusicFallbackObject;
var MusicFallbackPack MusicFallbackPack;

function Initialize(KFTurboGameType GameType)
{
    local KFMusicTrigger MusicTrigger;

    if (GameType == None || MusicFallbackObject == None)
    {
        return;
    }

    foreach GameType.DynamicActors(class'KFMusicTrigger', MusicTrigger)
    {
        break;
    }

    if (MusicTrigger != None || MusicFallbackObject.PackList.Length == 0)
    {
        return;
    }

    MusicFallbackPack = MusicFallbackObject.PackList[Rand(MusicFallbackObject.PackList.Length)];
    log("Turbo Music Manager detected no KFMusicTrigger and has selected"@MusicFallbackPack.PackName@"as a substitute map music pack.");
}

function bool IsBossWave(KFTurboGameType GameType, int Wave)
{
    return GameType != None && Wave == GameType.FinalWave;
}

function string GetCombatSong(KFTurboGameType GameType, int Wave)
{
    local string Song;
    if (GameType != None && GameType.MapSongHandler != None)
    {
        if (GameType.MapSongHandler.WaveBasedSongs.Length != 0)
        {
            Song = GameType.MapSongHandler.WaveBasedSongs[Wave % GameType.MapSongHandler.WaveBasedSongs.Length].CombatSong;
        }
        
        if (Song == "")
        {
            return GameType.MapSongHandler.CombatSong;
        }

        return Song;
    }

    if (MusicFallbackPack != None)
    {
        if (MusicFallbackPack.BossMusicList.Length != 0 && IsBossWave(GameType, Wave))
        {
            return MusicFallbackPack.BossMusicList[Rand(MusicFallbackPack.BossMusicList.Length)];
        }
        else if (MusicFallbackPack.CombatMusicList.Length != 0)
        {
            return MusicFallbackPack.CombatMusicList[Wave % MusicFallbackPack.CombatMusicList.Length];
        }
    }

    return "";
}

function string GetCalmSong(KFTurboGameType GameType, int Wave)
{
    local string Song;
    if (GameType != None && GameType.MapSongHandler != None)
    {
        if (GameType.MapSongHandler.WaveBasedSongs.Length != 0)
        {
            Song = GameType.MapSongHandler.WaveBasedSongs[Wave % GameType.MapSongHandler.WaveBasedSongs.Length].CalmSong;
        }

        if (Song == "")
        {
            return GameType.MapSongHandler.Song;
        }

        return Song;
    }

    if (MusicFallbackPack != None && MusicFallbackPack.CalmMusicList.Length != 0)
    {
        return MusicFallbackPack.CalmMusicList[Wave % MusicFallbackPack.CalmMusicList.Length];
    }

    return "";
}

function float GetFadeInTime(KFTurboGameType GameType)
{
    if (GameType != None && GameType.MapSongHandler != None)
    {
        return GameType.MapSongHandler.FadeInTime;
    }

    if (MusicFallbackPack != None)
    {
        return MusicFallbackPack.MusicFadeInTime;
    }

    return class'MusicFallbackPack'.default.MusicFadeInTime;
}

function float GetFadeOutTime(KFTurboGameType GameType)
{
    if (GameType != None && GameType.MapSongHandler != None)
    {
        return GameType.MapSongHandler.FadeOutTime;
    }

    if (MusicFallbackPack != None)
    {
        return MusicFallbackPack.MusicFadeOutTime;
    }

    return class'MusicFallbackPack'.default.MusicFadeOutTime;
}

//Moved this here because someone might want to alter how this works.
function PlayMusic(KFTurboGameType GameType, KFPlayerController Target, bool bCombat, string Song)
{
    if (Target == None)
    {
        return;
    }

    Target.NetPlayMusic(Song, GetFadeInTime(GameType), GetFadeOutTime(GameType));
}

defaultproperties
{
    Begin Object name=DefaultMusicFallback class=MusicFallbackObjectDefault
    End Object
    MusicFallbackObject=MusicFallbackObject'DefaultMusicFallback'
}