class TurboAccoladeAchievementLocalMessage extends TurboAccoladeLocalMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    //Routes to TurboAchievementPackImpl::GetLocalString()
    if ( class<TurboAchievementPackImpl>(OptionalObject) != None )
    {
        return class<TurboAchievementPackImpl>(OptionalObject).static.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
    }

    return "";
}

defaultproperties
{
    bDisplayForAccoladeEarner=true
}