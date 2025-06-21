//Killing Floor Turbo MapConfigurationObject
//Per-map object that allows for modifications of defined maps' spawn rates/max zeds/etc without needing to alter the map file.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
Class MapConfigurationObject extends Object
	PerObjectConfig
	Config(KFTurboMapConfig);

var config bool bDisabled;
var config string MapNameRedirect; //If specified, KFTurbo will try to find a config object with this name and use it instead.
var config float WaveSpawnRateMultiplier;
var config float WaveMaxMonstersMultiplier;
var config float ZombieVolumeCanRespawnTimeMultiplier;
var config float ZombieVolumeMinDistanceToPlayerMultiplier;
var config bool bSkipInitialMonsterWander;

defaultproperties
{
	bDisabled=false
	MapNameRedirect=""
	WaveSpawnRateMultiplier=1.f
	WaveMaxMonstersMultiplier=1.f
	ZombieVolumeCanRespawnTimeMultiplier=1.f
	ZombieVolumeMinDistanceToPlayerMultiplier=1.f
	bSkipInitialMonsterWander=false
}
