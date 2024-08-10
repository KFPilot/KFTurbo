//Fixes up CPRLs that get broken due to replication quirks
class TurboRepLinkFix extends Info;

var int VerifyCount;

simulated function BeginPlay()
{
    SetTimer(4.f, true);
}

simulated function Timer()
{
	local ClientPerkRepLink CPRL;
	local PlayerController PlayerController;
 
	PlayerController = PlayerController(Owner);

	if (PlayerController == None || PlayerController.PlayerReplicationInfo == None)
    {
		return;
    }
    
	CPRL = class'ClientPerkRepLink'.Static.FindStats(PlayerController);

	if (CPRL != None)
	{
        if (VerifyCount > 30)
        {
			SetTimer(0, false);
            Destroy();
            return;
        }

        VerifyCount++;
		return;
	}

	VerifyCount = 0;
	
    foreach DynamicActors(Class'ClientPerkRepLink', CPRL)
	{
		if (CPRL.Owner == None)
        {
			CPRL.SetOwner(PlayerController);
        }

		CPRL.RepLinkBroken();
	}
}
 
defaultproperties
{
	NetUpdateFrequency=1
}