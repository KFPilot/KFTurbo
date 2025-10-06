//Killing Floor Turbo V_CommandoClassification
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class V_CommandoFirebugClassification extends CoreWeaponClassification;

function bool IsPerkWeapon(class<CoreVeterancyTypes> PerkClass)
{
	return PerkClass == class'V_Commando' || PerkClass == class'V_Firebug';
}