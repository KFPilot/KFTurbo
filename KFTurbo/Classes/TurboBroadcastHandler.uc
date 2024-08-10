class TurboBroadcastHandler extends Engine.BroadcastHandler;

event AllowBroadcastLocalized( Actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
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
