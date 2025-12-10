//Killing Floor Turbo TurboHUDPlayer
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDPlayer extends TurboHUDOverlay
    hidecategories(Advanced,Collision,Display,Events,Force,Karma,LightColor,Lighting,Movement,Object,Sound)
	config(KFTurbo);

var int BaseFontSize;

var config bool bEnableHitchDetection;
var float FrameTimeList[100];
var int FrameTimeIndex;
var float LastHitchTime;
var float HitchFrameTime;

//These sizes are based on % of monitor Y size.
var(Layout) Vector2D HealthBackplateSize;
var(Layout) Vector2D AmmoBackplateSize;
var(Layout) Vector2D AlternateAmmoBackplateSize; //Used by both secondary ammo and medic ammo.
var(Layout) Vector2D WeightBackplateSize;
var(Layout) Vector2D CashBackplateSize;
var(Layout) Vector2D PerkProgressSize;
var(Layout) Vector2D PerkProgressOffset;
var(Layout) Vector2D PerkIconOffset;

//Space for text centered around the above backplate sizes (so that there can be a margin at the edges of the backplate)
var(Layout) Vector2D HealthBackplateTextArea;
var(Layout) Vector2D AmmoBackplateTextArea;
var(Layout) Vector2D AlternateAmmoBackplateTextArea;
var(Layout) Vector2D WeightBackplateTextArea;
var(Layout) Vector2D CashBackplateTextArea;

var Vector2D BackplateSpacing; //Distance from top and middle.

var float EmptyDigitOpacityMultiplier;

var Color BackplateColor;
var Texture RoundedContainer;

var bool bHasPawn;

var float CurrentHealth;
var float HealthInterpRate;
var float CurrentPulseAmount;
var float CurrentPulseRate;
var float CurrentPulseRatio;

var float CurrentArmor;
var float ArmorInterpRate;

var WeaponSyringe CurrentSyringe;
var float CurrentSyringeCharge;
var float SyringeInterpRate;
var Texture SyringeIcon;

var float CurrentHealingRatio;
var float CurrentHealingInterpRate;
var Material HealingMaterial;

var WeaponFrag CurrentGrenade;
var float CurrentGrenadeCount;
var float MaxGrenadeCount;
var Texture GrenadeIcon;

var WeaponWelder CurrentWelder;
var float CurrentWelderCharge;
var float WelderInterpRate;

var float CurrentMagazineAmmo;
var float CurrentLoadedAmmo; //Used to help with CurrentSpareAmmo calculation.
var float CurrentSpareAmmo;

var bool bIsMeleeGun;
var bool bIsWelderOrSyringe;
var bool bIsSingleShotWeapon;
var bool bIsHuskGun;
var bool bIsLargeCapacityMagazine;

var bool bWeaponHasSecondaryAmmo;
var bool bWeaponSecondaryCanFire;
var float CurrentSpareSecondaryAmmo;
var float CurrentMaxSecondaryAmmo;
var float SecondaryAmmoFade;
var float SecondaryAmmoFadeRate;
var float SecondaryAmmoOffset;

var bool bIsMedicGun;
var float CurrentSpareMedicGunAmmo;
var float CurrentMaxMedicGunAmmo;
var float MedicGunAmmoFade;

var localized string SecondaryAmmoHeader; //Can be anything - just make sure it's 3 or less characters.
var localized string SecondaryMedicGunAmmoHeader; //Can be anything - just make sure it's 3 or less characters.

var KFWeapon LastKnownWeapon;
var bool bIsReloading;
var float LastReloadingTime;
var float ReloadFade;
var float ReloadFadeRate;

var bool bIsOutOfAmmo;
var float OutOfAmmoFade;
var float OutOfAmmoFadeRate;

var bool bIsFlashlightOn;
var float FlashlightPower;
var float FlashlightPowerFade;
var float FlashlightPowerFadeRate;
var float FlashlightOffset;
var Texture FlashlightIcon;

var int CurrentWeight;
var int MaxCarryWeight;
var Texture WeightIcon;

var float CurrentPlayerCash;
var float TargetPlayerCash;
var float CurrentPlayerCashReceive;
var float CurrentPlayerCashReceiveDivisor;
var int LastPlayerCash, LastReceivedBonus;
var float LastCashLostTime;
var float ReceivedCashDecayDelay;
var float CashInterpRate;
var float CurrentCashBackplateX;
var float DesiredCashBackplateX;

var(Perk) int PerkLevel;
var(Perk) float PerkProgress;
var(Perk) Color PerkProgressColor;
var(Perk) class<TurboVeterancyTypes> PlayerPerk;
var(Perk) float PerkDrawScale;

simulated final function Pawn FindRelevantPawn()
{
	if (GetPawn() != None && GetPawn().Health > 0)
	{
		return GetPawn();
	}

	if (TurboHUD.PawnOwner == None || TurboHUD.PawnOwner.Health <= 0)
	{
		return None;
	}

	//Don't do this for monsters.
	if (KFMonster(TurboHUD.PawnOwner) != None)
	{
		return None;
	}

	return TurboHUD.PawnOwner;
}

simulated function AddTickEntry(float DeltaTime)
{
	local int Index;
	local float FrameTime;
	local float FrameTimeAverage;

	FrameTime = (DeltaTime / Level.TimeDilation);
	FrameTimeList[FrameTimeIndex] = FrameTime;
	FrameTimeIndex = (FrameTimeIndex + 1) % 100;

	for (Index = 0; Index < ArrayCount(FrameTimeList); Index++)
	{
		if (FrameTimeList[Index] <= 0.f)
		{
			break;
		}

		FrameTimeAverage += FrameTimeList[Index];
	}

	FrameTimeAverage = FrameTimeAverage / float(Index);

	if (FrameTimeAverage * 2.f < FrameTime)
	{
		if (HitchFrameTime > FrameTime && LastHitchTime > Level.TimeSeconds + 5.f)
		{
			return;
		}

		HitchFrameTime = FrameTime;
		LastHitchTime = Level.TimeSeconds;
	}
}

