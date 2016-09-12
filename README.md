les_yeux
=====

An escript for displaying periodic notifications.

Build
-----

    $ rebar3 escriptize

Run
---

Add the configuration file for specifying desired notifications in `~/.les_yeux`:

    {"Hey", "Sup", 600}.
    {"Hi There!", "What's happening?", 1800}.

The format is:

    `<notification>.[\n<notification> .] <...>`

Where a notification is:

    `{"<notification-title>", "<notification-body>", <notification-period>}`

At this point you are ready to run the executable file:

    $ _build/default/bin/les_yeux
