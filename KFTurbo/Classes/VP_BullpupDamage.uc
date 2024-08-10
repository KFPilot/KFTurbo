//Represents a user's vanilla stat value for this progress type.
class VP_BullpupDamage extends SRCustomProgressInt;

//Hook into killing stalkers as a Commando here and provide bonus EXP.
function NotifyPlayerKill( Pawn Killed, class<DamageType> damageType )
{
     if (RepLink == None ||  RepLink.StatObject == None || RepLink.OwnerPRI == None || RepLink.OwnerPRI.ClientVeteranSkill != class'V_Commando')
     {
          return;
     }

     if (P_Stalker(Killed) == None)
     {
          return;
     }

     RepLink.StatObject.AddBullpupDamage(Killed.HealthMax); //Bonus bullpup damage.
}

defaultproperties
{
     ProgressName="Steam Assault Rifle Damage"
}