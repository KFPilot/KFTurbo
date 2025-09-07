//Killing Floor Turbo TurboMapListLoader
//For some reason map prefixes are not checked for uniqueness? And there's no way to modify the expected map extension?
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapListLoader extends DefaultMapListLoader;

function LoadMapList(xVotingHandler VotingHandler)
{
	local int Index, UniqueIndex;
	local bool bFoundPrefix;
	local array<string> PrefixList;
	local array<string> UniquePrefixList;

	if (bUseMapList)
	{
		log("Using MapList instead of name prefixes... ", 'MapVote');
		Super.LoadMapList(VotingHandler);
		return;
	}

	if (MapNamePrefixes == "")
	{
		for (Index = 0; Index < VotingHandler.GameConfig.Length; Index++)
		{
			MapNamePrefixes $= VotingHandler.GameConfig[Index].Prefix;
			
			if (Index < VotingHandler.GameConfig.Length - 1)
			{
				MapNamePrefixes $= ",";
			}
		}
	}

	//Not sure why this was before we potentially modify the string.
	log("Loading Maps with the following prefixes: " $ MapNamePrefixes, 'MapVote');

	PrefixList.Length = 0;
	if (Split(MapNamePrefixes, ",", PrefixList) == 0)
	{
		return;
	}
	
	//Ensure prefixes are unique.
	for (Index = 0; Index < PrefixList.Length; Index++)
	{
		bFoundPrefix = false;
		for (UniqueIndex = 0; UniqueIndex < UniquePrefixList.Length; UniqueIndex++)
		{
			if (UniquePrefixList[UniqueIndex] ~= PrefixList[Index])
			{
				bFoundPrefix = true;
				break;
			}
		}

		if (!bFoundPrefix)
		{
			UniquePrefixList[UniquePrefixList.Length] = PrefixList[Index];
		}
	}

	for (Index = 0; Index < UniquePrefixList.Length; Index++)
	{
		log("Loading Maps with prefix " $ UniquePrefixList[Index] $".", 'MapVote');
		LoadFromPrefix(UniquePrefixList[Index], VotingHandler);
	}
}

function LoadFromPreFix(string Prefix, xVotingHandler VotingHandler)
{
	local string FirstMap, NextMap, MapName, TestMap;
	local bool bHasExtension;

	FirstMap = Level.GetMapName(Prefix, "", 0);
	NextMap = FirstMap;
	
	while(!(FirstMap ~= TestMap))
	{
		MapName = NextMap;

		//Check for .rom instead of .ut2
		bHasExtension = Right(MapName, 4) ~= ".rom";
		if (bHasExtension)
		{
			MapName = Left(MapName, Len(MapName) - 4);  // remove ".rom"
		}

		VotingHandler.AddMap(MapName, "", "");
		NextMap = Level.GetMapName(Prefix, NextMap, 1);
		TestMap = NextMap;
	}
}

//Have to copy the whole function over just to remove the extension...
function LoadFromMapList(string MapListType, xVotingHandler VotingHandler)
{
	local string Mutators,GameOptions;
	local class<MapList> MapListClass;
	local string MapName;
	local array<string> Parts;
	local array<string> Maps;
	local int x, i;
	local bool bHasExtension;

	MapListClass = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
	if (MapListClass == None)
	{
		Log("___Couldn't load maplist type: "$MaplistType,'MapVote');
		return;
	}

	Maps = MapListClass.static.StaticGetMaps();
	for (i = 0; i < Maps.Length; i++)
	{
		Mutators = "";
		GameOptions = "";

		MapName = Maps[i];
		
		Parts.Length = 0;
		
		if (Split(MapName, "?", Parts) > 1)
		{
			MapName = Parts[0];
			for (x=1; x < Parts.Length; x++)
			{
				if (Left(Parts[x],8) ~= "Mutator=")
				{
					Mutators = Mid(Parts[x],8);
				}
				else
				{
					if (!(Left(Parts[x],5) ~= "Game="))
					{
						if(GameOptions == "")
						{
							GameOptions = Parts[x];
						}
						else
						{
							GameOptions = GameOptions $ "?" $ Parts[x];
						}
					}
				}
			}
		}

		//Check for .rom instead of .ut2
		bHasExtension = Right(MapName, 4) ~= ".rom";
		if (bHasExtension)
		{
			MapName = Left(MapName, Len(MapName) - 4);  // remove ".rom"
		}

		VotingHandler.AddMap(MapName, Mutators, GameOptions);
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	PlayInfo.AddClass(class'DefaultMapListLoader');
	PlayInfo.AddSetting(default.MapVoteGroup,"bUseMapList",default.UseMapListPropsDisplayText,0,1,"Check",,,True,True);
	PlayInfo.PopClass();
}

defaultproperties
{
	bUseMapList=false
}