simulated function Tick(float DeltaTime)
{
	local Pawn CurrentPawn;
	CurrentPawn = FindRelevantPawn();

	if (bEnableHitchDetection && DeltaTime > 0.f)
	{
		AddTickEntry(DeltaTime);
	}

	if (CurrentPawn == None)
	{
		bHasPawn = false;
		CurrentHealth = 0.f;
		CurrentArmor = 0.f;
		CurrentSyringeCharge = 0.f;
		CurrentGrenadeCount = 0;
		MaxGrenadeCount = 5;
		bIsMeleeGun = false;
		bIsWelderOrSyringe = false;
		bIsSingleShotWeapon = false;
		bIsReloading = false;
		ReloadFade = 0.f;
		bIsOutOfAmmo = false;
		OutOfAmmoFade = 0.f;
		CurrentPlayerCash = -1.f;
		CurrentHealingRatio = 0.f;
		return;
	}

	bHasPawn = true;

	DeltaTime = FMin(DeltaTime, 0.1f);

	TickPlayerReplicationInfo(DeltaTime, KFPlayerReplicationInfo(CurrentPawn.PlayerReplicationInfo));

	FindSyringe(CurrentPawn);
	FindWelder(CurrentPawn);
	FindGrenade(CurrentPawn);

	CurrentHealth = Lerp(HealthInterpRate * DeltaTime, CurrentHealth, float(CurrentPawn.Health));
	if (Abs(CurrentHealth - float(CurrentPawn.Health)) < 0.1)
	{
		CurrentHealth = float(CurrentPawn.Health);
	}

	CurrentPulseRate = FClamp(Lerp(float(CurrentPawn.Health) / (CurrentPawn.HealthMax * 0.5f), 16.f, 2.f), 2.f, 16.f);
	CurrentPulseRatio = FClamp(Lerp(float(CurrentPawn.Health + 10) / (CurrentPawn.HealthMax * 0.5f), 1.f, 0.f), 0.f, 1.f);
	CurrentPulseAmount += CurrentPulseRate * DeltaTime;

	CurrentArmor = Lerp(ArmorInterpRate * DeltaTime, CurrentArmor, CurrentPawn.ShieldStrength);
	if (Abs(CurrentArmor - CurrentPawn.ShieldStrength) < 0.5)
	{
		CurrentArmor = CurrentPawn.ShieldStrength;
	}

	TickHumanPawn(DeltaTime, TurboHumanPawn(CurrentPawn));
	TickSyringe(DeltaTime);
	TickWelder(DeltaTime);

	if (CurrentGrenade != None)
	{
		CurrentGrenade.GetAmmoCount(MaxGrenadeCount, CurrentGrenadeCount);
	}
	else
	{
		CurrentGrenadeCount = 0;
		MaxGrenadeCount = 5;
	}

	bIsReloading = false;
	bIsOutOfAmmo = false;
	if (KFWeapon(CurrentPawn.Weapon) != None)
	{
		WeaponUpdate(DeltaTime, KFWeapon(CurrentPawn.Weapon));
	}

	TickSecondaryAmmoLayout(DeltaTime);

	if (bIsReloading)
	{
		ReloadFade = FMin(ReloadFade + (DeltaTime * ReloadFadeRate), 1.f);
	}
	else
	{
		ReloadFade = FMax(ReloadFade - (DeltaTime * ReloadFadeRate), 0.f);
	}

	if (bIsOutOfAmmo)
	{
		OutOfAmmoFade = FMin(OutOfAmmoFade + (DeltaTime * OutOfAmmoFadeRate), 1.f);
	}
	else
	{
		OutOfAmmoFade = FMax(OutOfAmmoFade - (DeltaTime * OutOfAmmoFadeRate), 0.f);
	}

	CurrentCashBackplateX = Lerp(DeltaTime * 2.f, CurrentCashBackplateX, DesiredCashBackplateX);
}

simulated function TickSecondaryAmmoLayout(float DeltaTime)
{
	if (bIsFlashlightOn || FlashlightPower < 100.f)
	{
		FlashlightPowerFade = FMin(FlashlightPowerFade + (DeltaTime * FlashlightPowerFadeRate), 1.f);
	}
	else
	{
		FlashlightPowerFade = FMax(FlashlightPowerFade - (DeltaTime * FlashlightPowerFadeRate), 0.f);
	}

	if (bWeaponHasSecondaryAmmo || bIsMedicGun)
	{
		FlashlightOffset = Lerp(DeltaTime * SecondaryAmmoFadeRate * 4.f, FlashlightOffset, 1.f);
	}
	else
	{
		FlashlightOffset = Lerp(DeltaTime * SecondaryAmmoFadeRate * 1.f, FlashlightOffset, 0.f);
	}

	if (bWeaponHasSecondaryAmmo)
	{
		SecondaryAmmoFade = FMin(SecondaryAmmoFade + (DeltaTime * SecondaryAmmoFadeRate), 1.f);
	}
	else
	{
		SecondaryAmmoFade = FMax(SecondaryAmmoFade - (DeltaTime * SecondaryAmmoFadeRate), 0.f);
	}

	if (bIsMedicGun)
	{
		MedicGunAmmoFade = FMin(MedicGunAmmoFade + (DeltaTime * SecondaryAmmoFadeRate), 1.f);
		SecondaryAmmoOffset = Lerp(DeltaTime * SecondaryAmmoFadeRate * 4.f, SecondaryAmmoOffset, 1.f);
	}
	else
	{
		MedicGunAmmoFade = FMax(MedicGunAmmoFade - (DeltaTime * SecondaryAmmoFadeRate), 0.f);
		SecondaryAmmoOffset = Lerp(DeltaTime * SecondaryAmmoFadeRate * 1.f, SecondaryAmmoOffset, 0.f);
	}
}

simulated function OnScreenSizeChange(Canvas C, Vector2D CurrentClipSize, Vector2D PreviousClipSize)
{
	local int Index;

	if (C.ClipY > 1600)
	{
		BaseFontSize = 0;
	}
	else if (C.ClipY > 1400)
	{
		BaseFontSize = 1;
	}
	else if (C.ClipY > 1000)
	{
		BaseFontSize = 2;
	}
	else
	{
		BaseFontSize = 3;
	}

	for (Index = ArrayCount(FrameTimeList) - 1; Index >= 0; Index--)
	{
		FrameTimeList[Index] = -1.f;
	}
}

simulated final function FindSyringe(Pawn CurrentPawn)
{
	if (CurrentSyringe != None)
	{
		return;
	}	
	
	CurrentSyringe = WeaponSyringe(CurrentPawn.FindInventoryType(class'WeaponSyringe'));
}

simulated final function FindWelder(Pawn CurrentPawn)
{
	if (CurrentWelder != None)
	{
		return;
	}	
	
	CurrentWelder = WeaponWelder(CurrentPawn.FindInventoryType(class'WeaponWelder'));
}

simulated final function FindGrenade(Pawn CurrentPawn)
{
	if (CurrentGrenade != None)
	{
		return;
	}	
	
	CurrentGrenade = WeaponFrag(CurrentPawn.FindInventoryType(class'WeaponFrag'));
}

simulated final function TickPlayerReplicationInfo(float DeltaTime, KFPlayerReplicationInfo KFPRI)
{
	local int CurrentScore;

	if (KFPRI == None)
	{
		PlayerPerk = None;
		return;
	}

	PlayerPerk = class<TurboVeterancyTypes>(KFPRI.ClientVeteranSkill);
	PerkLevel = KFPRI.ClientVeteranSkillLevel;

	if (PlayerPerk != None && GetController() != None && GetController().GetClientPerkRepLink() != None)
	{
		PerkProgress = Lerp(DeltaTime * 2.f, PerkProgress, PlayerPerk.static.GetTotalProgress(GetController().GetClientPerkRepLink(), PerkLevel + 1));
	}

	if (CurrentPlayerCash == -1.f)
	{
		CurrentScore = KFPRI.Score;
		CurrentPlayerCash = CurrentScore;
		LastPlayerCash = CurrentScore;
		return;
	}

	CurrentScore = KFPRI.Score;
	CurrentPlayerCash = Lerp(DeltaTime * CashInterpRate, CurrentPlayerCash, CurrentScore);

	if (Abs(CurrentPlayerCash - CurrentScore) < 0.5)
	{
		CurrentPlayerCash = CurrentScore;
	}

	if (LastReceivedBonus + ReceivedCashDecayDelay < Level.TimeSeconds)
	{
		CurrentPlayerCashReceive = Lerp(DeltaTime * CashInterpRate * 2.f, CurrentPlayerCashReceive, 0.f);
	}

	if (CurrentScore == LastPlayerCash)
	{
		return;
	}

	if (CurrentScore < LastPlayerCash)
	{
		LastCashLostTime = Level.TimeSeconds;
		LastPlayerCash = KFPRI.Score;
		return;
	}

	if (CurrentScore > LastPlayerCash && (LastCashLostTime + 0.5f < Level.TimeSeconds))
	{
		CurrentPlayerCashReceive += CurrentScore - LastPlayerCash;
		CurrentPlayerCashReceiveDivisor = CurrentPlayerCashReceive;
		LastReceivedBonus = Level.TimeSeconds;
	}

	LastPlayerCash = KFPRI.Score;
}

