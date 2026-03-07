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

    if (MusicTrigger != None || MusicFallbackObject == None || MusicFallbackObject.PackList.Length == 0)
    {
        return;
    }

    MusicFallbackPack = MusicFallbackObject.PackList[Rand(MusicFallbackObject.PackList.Length)];
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
        return MusicFallbackPack.CombatMusicList[Wave % MusicFallbackPack.CombatMusicList.Length];
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

    if (MusicFallbackPack != None)
    {
        return MusicFallbackPack.CalmMusicList[Wave % MusicFallbackPack.CalmMusicList.Length];
    }

    return "";
}

defaultproperties
{
    Begin Object name=DefaultMusicFallback class=MusicFallbackObjectDefault
    End Object
    MusicFallbackObject=MusicFallbackObject'DefaultMusicFallback'
}