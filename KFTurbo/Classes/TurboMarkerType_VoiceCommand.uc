class TurboMarkerType_VoiceCommand extends TurboMarkerType
    abstract;

//Simplified voice command list to help us figure out what voice command was used.
enum ETurboVoiceCommand{
    //Support
    Medic,
    Help,

    //Alert
    Run,
    WaitForMe,
    LetsHoleUpHere,
    FollowMe,

    //Direction
    GoUpstairs,
    HeadDownstairs,
    GetInside,
    GoOutside
};

static function int GetGenerateMarkerDataFromVoiceCommand(Name Type, int Index)
{
	switch(Type)
	{
		case 'SUPPORT':
			switch(Index)
			{
				case 0:
					return ETurboVoiceCommand.Medic;
				case 1:
					return ETurboVoiceCommand.Help;
			}
			break;
		case 'ALERT':
			switch(Index)
			{
				case 1:
                    return ETurboVoiceCommand.Run;
				case 2:
                    return ETurboVoiceCommand.WaitForMe;
				case 4:
                    return ETurboVoiceCommand.LetsHoleUpHere;
				case 5:
                    return ETurboVoiceCommand.FollowMe;
			}
			break;
		case 'direction':
			switch(Index)
			{
				case 1:
                    return ETurboVoiceCommand.GoUpstairs;
				case 2:
                    return ETurboVoiceCommand.HeadDownstairs;
				case 3:
                    return ETurboVoiceCommand.GetInside;
				case 4:
                    return ETurboVoiceCommand.GoOutside;
			}
			break;
	}

    return -1;
}

static function float GetMarkerDuration(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    switch(ETurboVoiceCommand(MarkerData))
    {
        case Help:
        case LetsHoleUpHere:
            return 20.f;
        case Run:
        case WaitForMe:
        case FollowMe:
            return 15.f;
        case GoUpstairs:
        case HeadDownstairs:
        case GetInside:
        case GoOutside:
            return 10.f;
    }
}

static function bool ShouldReceiveLocationUpdate(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    switch(ETurboVoiceCommand(MarkerData))
    {
        case LetsHoleUpHere:
            return false;
    }

    return true;
}

static function String GenerateMarkerDisplayString(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    local class<KFVoicePack> VoicePack;
    VoicePack = class'KFVoicePack';

    switch(ETurboVoiceCommand(MarkerData))
    {
        case Medic:
            return VoicePack.default.SupportString[0];
        case Help:
            return VoicePack.default.SupportString[1];
            
        case Run:
            return VoicePack.default.AlertString[1];
        case WaitForMe:
            return VoicePack.default.AlertString[2];
        case LetsHoleUpHere:
            return VoicePack.default.AlertString[4];
        case FollowMe:
            return VoicePack.default.AlertString[5];

        case GoUpstairs:
            return VoicePack.default.DirectionString[1];
        case HeadDownstairs:
            return VoicePack.default.DirectionString[2];
        case GetInside:
            return VoicePack.default.DirectionString[3];
        case GoOutside:
            return VoicePack.default.DirectionString[4];
    }

    return "";
}