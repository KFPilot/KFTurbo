//Killing Floor Turbo TurboHUDOverlay
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDOverlay extends HudOverlay;

struct Vector2D
{
	var() float X;
	var() float Y;
};

var Vector2D LastKnownScreenSize;
var Vector2D ScreenSize;

var TurboHUDKillingFloor TurboHUD;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	TurboHUD = TurboHUDKillingFloor(Owner);
}

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	TurboHUD = OwnerHUD;
}

simulated final function TurboPlayerController GetController()
{
	return TurboPlayerController(TurboHUD.PlayerOwner);
}

simulated final function Pawn GetPawn()
{
	return TurboHUD.PlayerOwner.Pawn;
}

simulated final function KFWeapon GetWeapon()
{
	if (TurboHUD.PlayerOwner.Pawn != None)
	{
		return KFWeapon(TurboHUD.PlayerOwner.Pawn.Weapon);
	}

	return None;
}

//If you want screensize updates (or initial call), always call Super.Render(C) on subclasses.
simulated function Render(Canvas C)
{
	if (TurboHUD == None)
	{
		return;
	}
	
	if (LastKnownScreenSize.X != C.SizeX || LastKnownScreenSize.Y != C.SizeY)
	{
		ScreenSize.X = C.SizeX;
		ScreenSize.Y = C.SizeY;

		OnScreenSizeChange(C, ScreenSize, LastKnownScreenSize);
		
		LastKnownScreenSize = ScreenSize;
	}
}

event OnScreenSizeChange(Canvas C, Vector2D CurrentScreenSize, Vector2D PreviousScreenSize);

static final function String GetStringOfZeroes(int NumberOfDigits)
{
	local String Result;

	Result = string(0);

	while (Len(Result) < NumberOfDigits)
	{
		Result = "0" $ Result;
	}

	return Result;
}

static final function String FillStringWithZeroes(coerce String String, int NumberOfDigits)
{
	if (Len(String) > NumberOfDigits)
	{
		return Right(String, NumberOfDigits);
	}

	while (Len(String) < NumberOfDigits)
	{
		String = "0" $ String;
	}

	return String;
}

static final function DrawTextMeticulous(Canvas C, coerce String String, float SizeX)
{
	local String StringToDraw;
	local float SubStringSizeX, SubStringSizeY;
	local float RootX, RootY;

	SizeX /= float(Len(String));

	RootX = C.CurX;
	RootY = C.CurY;

	while (Len(String) > 0)
	{
		StringToDraw = Left(String, 1);

		C.TextSize(StringToDraw, SubStringSizeX, SubStringSizeY);
		C.CurX += (SizeX * 0.5f) - (SubStringSizeX * 0.5f);

		C.DrawText(StringToDraw);

		if (Len(String) == 1)
		{
			break;
		}

		RootX += SizeX;
		C.CurX = RootX;
		C.CurY = RootY;
		String = Right(String, Len(String) - 1);
	}
}

static final function DrawCounterTextMeticulous(Canvas C, String String, float SizeX, float EmptyDigitOpacityMultiplier)
{
	local String StringToDraw;
	local float SubStringSizeX, SubStringSizeY;
	local byte RegularAlpha;
	local float RootX, RootY;
	local bool bFoundRegularDigit;
	SizeX /= float(Len(String));

	RootX = C.CurX;
	RootY = C.CurY;

	bFoundRegularDigit = false;
	RegularAlpha = C.DrawColor.A;
	C.DrawColor.A = Ceil(float(C.DrawColor.A) * EmptyDigitOpacityMultiplier);

	while (Len(String) > 0)
	{
		StringToDraw = Left(String, 1);

		if (!bFoundRegularDigit && int(StringToDraw) != 0)
		{
			bFoundRegularDigit = true;
			C.DrawColor.A = RegularAlpha;
		}

		C.TextSize(StringToDraw, SubStringSizeX, SubStringSizeY);
		C.CurX += (SizeX * 0.5f) - (SubStringSizeX * 0.5f);

		C.DrawText(StringToDraw);

		if (Len(String) == 1)
		{
			break;
		}

		RootX += SizeX;
		C.CurX = RootX;
		C.CurY = RootY;
		String = Right(String, Len(String) - 1);
	}
}

//A MakeColor that doesn't randomly map 0 to 255.
static final function Color MakeColor(byte R, byte G, byte B, byte A)
{
	local Color C;

	C.R = R;
	C.G = G;
	C.B = B;
	C.A = A;
	return C;
}