simulated final function TickHumanPawn(float DeltaTime, TurboHumanPawn HumanPawn)
{
	local float CurrentFlashlightPower;

	if (HumanPawn == None)
	{
		FlashlightPower = 0.f;
		CurrentWeight = 0.f;
		MaxCarryWeight = 15.f;
		CurrentHealingRatio = 0.f;
		return;
	}

	if (HumanPawn.HealthHealingTo < 0 || HumanPawn.HealthHealingTo <= HumanPawn.Health)
	{
		CurrentHealingRatio = Lerp(DeltaTime * CurrentHealingInterpRate, CurrentHealingRatio, 0.f);
	}
	else
	{
		CurrentHealingRatio = Lerp(DeltaTime * CurrentHealingInterpRate, CurrentHealingRatio, 1.f);
	}

	CurrentWeight = HumanPawn.CurrentWeight;
	MaxCarryWeight = HumanPawn.MaxCarryWeight;

	CurrentFlashlightPower = (float(HumanPawn.TorchBatteryLife) / float(HumanPawn.default.TorchBatteryLife)) * 100.f;

	FlashlightPower = Lerp(SyringeInterpRate * DeltaTime * 0.25f, FlashlightPower, CurrentFlashlightPower);

	if (Abs(CurrentFlashlightPower - FlashlightPower) < 0.5)
	{
		FlashlightPower = CurrentFlashlightPower;
	}
}

simulated function TickSyringe(float DeltaTime)
{
	local float SyringeCharge;

	if (CurrentSyringe == None)
	{
		CurrentSyringeCharge = 0.f;
		return;
	}

	SyringeCharge = CurrentSyringe.ChargeBar() * 100.f;

	if (SyringeCharge < CurrentSyringeCharge)
	{
		CurrentSyringeCharge = SyringeCharge;
	}
	else
	{
		CurrentSyringeCharge = Lerp(SyringeInterpRate * DeltaTime, CurrentSyringeCharge, SyringeCharge);

		if (Abs(CurrentSyringeCharge - SyringeCharge) < 0.5)
		{
			CurrentSyringeCharge = SyringeCharge;
		}
	}
}

simulated function TickWelder(float DeltaTime)
{
	local float WelderCharge;

	if (CurrentWelder == None)
	{
		CurrentWelderCharge = 0.f;
		return;
	}

	WelderCharge = CurrentWelder.ChargeBar() * 100.f;

	CurrentWelderCharge = Lerp(WelderInterpRate * DeltaTime, CurrentWelderCharge, WelderCharge);

	if (Abs(CurrentWelderCharge - WelderCharge) < 0.5)
	{
		CurrentWelderCharge = WelderCharge;
	}
}

simulated function WeaponUpdate(float DeltaTime, KFWeapon Weapon)
{
	local bool bHasChangedWeapon;
	local float MaxAmmo;

	bHasChangedWeapon = false;
	if (LastKnownWeapon != Weapon)
	{
		bHasChangedWeapon = true;
		LastKnownWeapon = Weapon;
		OutOfAmmoFade = 0.f;
		LastReloadingTime = Level.TimeSeconds; //Force an ammo update.
	}

	bIsReloading = Weapon.bIsReloading;
	bIsOutOfAmmo = false;

	bIsFlashlightOn = Weapon.FlashLight != None && Weapon.FlashLight.bHasLight;
	
	bIsMeleeGun = KFMeleeGun(Weapon) != None;
	bIsWelderOrSyringe = (Weapon == CurrentWelder) || (Weapon == CurrentSyringe);

	bIsSingleShotWeapon = false;
	bIsHuskGun = false;
	bIsLargeCapacityMagazine = false;

	bIsMedicGun = false;
	bWeaponHasSecondaryAmmo = false;

	if (bIsMeleeGun)
	{
		if (bIsWelderOrSyringe)
		{
			if (Weapon == CurrentSyringe)
			{
				CurrentLoadedAmmo = CurrentSyringeCharge;
			}
			else if (Weapon == CurrentWelder)
			{
				CurrentLoadedAmmo = CurrentWelderCharge;
			}
			else
			{
				Weapon.GetAmmoCount(MaxAmmo, CurrentLoadedAmmo);
				CurrentLoadedAmmo = (CurrentLoadedAmmo / CurrentSpareAmmo) * 100.f;
			}

			CurrentMagazineAmmo = int(CurrentLoadedAmmo);
			CurrentSpareAmmo = 0;
		}
		else
		{
			CurrentMagazineAmmo = 0;
			CurrentLoadedAmmo = 0;
			CurrentSpareAmmo = 0;
		}
		return;
	}

	bWeaponHasSecondaryAmmo = (Weapon.bHasSecondaryAmmo && !Weapon.bReduceMagAmmoOnSecondaryFire);
	bWeaponSecondaryCanFire = true;

	if (bWeaponHasSecondaryAmmo)
	{
		Weapon.GetSecondaryAmmoCount(CurrentMaxSecondaryAmmo, CurrentSpareSecondaryAmmo);
		bWeaponSecondaryCanFire = Weapon.ReadyToFire(1); //Ask if we can perform secondary fire.
	}
	
	bIsMedicGun = KFMedicGun(Weapon) != None;
	if (bIsMedicGun)
	{
		MedicGunUpdate(DeltaTime, KFMedicGun(Weapon), bHasChangedWeapon);
	}

	if (Weapon.MagCapacity == 1)
	{
		bIsHuskGun = HuskGun(Weapon) != None;

		bIsSingleShotWeapon = !bIsHuskGun;
		
		if (bIsSingleShotWeapon)
		{
			Weapon.GetAmmoCount(MaxAmmo, CurrentLoadedAmmo);
			CurrentSpareAmmo = 0;
			CurrentMagazineAmmo = CurrentLoadedAmmo;
			bIsOutOfAmmo = CurrentLoadedAmmo <= 0;
			return;
		}
	}
	else if (Weapon.MagCapacity > 999)
	{
		bIsLargeCapacityMagazine = true;
	}

	if (bIsHuskGun)
	{
		HuskGunUpdate(HuskGun(Weapon));
		return;
	}

	MagazineAmmoUpdate(Weapon);
}

simulated function MagazineAmmoUpdate(KFWeapon Weapon)
{
	local float MaxAmmo;

	Weapon.GetAmmoCount(MaxAmmo, CurrentSpareAmmo);

	if (Weapon.MagAmmoRemaining < CurrentLoadedAmmo)
	{
		CurrentLoadedAmmo = Weapon.MagAmmoRemaining;
	}
	else
	{
		if (bIsReloading)
		{
			LastReloadingTime = Level.TimeSeconds;
			CurrentLoadedAmmo = Weapon.MagAmmoRemaining;
		}
		else if (Level.TimeSeconds < LastReloadingTime + 0.2f)
		{
			CurrentLoadedAmmo = Weapon.MagAmmoRemaining;
		}
	}

	//Large capacity magazines need to do this. We only support two digits!
	if (bIsLargeCapacityMagazine)
	{
		CurrentSpareAmmo = ((CurrentSpareAmmo - CurrentLoadedAmmo) / float(Weapon.MagCapacity)) * 100.f;
		CurrentLoadedAmmo = (CurrentLoadedAmmo / float(Weapon.MagCapacity)) * 999.f;
	}
	else
	{
		CurrentSpareAmmo = CurrentSpareAmmo - CurrentLoadedAmmo;
	}
	
	bIsOutOfAmmo = CurrentSpareAmmo <= 0;
	CurrentMagazineAmmo = Weapon.MagAmmoRemaining;
}

