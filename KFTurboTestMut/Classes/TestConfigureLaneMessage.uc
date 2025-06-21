class TestConfigureLaneMessage extends TestLaneMessage;

var localized string ConfigureWaveString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(default.ConfigureWaveString);
}

defaultproperties
{
    ConfigureWaveString="%dPress %kuse%d to %kconfigure lane settings%d."
}