//Killing Floor Turbo W_V_Katana_Gold_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Katana_Gold_Pickup extends W_Katana_Pickup;

#exec OBJ LOAD FILE=KF_Weapons3rd_Gold_T.utx

defaultproperties
{
     ItemName="Golden Katana"
     InventoryType=Class'KFTurbo.W_V_Katana_Gold_Weap'
     Skins(0)=Texture'KF_Weapons3rd_Gold_T.Weapons.Gold_Katana_3rd'
}
