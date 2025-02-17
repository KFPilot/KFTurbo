//Killing Floor Turbo TurboCardStatsTcpLink
//Sends data regarding card voting to a specified place. Piggy backs off TurboStatsLink to send data.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardStatsTcpLink extends Info
    config(KFTurboCardGame);

var TurboStatsTcpLink StatsTcpLink;

//Cached list of shown cards. Slowly built up using SendVote()'s VoteSelectionList.
var array<TurboCard> ShownCardList;

//static final function KFTurboCardGameMut FindMutator(GameInfo GameInfo)
static final function TurboCardStatsTcpLink FindStats(GameInfo GameInfo)
{
    local KFTurboCardGameMut CardGameMut;
    CardGameMut = class'KFTurboCardGameMut'.static.FindMutator(GameInfo);

    if (CardGameMut == None)
    {
        return None;
    }

    return CardGameMut.TurboCardStats;
}

final function TurboStatsTcpLink GetStatsTcpLink()
{
    if (StatsTcpLink == None)
    {
        StatsTcpLink = class'KFTurboMut'.static.FindMutator(Level.Game).StatsTcpLink;
    }

    return StatsTcpLink;
}

function PostBeginPlay()
{
    log("KFTurbo Card Game is starting up stats TCP link!", 'KFTurboCardGame');
}

//Analytics event for a vote that occurred.
function OnVoteComplete(array<TurboCard> ActiveCardList, array<TurboCard> VoteSelectionList, TurboCard SelectedCard)
{
    local int ShownStartingIndex, Index;

    //Append vote selection to shown cards.
    ShownStartingIndex = ShownCardList.Length;
    ShownCardList.Length = ShownCardList.Length + VoteSelectionList.Length;
    for (Index = 0; Index < VoteSelectionList.Length; Index++)
    {
        ShownCardList[ShownStartingIndex + Index] = VoteSelectionList[Index];
    }

    GetStatsTcpLink().SendData(BuildVotePayload(Level.Game.GetCurrentWaveNum(), ConvertCardToCardID(ActiveCardList), ConvertCardToCardID(VoteSelectionList), SelectedCard.CardID));
}

/*
Data payload for a vote looks like the following;

{
    "type": "cardgame_vote",
    "version": "4.4.1",
    "session": "<session ID>",
    "wavenum" : 8,
    "activecards" : ["CARD1", "CARD2", "CARD3", "CARD4", "CARD5", "CARD6", "CARD7"],
    "voteselection" : ["CARD8", "CARD9", "CARD10"],
    "votedcard" : "CARD9"
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game.
wavenum - The wave this vote data came from during the game.
activecards - The cards that have been selected so far.
voteselection - The cards to vote on for this round of voting.
votedcard - The card that was ultimately selected.
*/

final function string BuildVotePayload(int WaveNumber, array<string> ActiveCardList, array<string> VoteSelectionList, string VotedCardList)
{
    local string Payload;
    local KFTurboMut Mutator;
    Mutator = class'KFTurboMut'.static.FindMutator(Level.Game);

    Payload = "{%qtype%q:%qcardgame_vote%q,";
    Payload $= "%qversion%q:%q"$Mutator.GetTurboVersionID()$"%q,";
    Payload $= "%qsession%q:%q"$Mutator.GetSessionID()$"%q,";
    Payload $= "%qwavenum%q:"$WaveNumber$",";
    Payload $= "%qactivecards%q:["$ConvertToString(ActiveCardList)$"],";
    Payload $= "%qvoteselection%q:["$ConvertToString(VoteSelectionList)$"],";
    Payload $= "%qvotedcard%q:%q"$VotedCardList$"%q}";
    
    Payload = Repl(Payload, "%q", Chr(34));
    return Payload;
}

function OnGameEnd(int Result, array<TurboCard> ActiveCardList)
{
    GetStatsTcpLink().SendData(BuildEndGamePayload(Result, ConvertCardToCardID(ActiveCardList), ConvertCardToCardID(ShownCardList)));
}

/*
Data payload for a game end looks like the following;

{
    "type": "cardgame_endgame",
    "version": "4.4.1",
    "session": "<session ID>",
    "result": "won",
    "activecards" : ["CARD2", "CARD4", "CARD8"],

    //Not currently sent. We need to compress card IDs or something because this causes the payload size to explode (14 (waves) x 3~4 (cards shown each wave) x 15 (card id characters average))
    "showncards" : ["CARD1", "CARD3", "CARD5", ...] 
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game.
result - The result of the game. Can be "won", "lost", "aborted". Aborted refers to a map vote that occurred without a game end state being reached.
activecards - The cards that were selected during the game.


showncards - The cards that were not selected during the game.
*/

//Analytics event for a game ending.
final function string BuildEndGamePayload(int Result, array<string> ActiveCardList, array<string> ShownCardList)
{
    local string Payload;
    local KFTurboMut Mutator;
    Mutator = class'KFTurboMut'.static.FindMutator(Level.Game);

    Payload = "{%qtype%q:%qcardgame_endgame%q,";
    Payload $= "%qversion%q:%q"$Mutator.GetTurboVersionID()$"%q,";
    Payload $= "%qsession%q:%q"$Mutator.GetSessionID()$"%q,";
    Payload $= "%qresult%q:"$Result$",";
    Payload $= "%qactivecards%q:["$ConvertToString(ActiveCardList)$"]}";
    //Payload $= "%qshowncards%q:["$ConvertToString(ShownCardList)$"]}";
    
    Payload = Repl(Payload, "%q", Chr(34));
    return Payload;
}

final function string ConvertToString(array<string> StringList)
{
    local string Result;
    local int Index;
    Result = "";

    for (Index = 0; Index < StringList.Length; Index++)
    {
        Result $= "%q"$StringList[Index]$"%q";

        if (Index < StringList.Length - 1)
        {
            Result $= ",";
        }
    }

    return Result;
}

static final function array<string> ConvertCardToCardID(array<TurboCard> CardList)
{
    local array<string> Result;
    local int Index;

    Result.Length = CardList.Length;

    for (Index = 0; Index < CardList.Length; Index++)
    {
        if (CardList[Index] == None)
        {
            continue;
        }

        Result[Index] = CardList[Index].CardID;
    }

    return Result;
}


defaultproperties
{

}