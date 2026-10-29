//Killing Floor Turbo VinylAugmentRegenerationUndamaged
//Regenerates health once the player has gone a while without taking damage.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentRegenerationUndamaged extends VinylAugmentRegeneration;

var float DamageTakenEndTime;
var const float DamageTakenDuration;

function NotifyPlayerReceivedDamage(TurboPlayerController Player, KFMonster DamageInstigator, int Damage, class<DamageType> DamageType)
{
    DamageTakenEndTime = Level.TimeSeconds + DamageTakenDuration;
}

function bool IsRegenerating()
{
    return Level.TimeSeconds >= DamageTakenEndTime;
}

defaultproperties
{
    bWantsPlayerReceivedDamageEvents=true
    DamageTakenDuration=5.f
}
