//Killing Floor Turbo W_Frag_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Frag_Weap extends Frag;

struct MeshDefinition
{
    var Mesh WeaponMesh;
    var int ArmUVIndex;
    var array<Material> WeaponMeshMaterialList;
    var class<InventoryAttachment> AttachmentClass;
    //Potentially add material list here... kinda sucks if that's what's necessary though.
};

var class<Projectile> LastThrownGrenadeClass;
var class<KFSpeciesType> LastSpeciesTypeClass;
var MeshDefinition CurrentGrenadeDefinition;

var MeshDefinition DefaultGrenadeDefinition;
var MeshDefinition FirebugGrenadeDefinition;
var MeshDefinition BerserkerGrenadeDefinition;
var MeshDefinition MedicGrenadeDefinition;

var() float QuatPitch;
var() float QuatYaw;
var() float QuatRoll;

simulated event StartThrow()
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        PerformMeshUpdate();
    }

    Super.StartThrow();
}

//Updates grenade mesh and material.
simulated function PerformMeshUpdate()
{
    local Pawn Pawn;

    Pawn = Pawn(Owner);

    if (Pawn == None || !Pawn.IsLocallyControlled())
    {
        return;
    }

    if (!UpdateMeshDefinition())
    {
        UpdateSleeveTexture();
        return;
    }
    UpdateWeaponMesh();
    UpdateSleeveTexture();
}

simulated function bool UpdateMeshDefinition()
{
    local class<Projectile> NewDesiredProjectileClass;
    NewDesiredProjectileClass = W_Frag_Fire(FireMode[0]).GetDesiredProjectileClass();
    if (LastThrownGrenadeClass == NewDesiredProjectileClass)
    {
        return false;
    }

    LastThrownGrenadeClass = NewDesiredProjectileClass;

    //Doesn't make any sense but handle it anyways.
    if (NewDesiredProjectileClass == None)
    {
        CurrentGrenadeDefinition = DefaultGrenadeDefinition;
        return true;
    }

    switch (NewDesiredProjectileClass)
    {
        case class'KFMod.Nade':
        case class'KFTurbo.W_Frag_Proj':
            CurrentGrenadeDefinition = DefaultGrenadeDefinition;
            break;
        case class'KFTurbo.V_Firebug_Grenade':
            CurrentGrenadeDefinition = FirebugGrenadeDefinition;
            break;
        case class'KFTurbo.V_FieldMedic_Grenade':
            CurrentGrenadeDefinition = MedicGrenadeDefinition;
            break;
        case class'KFTurbo.V_Berserker_Grenade':
            CurrentGrenadeDefinition = BerserkerGrenadeDefinition;
            break;
    }
    return true;
}

simulated function UpdateWeaponMesh()
{
    LinkMesh(CurrentGrenadeDefinition.WeaponMesh, true);
    Skins = CurrentGrenadeDefinition.WeaponMeshMaterialList;
    ShowGrenadeMesh();
}

simulated function UpdateSleeveTexture()
{
    local class<KFSpeciesType> NewSpeciesTypeClass;
 
    if (xPawn(Owner) == None)
    {
        return;
    }
 
    NewSpeciesTypeClass = class<KFSpeciesType>(xPawn(Owner).Species);
    if (LastSpeciesTypeClass == NewSpeciesTypeClass)
    {
        return;
    }

    LastSpeciesTypeClass = NewSpeciesTypeClass;

    if (CurrentGrenadeDefinition.ArmUVIndex != -1)
    {
        Skins[CurrentGrenadeDefinition.ArmUVIndex] = NewSpeciesTypeClass.static.GetSleeveTexture();
    }
}

//=============
//RepNotifies

simulated function HideGrenadeMesh()
{
    if (Level.NetMode == NM_DedicatedServer)
    {
        return;
    }

    //int Slot, optional float BoneScale, optional name BoneName
    SetBoneScale(0, 0.f, 'Frag');
}

simulated function ShowGrenadeMesh()
{
    if (Level.NetMode == NM_DedicatedServer)
    {
        return;
    }

    SetBoneScale(0, 1.f, 'Frag');
}

defaultproperties
{
    LastThrownGrenadeClass = None
    LastSpeciesTypeClass = None
    
    DefaultGrenadeDefinition=(WeaponMesh=SkeletalMesh'KF_Weapons_Trip.Frag_Trip',WeaponMeshMaterialList=(Shader'KillingFloorWeapons.Frag_Grenade.FragShader'),ArmUVIndex=1,AttachmentClass=Class'KFMod.FragAttachment')
    FirebugGrenadeDefinition=(WeaponMesh=SkeletalMesh'KFTurbo.FirebugGrenade',WeaponMeshMaterialList=(Shader'KFTurbo.FP7.FP7_SHDR'),ArmUVIndex=1,AttachmentClass=Class'KFMod.FragAttachment')
    MedicGrenadeDefinition=(WeaponMesh=SkeletalMesh'KFTurbo.MedicGrenade',WeaponMeshMaterialList=(Texture'KFTurbo.G28.G28MedicGrenade'),ArmUVIndex=1,AttachmentClass=Class'KFMod.FragAttachment')
    BerserkerGrenadeDefinition=(WeaponMesh=SkeletalMesh'KFTurbo.ZerkNade',WeaponMeshMaterialList=(Shader'KFTurbo.XM84.XM84-Glow'),ArmUVIndex=1,AttachmentClass=Class'KFMod.FragAttachment')

    //Might as well incorporate the frag fix while we're here.
    FireModeClass(0)=Class'W_Frag_Fire'

    AttachmentClass=Class'KFMod.FragAttachment'
    Mesh=SkeletalMesh'KF_Weapons_Trip.Frag_Trip'

    QuatPitch=-0.5f
    QuatYaw=0.25
    QuatRoll=0.8
}