simulated function HuskGunUpdate(HuskGun HuskGun)
{
	local W_HuskGun_Fire FireMode;
	local float MaxAmmo;
	
	FireMode = W_HuskGun_Fire(HuskGun.GetFireMode(0));

	HuskGun.GetAmmoCount(MaxAmmo, CurrentSpareAmmo);
	
	CurrentLoadedAmmo = 0.f;
	CurrentMagazineAmmo = FMin((FireMode.HoldTime / FireMode.GetScaledMaxChargeTime()) * 100.f, 100.f);
}

simulated function MedicGunUpdate(float DeltaTime, KFMedicGun MedicGun, bool bHasChangedWeapon)
{
	local float MedicGunCharge;
	MedicGunCharge = MedicGun.ChargeBar() * 100.f;

	if (bHasChangedWeapon)
	{
		CurrentSpareMedicGunAmmo = MedicGunCharge;
		return;
	}

	if (CurrentSpareMedicGunAmmo > MedicGunCharge)
	{
		CurrentSpareMedicGunAmmo = MedicGunCharge;
		return;
	}

	CurrentSpareMedicGunAmmo = Lerp(DeltaTime * SyringeInterpRate, CurrentSpareMedicGunAmmo, MedicGunCharge);

	if (Abs(CurrentSpareMedicGunAmmo - 100.f) < 0.5f)
	{
		CurrentSpareMedicGunAmmo = 100.f;
	}
}

simulated function Render(Canvas C)
{
	local Vector2D BackplateACenter, BackplateBCenter;
	local Vector2D LeftAnchor, RightAnchor;

	Super.Render(C);

	if (!bHasPawn)
	{
		return;
	}

	DrawBackplates(C, BackplateACenter, BackplateBCenter, LeftAnchor, RightAnchor);
	DrawHealthText(C, BackplateACenter);
	DrawAmmoText(C, BackplateBCenter);

	DrawAlternativeAmmo(C, RightAnchor);
	DrawWeight(C, LeftAnchor);
	DrawCash(C);

	DrawPerk(C);

	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
}

simulated final function DrawBackplates(Canvas C, out Vector2D BackplateACenter, out Vector2D BackplateBCenter, out Vector2D LeftAnchor, out Vector2D RightAnchor)
{
	local float CenterX, TopY;
	local float TempX, TempY;

	CenterX = C.ClipX * 0.5f;
	TopY = C.ClipY * (1.f - (BackplateSpacing.Y + HealthBackplateSize.Y));

	TempX = CenterX - (C.ClipY * (BackplateSpacing.X + HealthBackplateSize.X));
	TempY = TopY;

	C.DrawColor = BackplateColor;

	C.SetPos(TempX, TempY);
	BackplateACenter.X = TempX + (C.ClipY * HealthBackplateSize.X * 0.5f);
	BackplateACenter.Y = TempY + (C.ClipY * HealthBackplateSize.Y * 0.5f);

	C.DrawTileStretched(RoundedContainer, C.ClipY * HealthBackplateSize.X, C.ClipY * HealthBackplateSize.Y);

	if (CurrentHealingRatio > 0.f)
	{
		C.DrawColor = MakeColor(200, 255, 150, CurrentHealingRatio * 48.f);
		
		C.SetPos(TempX + (C.ClipY * HealthBackplateSize.X * 0.025f), TempY);
		C.DrawTileClipped(HealingMaterial, C.ClipY * HealthBackplateSize.X * 0.95f, C.ClipY * HealthBackplateSize.Y, 0.f, 0.f,
			HealingMaterial.MaterialUSize(), float(HealingMaterial.MaterialVSize()) / (HealthBackplateSize.X * 0.95f / HealthBackplateSize.Y));
		
		C.DrawColor = BackplateColor;
	}
	
	LeftAnchor.X = TempX - (C.ClipY * BackplateSpacing.X * 0.5f);
	LeftAnchor.Y = C.ClipY * (1.f - BackplateSpacing.Y);

	TempX = CenterX + (C.ClipY * BackplateSpacing.X);
	TopY = C.ClipY * (1.f - (BackplateSpacing.Y + AmmoBackplateSize.Y));
	TempY = TopY;

	C.SetPos(TempX, TempY);
	BackplateBCenter.X = TempX + (C.ClipY * AmmoBackplateSize.X * 0.5f);
	BackplateBCenter.Y = TempY + (C.ClipY * AmmoBackplateSize.Y * 0.5f);

	C.DrawTileStretched(RoundedContainer, C.ClipY * AmmoBackplateSize.X, C.ClipY * AmmoBackplateSize.Y);

	RightAnchor.X = TempX + (C.ClipY * ((BackplateSpacing.X * 0.5f) + AmmoBackplateSize.X));
	RightAnchor.Y = LeftAnchor.Y;
}

simulated final function DrawHealthText(Canvas C, Vector2D BackplateACenter)
{
	local float BackplateSizeX, BackplateSizeY;
	local float HealthSizeX, ArmorSizeX, SyringeSizeX;
	local float DefaultTextSizeX, DefaultTextSizeY;
	local float TextSizeX, TextSizeY, TextScale;
	local string HealthString, ArmorString, SyringeString;
	local byte SyringeOpacity, HealthOpacity;

	BackplateSizeX = HealthBackplateTextArea.X * C.ClipY;
	BackplateSizeY = HealthBackplateTextArea.Y * C.ClipY;
	HealthSizeX = BackplateSizeX * 0.667f;
	ArmorSizeX = BackplateSizeX - HealthSizeX;
	SyringeSizeX = ArmorSizeX * 0.667f;

	C.SetPos(BackplateACenter.X - (HealthSizeX - (BackplateSizeX * 0.5f)), BackplateACenter.Y - (BackplateSizeY * 0.5f));

	//Get how big this font is in general for 3 digit numbers.
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize);
	C.TextSize(GetStringOfZeroes(3), DefaultTextSizeX, DefaultTextSizeY);
	
	//Health
	C.DrawColor = MakeColor(200, 255, 150, 220);

	if (CurrentPulseRatio > 0.f)
	{
		C.DrawColor.R = Lerp(CurrentPulseRatio, C.DrawColor.R, 255);
		C.DrawColor.G = Lerp(CurrentPulseRatio, C.DrawColor.G, 0);
		C.DrawColor.B = Lerp(CurrentPulseRatio, C.DrawColor.B, 0);

		HealthOpacity = Lerp((Sin(CurrentPulseAmount) * 0.25f) + 0.75f, 0, 220);
		C.DrawColor.A = Lerp(CurrentPulseRatio, C.DrawColor.A, HealthOpacity);
	}

	//Scale Health text to fit the right 2/3 of the backplate.
	TextScale = HealthSizeX / DefaultTextSizeX;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);
	
	C.SetPos(BackplateACenter.X - (HealthSizeX - (BackplateSizeX * 0.5f)), BackplateACenter.Y - (TextSizeY * 0.515f));

	HealthString = FillStringWithZeroes(Min(int(CurrentHealth), 999), 3);
	DrawCounterTextMeticulous(C, HealthString, TextSizeX, EmptyDigitOpacityMultiplier);

	//Armor
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.DrawColor = C.MakeColor(170, 220, 255, 220);
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 1);
	C.TextSize(GetStringOfZeroes(3), DefaultTextSizeX, DefaultTextSizeY);
	TextScale = ArmorSizeX / DefaultTextSizeX;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);

	C.SetPos(((BackplateACenter.X - (BackplateSizeX * 0.48f)) + (ArmorSizeX * 0.5f)) - (TextSizeX * 0.5f), (BackplateACenter.Y + (BackplateSizeY * 0.475f)) - TextSizeY);

	ArmorString = FillStringWithZeroes(Min(int(CurrentArmor), 999), 3);
	DrawCounterTextMeticulous(C, ArmorString, TextSizeX, EmptyDigitOpacityMultiplier);

	//Syringe
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 2);
	C.TextSize(GetStringOfZeroes(3), DefaultTextSizeX, DefaultTextSizeY);
	TextScale = SyringeSizeX / DefaultTextSizeX;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);

	C.SetPos(BackplateACenter.X - ((BackplateSizeX * 0.275f) + (TextSizeX * 0.5f)), (BackplateACenter.Y - (BackplateSizeY * 0.21f)) - (TextSizeY * 0.5f));

	if (CurrentSyringeCharge >= 100.f)
	{
		SyringeOpacity = 220;
	}
	else if (CurrentSyringeCharge >= 50.f)
	{
		SyringeOpacity = 180;
	}
	else
	{
		SyringeOpacity = 100;
	}

	C.DrawColor = C.MakeColor(255, 255, 255, SyringeOpacity);
	
	SyringeString = FillStringWithZeroes(Min(int(CurrentSyringeCharge), 999), 3);
	DrawCounterTextMeticulous(C, SyringeString, TextSizeX, EmptyDigitOpacityMultiplier);
	
	C.DrawColor = C.MakeColor(255, 255, 255, 255);

	C.SetPos(BackplateACenter.X - ((BackplateSizeX * 0.5f)), (BackplateACenter.Y - (BackplateSizeY * 0.22f)) - (TextSizeY * 0.4f));
	C.DrawTileScaled(SyringeIcon, (TextSizeY / float(SyringeIcon.VSize)) * 0.8f, (TextSizeY / float(SyringeIcon.VSize)) * 0.8f);
}

