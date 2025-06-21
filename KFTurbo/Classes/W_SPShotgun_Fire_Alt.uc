//Killing Floor Turbo W_SPShotgun_Fire_Alt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPShotgun_Fire_Alt extends SPShotgunAltFire;

function HandleAchievement(Pawn Victim)
{
    local vector VelocityAdded;
    Super.HandleAchievement(Victim);

    if (Instigator == None)
    {
        return;
    }

    VelocityAdded = Normal((Victim.Location + Victim.EyePosition()) - Instigator.Location);
    VelocityAdded = VelocityAdded * InterpCurveEval(AppliedMomentumCurve, Victim.Mass) / Victim.Mass;

    class'TurboGameplayEventHandler'.static.BroadcastPawnPushedWithMCZThrower(Instigator, Victim, VelocityAdded);
}

defaultproperties
{
}
