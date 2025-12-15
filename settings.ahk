;taptapkey settings

/*  -----------------------------------------------------
    Modify the lines below as you wish. Unnecessary lines
    can be disabled by adding the ';' character at the
    beginning, or enabled by removing the character:  */

    #Include adobe/illustrator/funcs.ahk
    #Include adobe/illustrator/hotkeys.ahk

    #Include adobe/indesign/funcs.ahk
    #Include adobe/indesign/hotkeys.ahk

    #Include adobe/photoshop/funcs.ahk
    #Include adobe/photoshop/hotkeys.ahk

    #Include figma/funcs.ahk
    #Include figma/hotkeys.ahk

    #Include windows/funcs.ahk
    #Include windows/hotkeys.ahk
    ;#Include windows/snippets.ahk



/*  ----------------------------------------------
    Examples for advanced users. You can use
    this as a template for your customizations: */

    ;#Include general/general.ahk
    ;#Include general/graphics.ahk
    ;#Include general/user.ahk

    #Include *i ../.ahk ;delete this line



/*  ----------------
    Preferences:  */

    ttk.capsLockEnable := false
    /*  Disables native capslock function,
        to avoid interfering with capslock combos */

    ;ttk.tap := { layout: "English", restore: false }
    /*  Default setting for the 'tap("some text")' function,
        which changes the layout to a specific one, sends text to the
        application, then restores the current layout (if necessary).
        This is essential when you have several keyboard layouts
        (for example, non-Latin and Latin) and hotkeys in some English
        applications do not work when the wrong layout is active */