simulated final function DrawAmmoText(Canvas C, Vector2D BackplateCenter)
{
	local float BackplateSizeX, BackplateSizeY;
	local float LoadedAmmoSizeX, SpareAmmoSizeX;
	local float DefaultTextSizeX, DefaultTextSizeY, LoadedAmmoSizeY;
	local float TextSizeX, TextSizeY, TextScale;
	local string CurrentLoadedAmmoString, CurrentSpareAmmoString, CurrentGrenadeCountString;

	BackplateSizeX = AmmoBackplateTextArea.X * C.ClipY;
	BackplateSizeY = AmmoBackplateTextArea.Y * C.ClipY;
	LoadedAmmoSizeX = BackplateSizeX * 0.667f;
	
	C.DrawColor = C.MakeColor(255, 255, 255, 255);

	//Get how big this font is in general for 3 digit numbers.
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize - 1);
	C.TextSize(GetStringOfZeroes(3), DefaultTextSizeX, DefaultTextSizeY);

	//Weapon Name
	if (LastKnownWeapon != None)
	{
		CurrentLoadedAmmoString = LastKnownWeapon.ItemName;
	}
	else
	{
		CurrentLoadedAmmoString = "";
	}
	
	C.SetPos(BackplateCenter.X - (BackplateSizeX * 0.5f), (BackplateCenter.Y - (BackplateSizeY * 0.5f)));
	
	C.Font = TurboHUD.LoadFont(BaseFontSize + 3);
	C.TextSize(CurrentLoadedAmmoString, TextSizeX, TextSizeY);
	C.FontScaleX = 0.75f;
	C.FontScaleY = 0.75f;

	C.DrawColor = C.MakeColor(0, 0, 0, 120);
	C.SetPos((BackplateCenter.X - (BackplateSizeX * 0.5f)) + 2.f + 2.f, ((BackplateCenter.Y - (BackplateSizeY * 0.5f)) - (TextSizeY * 0.75f)) + 2.f);
	C.DrawText(CurrentLoadedAmmoString);

	C.DrawColor = C.MakeColor(255, 255, 255, 255);
	C.SetPos((BackplateCenter.X - (BackplateSizeX * 0.5f)) + 2.f, ((BackplateCenter.Y - (BackplateSizeY * 0.5f)) - (TextSizeY * 0.75f)));
	C.DrawText(CurrentLoadedAmmoString);

	//Loaded Ammo
	CurrentLoadedAmmoString = GetLoadedAmmoString();
	C.DrawColor = C.MakeColor(255, 255, 255, Lerp(ReloadFade, 220, 120));

	TextScale = (LoadedAmmoSizeX / DefaultTextSizeX);
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize - 1);
	C.TextSize(GetStringOfZeroes(Len(CurrentLoadedAmmoString)), TextSizeX, TextSizeY);

	C.SetPos(BackplateCenter.X - (BackplateSizeX * 0.5f), BackplateCenter.Y - (TextSizeY * 0.515f));

	if (bIsSingleShotWeapon)
	{
		C.DrawColor.G = Lerp(OutOfAmmoFade, 255, 40);
		C.DrawColor.B = Lerp(OutOfAmmoFade, 255, 40);
	}
	else if (bIsMeleeGun && !bIsWelderOrSyringe)
	{
		C.DrawColor.A = 120;
	}
	
	DrawCounterTextMeticulous(C, CurrentLoadedAmmoString, TextSizeX, EmptyDigitOpacityMultiplier);

	LoadedAmmoSizeY = TextSizeY;
	SpareAmmoSizeX = BackplateSizeX - TextSizeX;

	//Spare Ammo
	CurrentSpareAmmoString = GetSpareAmmoString(); 

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 1);
	C.TextSize(GetStringOfZeroes(Len(CurrentSpareAmmoString)), TextSizeX, TextSizeY);
	
	TextScale = ((LoadedAmmoSizeY * 0.5f) / TextSizeY);
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize(GetStringOfZeroes(Len(CurrentSpareAmmoString)), TextSizeX, TextSizeY);

	C.SetPos(BackplateCenter.X + ((BackplateSizeX * 0.485f) - (TextSizeX)), (BackplateCenter.Y + (BackplateSizeY * 0.475f)) - TextSizeY);

	C.DrawColor = C.MakeColor(255, 255, 255, 220);

	if (!bIsSingleShotWeapon && (!bIsMeleeGun || bIsWelderOrSyringe))
	{
		C.DrawColor.G = Lerp(OutOfAmmoFade, 255, 40);
		C.DrawColor.B = Lerp(OutOfAmmoFade, 255, 40);
	}
	else
	{
		C.DrawColor.A = 120;
	}

	DrawCounterTextMeticulous(C, CurrentSpareAmmoString, TextSizeX, EmptyDigitOpacityMultiplier);

	//Grenade Ammo
	C.DrawColor = C.MakeColor(255, 255, 255, 220);

	if (MaxGrenadeCount >= 10)
	{
		CurrentGrenadeCountString = FillStringWithZeroes(Min(CurrentGrenadeCount, 99), 2);
	}
	else
	{
		CurrentGrenadeCountString = string(Min(CurrentGrenadeCount, 9));
	}

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 2);
	C.TextSize(GetStringOfZeroes(Len(CurrentGrenadeCountString)), TextSizeX, TextSizeY);

	TextScale = ((LoadedAmmoSizeY * 0.35f) / TextSizeY);
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize(GetStringOfZeroes(Len(CurrentGrenadeCountString)), TextSizeX, TextSizeY);

	C.SetPos(BackplateCenter.X + (BackplateSizeX * 0.49f) - (TextSizeY * 0.6f), (BackplateCenter.Y - (BackplateSizeY * 0.24f)) - (TextSizeY * 0.3f));
	C.DrawTileScaled(GrenadeIcon, (TextSizeY / float(SyringeIcon.VSize)) * 0.6f, (TextSizeY / float(SyringeIcon.USize)) * 0.6f);

	C.SetPos((BackplateCenter.X + ((BackplateSizeX * 0.49f)) - TextSizeX) - (TextSizeY * 0.6f), (BackplateCenter.Y - (BackplateSizeY * 0.24f)) - (TextSizeY * 0.5f));
	DrawCounterTextMeticulous(C, CurrentGrenadeCountString, TextSizeX, EmptyDigitOpacityMultiplier);
}

