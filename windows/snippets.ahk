;windows

;;SNIPPETS
  #HotIf
    #Hotstring EndChars `t ;expand snippet with <tab> at end
    #Hotstring NoMouse
    #Hotstring o ? k100
      ; *  - ending char is not required
      ; ?  - trigger inside word (?0 - turn off)
      ; b0 - turn off auto backspacing (b - turn on)
      ; c  - case sensitive (c0 - turn off)
      ; c1 - case conform (abc, Abc, ABC expands hotstring approrpiate)
      ; kN - key delay (in ms, -1 is no delay)
      ; o  - omit ending char
      ; pN - priority ???
      ; r  - send raw (r0 - turn off)
      ; si/sp/se - method to send: sendinput/sendplay/sendevent (si - default)
      ; t  - send raw without translating character to keystroke (t0/r0 - turn off)
      ; x  - execute (run code instead sending text)
      ; z  - reset hotstring processing (for preventing recursion on b0) (z0 - turn off)

    >+Space:: Send("{U+00A0}"), hk("nbsp") ; rshift-space   non-breaking space

    ;:options:string::command ;comment

    ;date
    :cx:ddd::date()             ; ddd<tab> dd.mm.yyyy
    :cx:DDD::date("yyyy.MM.dd") ; DDD<tab> yyyy.mm.dd

    ;chars
    ::``*::{U+00B7}           ; `*<tab>    · middle dot
    ::``@::{U+2022}           ; `@<tab>    • bullet

    ::^--::{U+2191}           ; ^--<tab>   ↑ arrow up
    ::v--::{U+2193}           ; v--<tab>   ↓ arrow down
    ::<--::{U+2190}           ; <--<tab>   ← arrow left
    ::-->::{U+2192}           ; --><tab>   → arrow right

    ::---::{U+2014}           ; ---<tab>   — emdash
    ::--::{U+2013}            ; --<tab>    – endash
    ::-_::{U+2212}            ; -_<tab>    − math minus

    ::(c)::{U+00A9}           ;(c)<tab>    © copyright
    ::(r)::{U+00AE}           ;(r)<tab>    ® registered
    ::^tm::{U+2122}           ;^tm<tab>    ™ trademark

    ;quotes
    :*?:<<::{U+00AB}          ; <<         « double angle quotation left
    :*?:>>::{U+00BB}          ; >>         » double angle quotation right
    ::,,::{U+201C}            ; ,,<tab>    “ double comma quotation left
    ::..::{U+201D}            ; ..<tab>    ” double comma quotation right
    ::;;::{U+201E}            ; ;;<tab>    „ low double comma quotation mark
    ::''::{U+201F}            ; ''<tab>    ‟ double reversed comma quotation mark

    ;math
    *>!x::Send("{U+00D7}")    ; ralt-x     × multiplication
    *>!-::Send("{U+2212}")    ; ralt--     − minus
    *>!=::Send("{U+2260}")    ; ralt-=     ≠ not equal to
    *>!+::Send("{U+00B1}")    ; ralt-+     ± plus-minus
    *>!0::Send("{U+00B0}")    ; ralt-0     ° degree

    ;currency, ralt-char
    *>!b::Send("{U+20BF}")    ; ralt-b     ₿ bitcoin
    *>!r::Send("{U+20BD}")    ; ralt-r     ₽ ruble
    *>!e::Send("{U+20AC}")    ; ralt-e     € euro
    *>!d::Send("{U+0024}")    ; ralt-d     $ dollar
    *>!l::Send("{U+00A3}")    ; ralt-l     £ pound
    *>!t::Send("{U+20B8}")    ; ralt-t     ₸ tenge
    *>!y::Send("{U+00A5}")    ; ralt-y     ¥ yen
    *>!g::Send("{U+20B4}")    ; ralt-g     ₴ hryvnia
    *>!c::Send("{U+00A2}")    ; ralt-c     ¢ cent

    ;diacritic, ralt-char
    *>!6::Send("{U+0302}")    ; ralt-^     ˆ combining circumflex accent
    *>!vkC0::Send("{U+0300}") ; ralt-`     ` combining grave accent
    *>!9::Send("{U+0306}")    ; ralt-(     ˘ combining breve
    *>!vkBA::Send("{U+0308}") ; ralt-:     ¨ combining diaresis
    *>!o::Send("{U+030A}")    ; ralt-o     ˚ combining ring above
    *>!z::Send("{U+0327}")    ; ralt-z     ¸ combining cedilla
    *>!v::Send("{U+030C}")    ; ralt-v     ˇ combining caron
    *>!n::Send("{U+0303}")    ; ralt-n     ˜ combining tilde
    *>!/::Send("{U+0301}")    ; ralt-/     ´ combining acute accent
