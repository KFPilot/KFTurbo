//Killing Floor Turbo W_Benelli_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Benelli_Weap extends WeaponBenelliShotgun;

var float CachedMagAmmoRemaining;

var int AddReloadCount;

simulated function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();

	ConditionallyRollBackReload();

    if (Role == ROLE_Authority && ++AddReloadCount >= MagCapacity) { class'WeaponHelper'.static.OnWeaponReload(Self); AddReloadCount = 0; }
}

simulated function WeaponTick(float dt)
{
	Super.WeaponTick(dt);

	if (Level.NetMode != NM_DedicatedServer && CachedMagAmmoRemaining != MagAmmoRemaining)
	{
		ConditionallyRollBackReload();
		CachedMagAmmoRemaining = MagAmmoRemaining;
	}
}

simulated function ConditionallyRollBackReload()
{
	local Name SequenceName;
	local float OutFrame, OutRate;

	GetAnimParams(0, SequenceName, OutFrame, OutRate);

	OutFrame *= 174.f;

	if (SequenceName != ReloadAnim)
	{
		return;
	}

	if (OutFrame < 130.f)
	{
		return;
	}

	SetAnimFrame(OutFrame - 23.89, 0, 1);
}

defaultproperties
{
	MagCapacity=8
	FireModeClass(0)=Class'KFTurbo.W_Benelli_Fire'
	PickupClass=Class'KFTurbo.W_Benelli_Pickup'
	AttachmentClass=Class'KFTurbo.W_Benelli_Attachment'
	
	AddReloadCount=0
}