simulated final function string GetLoadedAmmoString()
{
	if (bIsMeleeGun)
	{
		if (bIsWelderOrSyringe)
		{
			return FillStringWithZeroes(Min(CurrentMagazineAmmo, 999), 3);
		}

		return "000";
	}

	return FillStringWithZeroes(Min(CurrentMagazineAmmo, 999), 3);
}

simulated final function string GetSpareAmmoString()
{
	if (bIsMeleeGun)
	{
		return "000";
	}

	if (bIsSingleShotWeapon)
	{
		return "000";
	}

	return FillStringWithZeroes(Clamp(CurrentSpareAmmo, 0, 999), 3);
}

//Secondary Ammo/Flashlight
simulated final function DrawAlternativeAmmo(Canvas C, Vector2D RightAnchor)
{
	local float BackplateSizeX, BackplateSizeY;
	local float BackplateTextSizeX, BackplateTextSizeY;
	local float BackplateCenterX, BackplateCenterY;
	local float SpacingX;
	local float TempX, TempY;
	local float TextSizeX, TextSizeY;
	local string FlashlightString;

	SpacingX = C.ClipY * BackplateSpacing.X;
	BackplateSizeX = C.ClipY * AlternateAmmoBackplateSize.X;
	BackplateSizeY = C.ClipY * AlternateAmmoBackplateSize.Y;

	BackplateTextSizeX = C.ClipY * AlternateAmmoBackplateTextArea.X;
	BackplateTextSizeY = C.ClipY * AlternateAmmoBackplateTextArea.Y;

	if (FlashlightPowerFade > 0.01f)
	{
		TempX = RightAnchor.X;
		TempY = RightAnchor.Y;

		TempX += (FlashlightOffset + (SecondaryAmmoOffset * SecondaryAmmoFade)) * ((SpacingX * 0.5f) + BackplateSizeX);

		C.DrawColor = BackplateColor;
		C.DrawColor.A = Lerp(1.f - FlashlightPowerFade, C.DrawColor.A, 0);

		C.SetPos(TempX, TempY - BackplateSizeY);
		C.DrawTileStretched(RoundedContainer, BackplateSizeX, BackplateSizeY);

		BackplateCenterX = TempX + (BackplateSizeX * 0.5f);
		BackplateCenterY = TempY - (BackplateSizeY * 0.5f);

		C.DrawColor = C.MakeColor(255, 255, 255, Max(Lerp(1.f - FlashlightPowerFade, 220, 0), 0));

		if (!bIsFlashlightOn)
		{
			C.DrawColor.A = Max(float(C.DrawColor.A) * 0.5f, 0);
		}

		//Draw bulb.
		TempX = BackplateCenterX;
		TempY = BackplateCenterY - (BackplateTextSizeY * 0.25f);
		C.SetPos(TempX - (BackplateTextSizeX * 0.4f), TempY - (BackplateTextSizeX * 0.375f));
		C.DrawTileScaled(FlashlightIcon, (BackplateTextSizeX * 0.8f) / float(SyringeIcon.USize), (BackplateTextSizeX * 0.8f) / float(SyringeIcon.VSize));

		//Draw current power.
		FlashlightString = FillStringWithZeroes(int(FlashlightPower), 3);
		
		C.FontScaleX = 1.f;
		C.FontScaleY = 1.f;
		C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 3);
		C.TextSize(GetStringOfZeroes(Len(FlashlightString)), TextSizeX, TextSizeY);
		TempY = BackplateCenterY + (BackplateTextSizeY * 0.3f);
		C.FontScaleX = BackplateTextSizeX / TextSizeX;
		C.FontScaleY = C.FontScaleX;
		C.TextSize(GetStringOfZeroes(Len(FlashlightString)), TextSizeX, TextSizeY);

		C.DrawColor = C.MakeColor(255, 255, 255, Max(Lerp(1.f - FlashlightPowerFade, 220, 0), 0));

		C.SetPos(TempX - (TextSizeX * 0.5f), TempY - (TextSizeY * 0.5f));
		DrawCounterTextMeticulous(C, FlashlightString, TextSizeX, EmptyDigitOpacityMultiplier);
	}

	if (SecondaryAmmoFade > 0.01f)
	{
		TempX = RightAnchor.X;
		TempY = RightAnchor.Y;

		TempX += SecondaryAmmoOffset * ((SpacingX * 0.5f) + BackplateSizeX);

		C.DrawColor = BackplateColor;
		C.DrawColor.A = Lerp(1.f - SecondaryAmmoFade, C.DrawColor.A, 0);

		C.SetPos(TempX, TempY - BackplateSizeY);
		C.DrawTileStretched(RoundedContainer, BackplateSizeX, BackplateSizeY);
		
		BackplateCenterX = TempX + (BackplateSizeX * 0.5f);
		BackplateCenterY = TempY - (BackplateSizeY * 0.5f);
	
		C.DrawColor = C.MakeColor(255, 255, 255, Max(Lerp(1.f - SecondaryAmmoFade, 220, 0), 0));

		if (!bWeaponSecondaryCanFire)
		{
			C.DrawColor.A = C.DrawColor.A * (((Sin(Level.TimeSeconds * 10.f) + 1.f) * 0.125f) +  0.5f);
		}

		TempX = BackplateCenterX;
		TempY = BackplateCenterY - (BackplateTextSizeY * 0.25f);

		//Draw "ALT" header text.
		C.FontScaleX = 1.f;
		C.FontScaleY = 1.f;
		C.Font = TurboHUD.LoadFont(BaseFontSize + 1);
		C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);
		C.FontScaleX = (BackplateTextSizeX / TextSizeX);
		C.FontScaleY = C.FontScaleX;
		C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);

		C.SetPos(TempX - (TextSizeX * 0.465f), TempY - (TextSizeY * 0.5f));

		DrawTextMeticulous(C, SecondaryAmmoHeader, TextSizeX);

		//Draw Secondary Ammo amount.
		FlashlightString = FillStringWithZeroes(Min(int(CurrentSpareSecondaryAmmo), 999), 3);
		
		C.FontScaleX = 1.f;
		C.FontScaleY = 1.f;
		C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 3);
		C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);
		TempY = BackplateCenterY + (BackplateTextSizeY * 0.3f);
		C.FontScaleX = BackplateTextSizeX / TextSizeX;
		C.FontScaleY = C.FontScaleX;
		C.TextSize(GetStringOfZeroes(Len(FlashlightString)), TextSizeX, TextSizeY);

		C.SetPos(TempX - (TextSizeX * 0.5f), TempY - (TextSizeY * 0.5f));
		DrawCounterTextMeticulous(C, FlashlightString, TextSizeX, EmptyDigitOpacityMultiplier);
	}

	if (MedicGunAmmoFade > 0.01f)
	{
		TempX = RightAnchor.X;
		TempY = RightAnchor.Y;

		C.DrawColor = BackplateColor;
		C.DrawColor.A = Lerp(1.f - MedicGunAmmoFade, C.DrawColor.A, 0);

		C.SetPos(TempX, TempY - BackplateSizeY);
		C.DrawTileStretched(RoundedContainer, BackplateSizeX, BackplateSizeY);
		
		BackplateCenterX = TempX + (BackplateSizeX * 0.5f);
		BackplateCenterY = TempY - (BackplateSizeY * 0.5f);
	
		C.DrawColor = C.MakeColor(255, 255, 255, Max(Lerp(1.f - MedicGunAmmoFade, 220, 0), 0));

		TempX = BackplateCenterX;
		TempY = BackplateCenterY - (BackplateTextSizeY * 0.25f);

		C.FontScaleX = 1.f;
		C.FontScaleY = 1.f;
		C.Font = TurboHUD.LoadFont(BaseFontSize + 1);
		C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);
		C.FontScaleX = (BackplateTextSizeX / TextSizeX);
		C.FontScaleY = C.FontScaleX;
		C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);

		C.SetPos(TempX - (TextSizeX * 0.465f), TempY - (TextSizeY * 0.5f));

		DrawTextMeticulous(C, SecondaryMedicGunAmmoHeader, TextSizeX);

		//Draw Secondary Ammo amount.
		FlashlightString = FillStringWithZeroes(Min(int(CurrentSpareMedicGunAmmo), 999), 3);
		
		C.FontScaleX = 1.f;
		C.FontScaleY = 1.f;
		C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 3);
		C.TextSize(GetStringOfZeroes(3), TextSizeX, TextSizeY);
		TempY = BackplateCenterY + (BackplateTextSizeY * 0.3f);
		C.FontScaleX = BackplateTextSizeX / TextSizeX;
		C.FontScaleY = C.FontScaleX;
		C.TextSize(GetStringOfZeroes(Len(FlashlightString)), TextSizeX, TextSizeY);

		C.SetPos(TempX - (TextSizeX * 0.5f), TempY - (TextSizeY * 0.5f));
		DrawCounterTextMeticulous(C, FlashlightString, TextSizeX, EmptyDigitOpacityMultiplier);
	}
}

