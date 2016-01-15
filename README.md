## ircnvim

### Neovim as an IRC client

##### Note: To use this plugin, you need to install [ircnvim-rs](https:/github.com/marchelzo/ircnvim-rs)

#### Installation

After installing ircnvim-rs, just install this plugin as you would any other plugin.

#### Usage

The `:IRC [profile]` command will start an IRC client instance in the current window.
The optional `profile` argument corresponds to a profile defined in the configuration
file (`$HOME/.ircnvim/config`).

Currently, the plugin remaps keys (I know this is probably undesirable; it will likely
change soon).

`<S-Left>` and `<S-Right>` move between channels.

`<Up>` and `<Down>` move back and forth through your history.

Supported commands are:

    - /j or /join   (/j #chan1 #chan2 #chan3)
    - /p or /part   (/part or /part goodbye)
    - /nick         (/nick new_nick)
    - /msg          (/msg target hi, foo bar baz)
    - /quit         (/quit or /quit goodbye)
    - /raw          (/raw PRIVMSG ##c :hello there)


#### Warning

This is still very much a work in progress, and is likely going to be extremely buggy.
If you do take the time to try it out, any feedback (issues, PRs, etc.) would be very
much appreciated.
