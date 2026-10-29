//Killing Floor Turbo VinylAugmentVampire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentVampire extends VinylAugmentReplicationInfo;

var const int KillHealAmount;

function NotifyPlayerKilledMonster(TurboPlayerController Player, KFMonster Target, class<DamageType> DamageType)
{
    if (Player == None || Player.Pawn == None || Player.Pawn.Health <= 0)
    {
        return;
    }

    Player.Pawn.GiveHealth(KillHealAmount, Player.Pawn.HealthMax);
}

defaultproperties
{
    bWantsPlayerKilledMonsterEvents=true
    KillHealAmount=3
}