simulated final function DrawWeight(Canvas C, Vector2D LeftAnchor)
{
	local float BackplateSizeX, BackplateSizeY;
	local float BackplateTextSizeX, BackplateTextSizeY;
	local float BackplateCenterX, BackplateCenterY;
	local float WeightTextSpaceX;
	local float SpacingX;
	local float TempX, TempY;
	local float TextSizeX, TextSizeY;
	local string WeightString;

	SpacingX = C.ClipY * BackplateSpacing.X;
	BackplateSizeX = C.ClipY * WeightBackplateSize.X;
	BackplateSizeY = C.ClipY * WeightBackplateSize.Y;

	BackplateTextSizeX = C.ClipY * WeightBackplateTextArea.X;
	BackplateTextSizeY = C.ClipY * WeightBackplateTextArea.Y;

	TempX = LeftAnchor.X;
	TempY = LeftAnchor.Y;
	BackplateCenterX = TempX - (BackplateSizeX * 0.5f);
	BackplateCenterY = TempY - (BackplateSizeY * 0.5f);

	C.DrawColor = BackplateColor;

	C.SetPos(TempX - BackplateSizeX, TempY - BackplateSizeY);
	C.DrawTileStretched(RoundedContainer, BackplateSizeX, BackplateSizeY);
	
	C.DrawColor = C.MakeColor(255, 255, 255, 220);
	C.SetPos(BackplateCenterX - (BackplateTextSizeX * 0.5f), (BackplateCenterY - (BackplateTextSizeY * 0.4f)));
	C.DrawTileScaled(WeightIcon, (BackplateTextSizeY / float(WeightIcon.VSize)) * 0.8f, (BackplateTextSizeY / float(WeightIcon.USize)) * 0.8f);

	WeightTextSpaceX = BackplateTextSizeX - (BackplateTextSizeY * 0.8f);

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 3);
	C.TextSize(GetStringOfZeroes(Len("00|00")), TextSizeX, TextSizeY);
	C.FontScaleX = WeightTextSpaceX / TextSizeX;
	C.FontScaleY = C.FontScaleX;

	WeightString = FillStringWithZeroes(Min(CurrentWeight,99), 2) $ "|" $ FillStringWithZeroes(Min(MaxCarryWeight,99), 2);
	C.TextSize(GetStringOfZeroes(Len(WeightString)), TextSizeX, TextSizeY);

	C.SetPos(BackplateCenterX + (BackplateTextSizeX * 0.5f) - (WeightTextSpaceX), BackplateCenterY - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, WeightString, TextSizeX);

	if (bEnableHitchDetection && LastHitchTime + 5.f > Level.TimeSeconds)
	{
		C.DrawColor = C.MakeColor(255, 0, 0, 255);
		C.SetPos(BackplateCenterX - BackplateSizeX, (BackplateCenterY - (BackplateSizeY * 1.5f)) - TextSizeY);
		C.Font = TurboHUD.LoadFont(BaseFontSize + 3);
		C.DrawText("HITCH FRAME TIME:"@(HitchFrameTime * 1000.f)$"ms");
	}
}

