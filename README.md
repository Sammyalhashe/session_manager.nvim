# session_manager.nvim

I tend to switch around between multiple workspaces, whether that be different
projects or git worktrees of the same repo. I did it enough that I wanted a
convenient way of doing so, so I made this plugin.

## Usage
All that's required is to load the plugin and setup any mappings. By default,
the mapped commands will give a vim prompt for you to follow at the bottom of
the screen. However, if you have telescope installed, you can add the
`override_selector` option as shown in the snippet. This will enable telescope
to be used as the session picker.
```lua
require("session_manager").setup {
    mappings = {
        chooseSession = "\\cs",
        saveSession = "\\ss",
        deleteSession = "\\ds",
        newSession = "\\ns"
    },
    -- override_selector = require("session_manager.telescope_ext")
}
```
