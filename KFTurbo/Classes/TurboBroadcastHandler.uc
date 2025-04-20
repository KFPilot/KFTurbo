//Killing Floor Turbo TurboBroadcastHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboBroadcastHandler extends Engine.BroadcastHandler;

function AllowBroadcastLocalized( Actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	//Ignore broken no late joiner message.
	if (Message == Level.Game.GameMessageClass && Switch == 16)
	{
		return;
	}

	switch(Message)
	{
		case class'KFMod.WaitingMessage':
			Message = class'TurboMessageWaiting';
			break;
		case class'ServerPerks.KFVetEarnedMessagePL':
			Message = class'TurboAccoladePerkLocalMessage';
			break;
	}

	Super.AllowBroadcastLocalized(Sender, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{

}
