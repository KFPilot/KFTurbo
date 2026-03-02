//Killing Floor Turbo TurboRelayBroadcastHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboRelayBroadcastHandler extends BroadcastHandler;

var TurboRelayTcpLink RelayTcpLink;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    RelayTcpLink = TurboRelayTcpLink(Owner);
}

function Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
    local PlayerController SenderPlayerController;

    Super.Broadcast(Sender, Msg, Type);

    if (RelayTcpLink == None)
    {
        return;
    }

	if (Pawn(Sender) != None)
    {
		SenderPlayerController = PlayerController(Pawn(Sender).Controller);
    }
	else if (PlayerController(Sender) != None)
    {
		SenderPlayerController = PlayerController(Sender);
    }
    else if (PlayerReplicationInfo(Sender) != None)
    {
		SenderPlayerController = PlayerController(Sender.Owner);
    }

    if (SenderPlayerController == None)
    {
        return;
    }

    switch (Type)
    {
        case 'Say':
        case 'TeamSay':
            if (Repl(Msg, " ", "") == "")
            {
                return;
            }

            RelayTcpLink.RelayMessage(SenderPlayerController, Msg);
    }
}