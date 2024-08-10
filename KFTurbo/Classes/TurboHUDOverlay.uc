class TurboHUDOverlay extends HudOverlay;

struct Vector2D
{
	var() float X;
	var() float Y;
};

var Vector2D LastKnownClipSize;
var Vector2D ClipSize;

var TurboHUDKillingFloor KFPHUD;

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	KFPHUD = OwnerHUD;
}

//If you want screensize updates (or initial call), always call Super.Render(C) on subclasses.
simulated function Render(Canvas C)
{
	if (KFPHUD == None)
	{
		return;
	}

	if (LastKnownClipSize.X != C.ClipX || LastKnownClipSize.Y != C.ClipY)
	{
		ClipSize.X = C.ClipX;
		ClipSize.Y = C.ClipY;

		OnScreenSizeChange(C, ClipSize, LastKnownClipSize);
		
		LastKnownClipSize.X = C.ClipX;
		LastKnownClipSize.Y = C.ClipY;
	}
}

event OnScreenSizeChange(Canvas C, Vector2D CurrentClipSize, Vector2D PreviousClipSize);

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