simulated final function DrawCash(Canvas C)
{
	local float BackplateSizeX, BackplateSizeY;
	local float BackplateTextSizeX, BackplateTextSizeY;
	local float BackplateCenterX, BackplateCenterY;
	local float SpacingX;
	local float TempX, TempY;
	local float TextSizeX, TextSizeY;
	local string DrawString;
	local float TotalSizeX;

	SpacingX = C.ClipY * BackplateSpacing.Y;
	BackplateSizeX = C.ClipY * CashBackplateSize.X;
	BackplateSizeY = C.ClipY * CashBackplateSize.Y;
	BackplateTextSizeX = C.ClipY * CashBackplateTextArea.X;
	BackplateTextSizeY = C.ClipY * CashBackplateTextArea.Y;

	C.DrawColor = BackplateColor;
	C.SetPos(C.ClipX * 0.5f, C.ClipY * 0.5f);

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(BaseFontSize + 2);
	DrawString = Max(CurrentPlayerCash, TargetPlayerCash) @ class'KFTab_BuyMenu'.default.MoneyCaption;
	C.TextSize(GetStringOfZeroes(Len(DrawString)), TextSizeX, TextSizeY);
	C.FontScaleY = (BackplateTextSizeY / TextSizeY) * 1.25f;
	C.FontScaleX = C.FontScaleY;
	C.TextSize(GetStringOfZeroes(Len(DrawString)), TextSizeX, TextSizeY);

	DesiredCashBackplateX = TextSizeX;

	if (CurrentCashBackplateX < DesiredCashBackplateX)
	{
		CurrentCashBackplateX = DesiredCashBackplateX;
	}

	TotalSizeX = CurrentCashBackplateX + (BackplateSizeX - BackplateTextSizeX);

	DrawString = int(CurrentPlayerCash) @ class'KFTab_BuyMenu'.default.MoneyCaption;
	
	TempX = (C.ClipX - SpacingX) - TotalSizeX;
	TempY = (C.ClipY - (C.ClipY * BackplateSpacing.Y)) - BackplateSizeY;
	BackplateCenterX = TempX + (TotalSizeX * 0.5f);
	BackplateCenterY = TempY + (BackplateSizeY * 0.5f);
	
	C.SetPos(TempX, TempY);
	C.DrawTileStretched(RoundedContainer, TotalSizeX, BackplateSizeY);
	
	C.DrawColor = C.MakeColor(255, 255, 255, 220);
	C.TextSize(GetStringOfZeroes(Len(DrawString)), TextSizeX, TextSizeY);
	C.SetPos(((TempX + TotalSizeX) - ((BackplateSizeX - BackplateTextSizeX) * 0.5f)) - TextSizeX, BackplateCenterY - (TextSizeY * 0.5f));
	DrawCounterTextMeticulous(C, DrawString, TextSizeX, EmptyDigitOpacityMultiplier);

	if (CurrentPlayerCashReceive > 0.25f)
	{
		C.DrawColor = C.MakeColor(32, 255, 96, 255);
		C.FontScaleY = C.FontScaleY * Lerp(FMin(CurrentPlayerCashReceive / CurrentPlayerCashReceiveDivisor, 1.f), 0.25f, 0.75f);
		C.FontScaleY *= Lerp(FMin(CurrentPlayerCashReceiveDivisor / 1000.f, 1.f), 1.f, 2.f);
		C.FontScaleX = C.FontScaleY;
		C.DrawColor.A = 255.f * Lerp(FMin(CurrentPlayerCashReceive / CurrentPlayerCashReceiveDivisor, 1.f), 0.f, 1.f);

		DrawString = int(CurrentPlayerCashReceive) $ "+";
		C.TextSize(GetStringOfZeroes(Len(DrawString)), TextSizeX, TextSizeY);
		C.SetPos(TempX - TextSizeX, BackplateCenterY - (TextSizeY * 0.5f));
		DrawCounterTextMeticulous(C, DrawString, TextSizeX, EmptyDigitOpacityMultiplier);
		C.bCenter = false;
	}
}

simulated final function DrawPerk(Canvas C)
{
	local float TopX, TopY, PerkX, PerkY;
	local float SizeX, SizeY;
	local int NumStars, Index, Counter;
	local Material PerkMaterial, PerkStarMaterial;
	local float PerkDrawSize, PerkStarSize;
	local Color PerkDrawColor;

	if (PlayerPerk == None)
	{
		return;
	}

	TopX = C.ClipY * (BackplateSpacing.Y + PerkProgressOffset.X);
	TopY = C.ClipY * ((1.f - BackplateSpacing.Y) + PerkProgressOffset.Y);
	SizeX = C.ClipY * PerkProgressSize.X;
	SizeY = C.ClipY * PerkProgressSize.Y;
	TopY -= SizeY;

	NumStars = PlayerPerk.Static.PreDrawPerk(C, PerkLevel, PerkMaterial, PerkStarMaterial);
	C.DrawColor.A = 240;
	PerkDrawColor = C.DrawColor;

	PerkX = TopX + (SizeX * PerkIconOffset.X);
	PerkY = TopY + (SizeY * PerkIconOffset.Y);
	PerkDrawSize = SizeX * PerkDrawScale;
	PerkY -= PerkDrawSize;

	C.DrawColor = C.MakeColor(16, 16, 16, 200);
	C.SetPos(PerkX + 1.f, PerkY + 2.f);
	C.DrawTile(PerkMaterial, PerkDrawSize, PerkDrawSize, 0, 0, PerkMaterial.MaterialUSize(), PerkMaterial.MaterialVSize());
	
	C.DrawColor = PerkDrawColor;
	C.SetPos(PerkX, PerkY);
	C.DrawTile(PerkMaterial, PerkDrawSize, PerkDrawSize, 0, 0, PerkMaterial.MaterialUSize(), PerkMaterial.MaterialVSize());

	Counter = 0;
	PerkStarSize = PerkDrawSize * 0.15f;
	PerkX += ((PerkDrawSize) - (PerkStarSize * 1.5f));
	PerkY += (PerkDrawSize - (PerkStarSize * 0.5f)) * 0.75f;

	for ( Index = 0; Index < NumStars; Index++ )
	{
		C.SetPos(PerkX, PerkY - (float(Counter) * PerkDrawSize * 0.15f));
		C.DrawTile(PerkStarMaterial, PerkStarSize, PerkStarSize, 0, 0, PerkStarMaterial.MaterialUSize(), PerkStarMaterial.MaterialVSize());

		if( ++Counter==5 )
		{
			Counter = 0;
			PerkX += (PerkStarSize * 0.75);
		}
	}
	
	C.DrawColor.A = 255;
	class'TurboHUDPerkProgressDrawer'.static.DrawPerkProgress(C, TopX, TopY, SizeX, SizeY, PerkProgress, C.MakeColor(16,16,16,240), C.DrawColor);
}

defaultproperties
{
	BaseFontSize = 2

	BackplateColor=(R=0,G=0,B=0,A=140)

	HealthBackplateSize=(X=0.2f,Y=0.075f)
	HealthBackplateTextArea=(X=0.19f,Y=0.078f)

	AmmoBackplateSize=(X=0.2f,Y=0.075f)
	AmmoBackplateTextArea=(X=0.19f,Y=0.076f)

	AlternateAmmoBackplateSize=(X=0.06f,Y=0.075f)
	AlternateAmmoBackplateTextArea=(X=0.045f,Y=0.065f)
	FlashlightPowerFadeRate=2.f
	SecondaryAmmoFadeRate=4.f
	SecondaryAmmoHeader="ALT"
	SecondaryMedicGunAmmoHeader="MED"

	WeightBackplateSize=(X=0.1125f,Y=0.035f)
	WeightBackplateTextArea=(X=0.1f,Y=0.035f)

	CashBackplateSize=(X=0.2f,Y=0.045f)
	CashBackplateTextArea=(X=0.18f,Y=0.035f)

	PerkProgressSize=(X=0.075f,Y=0.075f)
	PerkProgressOffset=(X=-0.01f,Y=0.01f)
	PerkIconOffset=(X=0.275f,Y=0.41f)
	PerkProgressColor=(R=255,G=32,B=32,A=255)
	PerkDrawScale=1.f

	BackplateSpacing=(X=0.04f,Y=0.02f)

	EmptyDigitOpacityMultiplier = 0.5f

	RoundedContainer=Texture'KFTurbo.HUD.ContainerRounded_D'

	HealingMaterial=FinalBlend'KFTurbo.HUD.Healing_FB'

	CurrentHealth=-1.f
	HealthInterpRate=8.f
	CurrentArmor=-1.f
	ArmorInterpRate=6.f
	CurrentSyringeCharge=-1.f
	SyringeInterpRate=4.f
	CurrentHealingInterpRate=4.f
	WelderInterpRate=2.f
	CashInterpRate=2.f
	ReceivedCashDecayDelay=2.f

	ReloadFadeRate=6.f
	OutOfAmmoFadeRate=3.f
	
	SyringeIcon=Texture'KFTurbo.Ammo.SyringeIcon_D'
	GrenadeIcon=Texture'KFTurbo.Ammo.NadeIcon_D'
	FlashlightIcon=Texture'KFTurbo.Ammo.BulbIcon_D'
	WeightIcon=Texture'KFTurbo.Ammo.WeightIcon_D'

	FrameTimeIndex=0
}