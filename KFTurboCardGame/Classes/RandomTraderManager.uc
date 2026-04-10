//Killing Floor Turbo RandomTraderManager
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class RandomTraderManager extends Engine.Info;

var KFTurboGameType KFGameType;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    KFGameType = KFTurboGameType(Level.Game);

    SetTimer(0.1f + (FRand() * 0.4f), false);
}

function Timer()
{
    SetTimer(0.1f + (FRand() * 0.4f), false);

    if (KFGameType == None || !KFGameType.bWaveInProgress)
    {
        return;
    }

    KFGameType.SelectShop();
}

defaultproperties
{

}