//Killing Floor Turbo W_M4203_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M4203_Fire extends WeaponM203Fire;

enum EFireState
{
	Ready,
	Reloading,
	ReadyLoaded
};

var private EFireState FireState;
var private float ReloadWorldTime;

var float ReloadTime;
var Name SecondaryReloadAnim;
var Name ThirdPersonSecondaryReloadAnim;
var bool bPendingReload;

var bool bDebugAllowFire;

simulated final function bool IsLocallyControlled()
{
	return Level.NetMode == NM_Standalone || (Instigator != None && Instigator.IsLocallyControlled());
}

simulated function bool IsIdle()
{
	return FireState == Ready || FireState == ReadyLoaded;
}

simulated function bool IsReady()
{
	return FireState == Ready;
}

simulated function bool IsReloading()
{
	return FireState == Reloading;
}

simulated function bool IsReadyAndLoaded()
{
	return FireState == ReadyLoaded;
}

simulated function bool IsCurrentlyFiring()
{
	if (NextFireTime - FireRate * 0.1f > Level.TimeSeconds + PreFireTime)
	{
		return true;
	}

	return false;
}

simulated function NotifyPendingReload()
{
	if (!IsLocallyControlled())
	{
		return;
	}

	bPendingReload = true;
}

simulated function bool AllowFire()
{
	if (KFWeapon(Weapon) != None && KFWeapon(Weapon).bIsReloading)
	{
		return false;
	}

	if (KFPawn(Instigator).bThrowingNade)
	{
		return false;
	}

	return Super.AllowFire();
}

function PlayFiring()
{
	Super.PlayFiring();
}

event ModeDoFire()
{
	if (!AllowFire())
	{
		return;
	}

	Super.ModeDoFire();

	SetFireState(Ready);
}

simulated function EFireState GetFireState()
{
	return FireState;
}

function SetFireState(EFireState NewState)
{
	FireState = NewState;
}

event ModeTick(float dt)
{
	Super.ModeTick(dt);

	if (IsReadyAndLoaded())
	{
		return;
	}

	if (IsReloading())
	{
		TickReload(dt);
	}
}

simulated function PerformReload(float WorldTimeSeconds)
{
	local float ReloadDuration;

	if (FireState == Reloading)
	{
		return;
	}

	//If we attempted a reload but are out of ammo, then get out of here.
	if (Weapon.AmmoAmount(1) == 0)
	{
		return;
	}
	
	if (KFWeap != None && KFWeap.bAimingRifle)
	{
		KFWeap.ZoomOut(true);
	}

	SetFireState(Reloading);

	ReloadDuration = (ReloadTime / GetReloadSpeed());

	ReloadWorldTime = ReloadDuration + WorldTimeSeconds - (ReloadDuration * 0.06f); //last reduction allows for local player owner to act as the reload anim has already completed

	Weapon.PlayAnim(SecondaryReloadAnim, (Weapon.GetAnimDuration(SecondaryReloadAnim) / ReloadDuration));

	if (Instigator != None)
	{
		Instigator.SetAnimAction(ThirdPersonSecondaryReloadAnim);

		if (Instigator.Role == ROLE_Authority && !Instigator.IsLocallyControlled())
		{
			W_M4203_Weap(Weapon).ClientNotifyReload(WorldTimeSeconds);
		}
	}
}

simulated function TickReload(float DeltaTime)
{
	if (ReloadWorldTime >= Level.TimeSeconds)
	{
		return;
	}

	SetFireState(ReadyLoaded);

	if (IsLocallyControlled() && Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
	{
		Weapon.PutDown();
	}
}

function DoFireEffect()
{
	Super(KFShotgunFire).DoFireEffect();
}

simulated function float GetFireSpeed()
{
	return 1.f;
}

simulated function float GetReloadSpeed()
{
	if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none 
		&& KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill == class'V_Demolitions')
	{
		return 1.f + FMin(float(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkillLevel) * 0.045f, 0.25f);
	}

	if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none)
	{
		return KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), KFWeapon(Weapon));
	}

	return 1.f;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.SetDrawColor(0, 255, 0);
	Canvas.DrawText("  FIREMODE "$self$" IsFiring "$bIsFiring$" in state "$GetStateName());
	YPos += YL;
	Canvas.SetPos(4, YPos);

	Canvas.DrawText("  FireOnRelease "$bFireOnRelease$" HoldTime "$HoldTime$" MaxHoldTime "$MaxHoldTime);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("  NextFireTime "$NextFireTime$" NowWaiting "$bNowWaiting);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("  bTimerLoop "$bTimerLoop$" NextTimerPop "$NextTimerPop);
	YPos += YL;
	Canvas.SetPos(4, YPos);

	switch (FireState)
	{
	case Ready:
		Canvas.DrawText("  Arming state Ready");
		break;
	case ReadyLoaded:
		Canvas.DrawText("  Arming state ReadyLoaded");
		break;
	case Reloading:
		Canvas.DrawText("  Arming state Reloading");
		break;
	}

	YPos += YL;
	Canvas.SetPos(4, YPos);
}

defaultproperties
{
     FireState=ReadyLoaded
     ReloadTime=2.500000
     SecondaryReloadAnim="Reload_Secondary"
     ThirdPersonSecondaryReloadAnim="Reload_Secondary_M4203"
     FireAimedAnim="FireLast_Iron_Secondary"
     FireAnim="FireLast_Secondary"
     FireRate=0.250000
     AmmoClass=Class'KFTurbo.W_M4203_Ammo'
     ProjectileClass=Class'KFTurbo.W_M4203_Proj'
}
