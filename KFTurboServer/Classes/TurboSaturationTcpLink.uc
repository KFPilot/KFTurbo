//Killing Floor Turbo TurboSaturationTcpLink
//Responsible for listening for packet notifying server that connection is saturated.
//Optional way of doing this. This is the easiest way to handle this for KFTurbo deployments.
//Other server owners may have their own preferred way of handling this.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboSaturationTcpLink extends TurboTcpLink
    config(KFTurbo);

var const globalconfig int ListenPort;
var const int PauseDuration;
var float PauseTimeRemaining;
var float PauseContinueMessageTimeRemaining;

var float ManualUnpauseOverrideTime;
var const int ManualUnpauseOverrideDuration;

function PostBeginPlay()
{
    log("KFTurboServer has created a staturation TCP link!", 'TurboSaturationTcpLink');

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;

    SetTimer(FRand() + 1.f, false);

    KFTurboGameType(Level.Game).OnServerManuallyUnpaused = OnManuallyUnpaused;
}

function OnManuallyUnpaused(Object Unpauser)
{

}

function Timer()
{
    BindPort(ListenPort);
    Listen();
}

function ReceivedText(string Text)
{
    if (ManualUnpauseOverrideTime > 0.f && ManualUnpauseOverrideTime > Level.TimeSeconds)
    {
        return;
    }

    if (Text ~= "SATURATED")
    {
        GotoState('PauseGame');
    }
}

function PlayerReplicationInfo GetMessagingSpectatorPRI()
{
    local Controller C;
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (MessagingSpectator(C) != None)
        {
            return C.PlayerReplicationInfo;
        }
    }

    return None;
}

function SetPaused(bool bPause)
{
    if (bPause)
    {
        Level.Pauser = GetMessagingSpectatorPRI();
    }
    else
    {
        Level.Pauser = None;
    }
}

function BroadcastMessage(TurboServerSaturationMessage.ENotificationType Switch)
{
    Level.Game.BroadcastLocalized(None, class'TurboServerSaturationMessage', int(Switch));
}

state PauseGame
{
    function BeginState()
    {
        log("ATTEMPTING TO PAUSE");
        PauseTimeRemaining = PauseDuration;
        PauseContinueMessageTimeRemaining = float(PauseDuration) * 1.5f;
        BroadcastMessage(Start);
        SetPaused(true);
    }

    function EndState()
    {
        if (Level.Pauser == None)
        {
            return;
        }

        BroadcastMessage(Unpaused);
        SetPaused(false);
    }

    function Tick(float DeltaTime)
    {
        local float LastPauseTimeRemaining;
        LastPauseTimeRemaining = PauseTimeRemaining;
        PauseTimeRemaining -= DeltaTime;

        if (Level.Pauser == None || PauseTimeRemaining <= 0.f)
        {
            GotoState('');
            return;
        }

        if (LastPauseTimeRemaining > 4.f && PauseTimeRemaining <= 4.f)
        {
            BroadcastMessage(End);
        }
        else if (LastPauseTimeRemaining > 3.f && PauseTimeRemaining <= 3.f)
        {
            BroadcastMessage(TMinusThree);
        }
        else if (LastPauseTimeRemaining > 2.f && PauseTimeRemaining <= 2.f)
        {
            BroadcastMessage(TMinusTwo);
        }
        else if (LastPauseTimeRemaining > 1.f && PauseTimeRemaining <= 1.f)
        {
            BroadcastMessage(TMinusOne);
        }
        else
        {
            PauseContinueMessageTimeRemaining -= DeltaTime;
            if (PauseContinueMessageTimeRemaining <= 0.f)
            {
                PauseContinueMessageTimeRemaining = float(PauseDuration) * 1.5f;
                BroadcastMessage(Continue);
            }
        }
    }

    function ReceivedText(string Text)
    {
        if (Text ~= "SATURATED")
        {
            if (PauseTimeRemaining < 3.f)
            {
                BroadcastMessage(Restart);
            }

            PauseTimeRemaining = PauseDuration;
        }
    }

    function OnManuallyUnpaused(Object Unpauser)
    {
        ManualUnpauseOverrideTime = Level.TimeSeconds + float(ManualUnpauseOverrideDuration);
        GotoState('');
    }
}

defaultproperties
{
    PauseDuration=15
    ManualUnpauseOverrideDuration=120
    ListenPort=28871
}
