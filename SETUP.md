# Setup
### Initial Setup
For starters, make sure [Server Perks](https://forums.tripwireinteractive.com/index.php?threads/mut-per-server-stats.36898/) and [Server Achievements](https://github.com/scaryghost/ServerAchievements) are installed on the server. Once both are installed, download the latest `KFTurbo.zip` from the [releases page](https://github.com/KFPilot/KFTurbo/releases) and drag and drop all the files in the `StagedKFTurboGitHub` folder into the server's `System` folder. Releases come with a `ServerPerks.ini` and `ServerAchievements.ini` which provide the default setup for KFTurbo.

### Launch Parameters
The following are required to be set in a server's launch command for KFTurbo to function properly at startup;

`?game=KFTurbo.KFTurboGameType`

`?Mutator=ServerPerksMut.ServerPerksMut,ServerAchievements.SAMutator,KFTurbo.KFTurboMut,KFTurboServer.KFTurboServerMut`

The result should look something like;

`ucc server KF-Departed.rom?game=KFTurbo.KFTurboGameType?Mutator=KFTurbo.KFTurboMut,KFTurboServer.KFTurboServerMut,KFTurboRandomizer.KFTurboRandomizerMut,ServerPerksMut.ServerPerksMut`

To play with the Randomizer mutator, add `KFTurboRandomizer.KFTurboRandomizerMut` to the comma separated list of mutators.

To play on KFTurbo Plus difficulty, the GameType launch parameter must be set to `?game=KFTurbo.KFTurboGameTypePlus`.

### Map Vote Setup
For servers using Marco's [KFMapVoteV2](https://forums.tripwireinteractive.com/index.php?threads/mod-voting-handler-fix.43202/), ensure that, for KFTurbo voting options, the GameType is set to either `Killing Floor Turbo Game Type` or `Killing Floor Turbo+ Game Type` and that the following mutators are selected;
- Server Veterancy Handler V7
- Server Achievements
- Killing Floor Turbo
- Killing Floor Turbo Server
