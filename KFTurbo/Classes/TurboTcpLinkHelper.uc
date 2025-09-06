class TurboTcpLinkHelper extends Object
    abstract;

static final function string Sanitize(string InString)
{
    return Repl(Repl(InString, "\\", "\\\\"), "\"", "\\\"");
}