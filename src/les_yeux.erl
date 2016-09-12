-module(les_yeux).

-record(state, {server,
                title,
                message,
                duration}).

%% API exports
-export([main/1]).
-compile(export_all).

-define(NOTIFIERS_FILE, "~/.les_yeux").

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main(_Args) ->
    notify_breed(),
    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================
notify_loop(S = #state{server=Server,
                    duration=Duration,
                    title=Title,
                    message=Message}) ->
    receive
        {Server, Ref, stop} ->
            Server ! {Ref, ok};
        {Server, Ref, summary} ->
            Server ! {Ref, {Title, Message, Duration}}
    after Duration * 1000 ->
            Server ! {done, S#state.title, S#state.message}
    end.

notify(Title, Message) ->
    Command = lists:flatten(io_lib:format("notify-send '~s' '~s'", [Title, Message])),
    os:cmd(Command).

expand_user(Path) ->
    UserHome = os:getenv("HOME"),
    re:replace(Path, "^~", UserHome, [{return, list}]).

spawn_notifiers([Notifier|Notifiers]) ->
    {Title, Message, Duration} = Notifier,
    spawn(?MODULE, notify_loop, [#state{server=self(), title=Title, message=Message,
                                     duration=Duration}]),
    spawn_notifiers(Notifiers);
spawn_notifiers([]) ->
    ok.

notify_breed() ->
    ConfigFile = expand_user(?NOTIFIERS_FILE),
    case file:consult(ConfigFile) of
        {ok, Notifications} ->
            spawn_notifiers(Notifications);
        {error, ExceptionType} ->
            throw(ExceptionType)
    end,
    receive
        {done, Title, Message} ->
            notify(Title, Message)
    end,
    notify_breed().
