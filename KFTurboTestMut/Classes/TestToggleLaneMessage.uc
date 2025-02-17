class TestToggleLaneMessage extends TestLaneMessage;

var localized string SetWaveStateString;
var localized string ActivateString;
var localized string DeactivateString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(Repl(default.SetWaveStateString, "%s", Eval(TestLaneWaveManager(OptionalObject).bIsActive, default.DeactivateString, default.ActivateString)));
}

defaultproperties
{
    SetWaveStateString="%dPress %kuse%d to %k%s%d the %klane%d."
    ActivateString="activate"
    DeactivateString="deactivate"
}