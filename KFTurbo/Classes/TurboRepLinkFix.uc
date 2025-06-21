//Killing Floor Turbo TurboRepLinkFix
//Fixes up CPRLs that get broken due to replication quirks
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboRepLinkFix extends Info;

var int VerifyCount;
var bool bHasValidatedCPRL;
var bool bHasValidatedTRL;

simulated function BeginPlay()
{
	bHasValidatedCPRL = false;
	bHasValidatedTRL = false;

    SetTimer(4.f, true);
}

simulated function Timer()
{
	local PlayerController PlayerController;
 
	PlayerController = PlayerController(Owner);

	if (PlayerController == None || PlayerController.PlayerReplicationInfo == None)
    {
		return;
    }

	//Wait until CPRL gives us the all clear.
	if (!bHasValidatedCPRL && !ValidateClientPerkRepLink(PlayerController))
	{
		return;
	}

	if (!bHasValidatedCPRL)
	{
		bHasValidatedCPRL = true;
		VerifyCount = 0;
	}
    
	//Test TRL until it gives us the all clear.
	if (!bHasValidatedTRL && !ValidateTurboRepLink(PlayerController))
	{
		return;
	}

	bHasValidatedTRL = true;
	
	SetTimer(0.f, false);
	Destroy();
}

simulated function bool ValidateClientPerkRepLink(PlayerController PlayerController)
{
	local ClientPerkRepLink CPRL;

	CPRL = class'ClientPerkRepLink'.Static.FindStats(PlayerController);

	if (CPRL != None)
	{
        if (VerifyCount > 60)
        {
            return true;
        }

        VerifyCount++;
		return false;
	}

	VerifyCount = 0;
	
    foreach DynamicActors(Class'ClientPerkRepLink', CPRL)
	{
		CPRL.SetOwner(PlayerController);
		CPRL.RepLinkBroken();
	}

	return false;
}

simulated function bool ValidateTurboRepLink(PlayerController PlayerController)
{
	local TurboRepLink TRL;

	TRL = class'TurboRepLink'.Static.FindTurboRepLink(PlayerController);

	if (TRL != None)
	{
        if (VerifyCount > 60)
        {
            return true;
        }

        VerifyCount++;
		return false;
	}

	VerifyCount = 0;
	
    foreach DynamicActors(Class'TurboRepLink', TRL)
	{
		TRL.SetOwner(PlayerController);
		TRL.RepLinkBroken();
	}

	return false;
}
 
defaultproperties
{

}