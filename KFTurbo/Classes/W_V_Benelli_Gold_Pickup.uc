//Killing Floor Turbo W_V_Benelli_Gold_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Benelli_Gold_Pickup extends W_Benelli_Pickup;

#exec OBJ LOAD FILE=KF_Weapons3rd_Gold_T.utx

defaultproperties
{
     ItemName="Golden Combat Shotgun"
     InventoryType=Class'KFTurbo.W_V_Benelli_Gold_Weap'
     Skins(0)=Texture'KF_Weapons3rd_Gold_T.Weapons.Gold_Benelli_3rd'
}
