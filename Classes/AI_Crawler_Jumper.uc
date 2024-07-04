class AI_Crawler_Jumper extends CrawlerController;

function bool IsInPounceDist(actor PTarget)
{
    local KFMonster Monster;
    local float PreviousMeleeRange;
    local bool bResult;

    Monster = KFMonster(Pawn);
    bResult = false;
    if (Monster != None)
    {
        PreviousMeleeRange = Monster.MeleeRange;
        Monster.MeleeRange = PreviousMeleeRange * 4.f;

        bResult = Super.IsInPounceDist(PTarget);
        
        Monster.MeleeRange = PreviousMeleeRange;
    }

    return bResult;
}

defaultproperties
{
}
