local modkey = 'Mod1'

return {
    -- Awesome
    Reload = {{modkey, "Control"}, "r"},
    Quit = {{modkey, "Shift"}, "q"},
    OpenTerminal = {{modkey, "Shift"}, "Return"},
    ShowMenubar = {{modkey}, "p"},

    -- Layouts
    JumpToUrgent = {{modkey}, "u"},
    IncSizeLeft = {{modkey}, "l"},
    IncSizeRight = {{modkey}, "h"},
    IncrementMasterClients = {{modkey, "Shift"}, "h"},
    DecreaseMasterClients = {{modkey, "Shift"}, "l"},
    NextLayout = {{modkey}, "space"},
    PreviousLayout = {{modkey, "Shift"}, "space"},

    -- Tag management modifiers
    OnlyViewModifiers = {modkey},
    ToggleTag = {modkey, "Control"},
    MoveClientToTag = {modkey, "Shift"},

    -- Clients
    Fullscreen = {{modkey}, "f"},
    KillClient = {{modkey, "Shift"}, "c"},
    ToggleFloating = {{modkey, "Control"}, "space"},
    MoveToMaster = {{modkey}, "Return"},
    MoveToScreen = {{modkey}, "o"},
    KeepOnTopToggle = {{modkey}, "n"},
    MaximizeToggle = {{modkey}, "m"},
    
    -- Focus
    FocusNext = {{modkey}, "k"},
    FocusPrevious = {{modkey}, "j"},
    FocusNextScreen = {{modkey}, "."},
    FocusPreviousScreen = {{modkey}, ","}

}