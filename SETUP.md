# Setup
### Initial Setup
For starters, make sure [Server Perks](https://forums.tripwireinteractive.com/index.php?threads/mut-per-server-stats.36898/) and [Server Achievements](https://github.com/scaryghost/ServerAchievements) are installed on the server. Once both are installed, download the latest `KFTurbo.zip` from the [releases page](https://github.com/KFPilot/KFTurbo/releases) and drag and drop all files into the server's `System` folder. Releases come with a `ServerPerks.ini` and `ServerAchievements.ini` which provide the intended default setup for KFTurbo.

### Launch Parameters
The following are required to be set in a server's launch command for KFTurbo to function properly at startup;

`?game=KFTurbo.KFTurboGameType`

`?Mutator=ServerPerksMut.ServerPerksMut,ServerAchievements.SAMutator,KFTurbo.KFTurboMut,KFTurboServer.KFTurboServerMut`

The result should look something like;

`ucc server KF-Departed.rom?game=KFTurbo.KFTurboGameType?Mutator=ServerPerksMut.ServerPerksMut,ServerAchievements.SAMutator,KFTurbo.KFTurboMut,KFTurboServer.KFTurboServerMut`

To play on KFTurbo Plus difficulty, the GameType launch parameter must be set to `?game=KFTurbo.KFTurboGameTypePlus`.

### Map Vote Setup
For servers using Marco's [KFMapVoteV2](https://forums.tripwireinteractive.com/index.php?threads/mod-voting-handler-fix.43202/), ensure that, for KFTurbo voting options, the GameType is set to either `Killing Floor Turbo Game Type` or `Killing Floor Turbo+ Game Type` and that the following mutators are selected;
- Server Veterancy Handler V7
- Server Achievements
- Killing Floor Turbo
- Killing Floor Turbo Server

### Randomizer

KFTurbo Randomizer is Killing Floor Turbo's randomizer mutator which provides players with random perks and loadouts each wave. More information can be found [here](https://github.com/KFPilot/KFTurbo/tree/master/KFTurboRandomizer#readme). To play the KFTurbo Randomizer, add `KFTurboRandomizer.KFTurboRandomizerMut` to the comma separated list of mutators (`?Mutator=`) in the server's launch parameters. To add it as a voting option in KFMapVoteV2, follow the instructions in the [Map Vote Setup](https://github.com/KFPilot/KFTurbo/blob/master/SETUP.md#map-vote-setup) section and add `Killing Floor Turbo Randomizer` to the list of Mutators.

### Card Game

The KFTurbo Card Game mutator adds votable "cards" players vote on each wave which modify a variety of gameplay mechanics. More information can be found [here](https://github.com/KFPilot/KFTurbo/tree/master/KFTurboCardGame#readme). To play the KFTurbo Card Game, add `KFTurboCardGame.KFTurboCardGameMut` to the comma separated list of mutators (`?Mutator=`) in the server's launch parameters. To add it as a voting option in KFMapVoteV2, follow the instructions in the [Map Vote Setup](https://github.com/KFPilot/KFTurbo/blob/master/SETUP.md#map-vote-setup) section and add `Killing Floor Turbo Card Game` to the list of Mutators.

### Killing Floor Turbo+

Killing Floor Turbo+ is the high difficulty mode for KFTurbo. To play Killing Floor Turbo+, set `KFTurbo.KFTurboGameTypePlus` in the game type specifier (`?game=`) in the server's launch parameters. To add it as a voting option in KFMapVoteV2, follow the instructions in the [Map Vote Setup](https://github.com/KFPilot/KFTurbo/blob/master/SETUP.md#map-vote-setup) section and set `Killing Floor Turbo+ Game Type` as the Game Type.
