//Killing Floor Turbo VP_FlamethrowerDamage
//Represents a user's vanilla stat value for this progress type.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VP_FlamethrowerDamage extends SRCustomProgressInt;

//Hook into killing crawlers as a Firebug here and provide bonus EXP.
function NotifyPlayerKill( Pawn Killed, class<DamageType> damageType )
{
     if (RepLink == None ||  RepLink.StatObject == None || RepLink.OwnerPRI == None || RepLink.OwnerPRI.ClientVeteranSkill != class'V_Firebug')
     {
          return;
     }

     if (P_Crawler(Killed) == None)
     {
          return;
     }

     RepLink.StatObject.AddFlameThrowerDamage(Killed.HealthMax * 0.5f); //Bonus flamethrower damage.
}

defaultproperties
{
     ProgressName="Steam Flamethrower Damage"
}
