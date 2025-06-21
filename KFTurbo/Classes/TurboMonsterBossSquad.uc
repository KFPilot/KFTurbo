//Killing Floor Turbo TurboMonsterBossSquad
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMonsterBossSquad extends Object
     editinlinenew;

var TurboMonsterSquad Squad;
var int SquadSizePerPlayerCount[6];

final function InitializeSquad(TurboMonsterCollection TurboCollection)
{
     if (Squad != None)
     {
          Squad.InitializeSquad(TurboCollection);
     }
}

defaultproperties
{
     SquadSizePerPlayerCount(0)=8
     SquadSizePerPlayerCount(1)=8
     SquadSizePerPlayerCount(2)=12
     SquadSizePerPlayerCount(3)=12
     SquadSizePerPlayerCount(4)=14
     SquadSizePerPlayerCount(5)=16
}