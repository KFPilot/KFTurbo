//Killing Floor Turbo KFTurboFontsCY
//Handles Cyrillic fonts for KFTurbo.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboFontHelperCY extends KFTurboFontHelper;

#exec new TrueTypeFontFactory Name=BahnschriftSemiLight72 FontName="Bahnschrift SemiLight Condensed" Height=72 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"

#exec TEXTURE COMPRESS NAME=KFTurboFontHelperCY.BahnschriftSemiLight72_PageA FORMAT=DXT3

#exec new TrueTypeFontFactory Name=BahnschriftSemiLight48 FontName="Bahnschrift SemiLight Condensed" Height=48 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight36 FontName="Bahnschrift SemiLight Condensed" Height=36 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight24 FontName="Bahnschrift SemiLight Condensed" Height=24 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight18 FontName="Bahnschrift SemiLight Condensed" Height=18 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight12 FontName="Bahnschrift SemiLight Condensed" Height=12 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight9 FontName="Bahnschrift SemiLight Condensed" Height=9 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"


#exec new TrueTypeFontFactory Name=BahnschriftBold72 FontName="Bahnschrift Bold SemiCondensed" Height=72 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftBold48 FontName="Bahnschrift Bold SemiCondensed" Height=48 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftBold36 FontName="Bahnschrift Bold SemiCondensed" Height=36 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftBold24 FontName="Bahnschrift Bold SemiCondensed" Height=24 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftBold18 FontName="Bahnschrift Bold SemiCondensed" Height=18 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftBold12 FontName="Bahnschrift Bold SemiCondensed" Height=12 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=BahnschriftBold9 FontName="Bahnschrift Bold SemiCondensed" Height=9 AntiAlias=1 XPad=2 Kerning=0 UnicodeRange="0400-052F"

#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic72 FontName="LEMON MILK Bold Italic" Height=72 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-2 Italic=1 Style=700 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic36 FontName="LEMON MILK Bold Italic" Height=36 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-4 Italic=1 Style=700 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic18 FontName="LEMON MILK Bold Italic" Height=18 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=700 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic12 FontName="LEMON MILK Bold Italic" Height=12 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=700 UnicodeRange="0400-052F"

#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic72 FontName="LEMON MILK Bold Italic" Height=72 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-2 Italic=1 Style=500 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic36 FontName="LEMON MILK Bold Italic" Height=36 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-4 Italic=1 Style=500 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic18 FontName="LEMON MILK Bold Italic" Height=18 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=600 UnicodeRange="0400-052F"
#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic12 FontName="LEMON MILK Bold Italic" Height=12 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=600 UnicodeRange="0400-052F"

defaultproperties
{
	HUDFontArrayNames(0)="KFTurboFontsCY.BahnschriftSemiLight72"
	HUDFontArrayNames(1)="KFTurboFontsCY.BahnschriftSemiLight72"
	HUDFontArrayNames(2)="KFTurboFontsCY.BahnschriftSemiLight48"
	HUDFontArrayNames(3)="KFTurboFontsCY.BahnschriftSemiLight36"
	HUDFontArrayNames(4)="KFTurboFontsCY.BahnschriftSemiLight24"
	HUDFontArrayNames(5)="KFTurboFontsCY.BahnschriftSemiLight18"
	HUDFontArrayNames(6)="KFTurboFontsCY.BahnschriftSemiLight12"
	HUDFontArrayNames(7)="KFTurboFontsCY.BahnschriftSemiLight9"

	HUDBoldFontArrayNames(0)="KFTurboFontsCY.BahnschriftBold72"
	HUDBoldFontArrayNames(1)="KFTurboFontsCY.BahnschriftBold72"
	HUDBoldFontArrayNames(2)="KFTurboFontsCY.BahnschriftBold48"
	HUDBoldFontArrayNames(3)="KFTurboFontsCY.BahnschriftBold36"
	HUDBoldFontArrayNames(4)="KFTurboFontsCY.BahnschriftBold24"
	HUDBoldFontArrayNames(5)="KFTurboFontsCY.BahnschriftBold18"
	HUDBoldFontArrayNames(6)="KFTurboFontsCY.BahnschriftBold12"
	HUDBoldFontArrayNames(7)="KFTurboFontsCY.BahnschriftBold9"
	
	HUDItalicFontArrayNames(0)="KFTurboFontsCY.LemonMilkRegularItalic72"
	HUDItalicFontArrayNames(1)="KFTurboFontsCY.LemonMilkRegularItalic36"
	HUDItalicFontArrayNames(2)="KFTurboFontsCY.LemonMilkRegularItalic18"
	HUDItalicFontArrayNames(3)="KFTurboFontsCY.LemonMilkRegularItalic12"

	HUDBoldItalicFontArrayNames(0)="KFTurboFontsCY.LemonMilkBoldItalic72"
	HUDBoldItalicFontArrayNames(1)="KFTurboFontsCY.LemonMilkBoldItalic36"
	HUDBoldItalicFontArrayNames(2)="KFTurboFontsCY.LemonMilkBoldItalic18"
	HUDBoldItalicFontArrayNames(3)="KFTurboFontsCY.LemonMilkBoldItalic12"
}