//Represents a user's vanilla stat value for this progress type.
class VP_ExplosiveDamage extends SRCustomProgressInt;

//Hook into killing fleshpounds as a Demolitions here and provide bonus EXP.
function NotifyPlayerKill( Pawn Killed, class<DamageType> damageType )
{
     if (RepLink == None ||  RepLink.StatObject == None || RepLink.OwnerPRI == None || RepLink.OwnerPRI.ClientVeteranSkill != class'V_Commando')
     {
          return;
     }

     if (P_Fleshpound(Killed) == None)
     {
          return;
     }

     RepLink.StatObject.AddExplosivesDamage(Killed.HealthMax * 0.5f); //Bonus explosive damage.
}

defaultproperties
{
     ProgressName="Steam Explosive Damage"
}
