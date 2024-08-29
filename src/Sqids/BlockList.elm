module Sqids.BlockList exposing
    ( default
    , de, en, es, fr, hi, it, pt
    )

{-| This module contains carefully chosen words and their variations that might not be appropriate to accidentally show up in auto-generated Sqids IDs.

It uses the [official Sqids block list](https://github.com/sqids/sqids-blocklist/tree/084d15864ce0d102fd1aa0e752edb2d78e073e9f) which is also linked as [a git submodule](https://github.com/sqids/sqids-blocklist/).

You can use the [default](#default) list, or reuse only some of the [languages](#languages) and add other words that you consider undesirable.

@docs default


## Variations

Words were transformed to include these changes:
`i → 1`, `l → 1`, `o → 0`.
If the BlockList contained the word `"low"`, it would also contain the variations: `"l0w"`, `"1ow"` and `"10w"`.

_Note_: This Elm package does not calculate these variations, it only contains the block lists as strings.


# Languages

@docs de, en, es, fr, hi, it, pt

-}


{-| Contains the blocked words of all languages listed below:
[English](#en), [French](#fr), [German](#de), [Hindi](#hi), [Italian](#it), [Portuguese](#pt), [Spanish](#es)
-}
default : List String
default =
    List.concat [ de, en, es, fr, hi, it, pt ]


{-| German blocked words and their variations
-}
de : List String
de =
    [ "arsch", "de1ch", "deich", "depp", "f0tze", "f1cker", "ficker", "fotze", "hund1n", "hundin", "m1st", "mist", "musch1", "muschi", "neger", "saugnapf", "sch1ampe", "sche1se", "sche1sse", "scheise", "scheisse", "schlampe", "schwachs1nn1g", "schwachs1nnig", "schwachsinn1g", "schwachsinnig", "schwanz", "verdammt", "w1chsen", "wichsen" ]


{-| English blocked words and their variations
-}
en : List String
en =
    [ "0rgasm", "1d10t", "1d1ot", "1di0t", "1diot", "1mbec11e", "1mbec1le", "1mbeci1e", "1mbecile", "ah01e", "ah0le", "aho1e", "ahole", "ana1", "anal", "anus", "arse", "ass", "b00b", "b0ob", "b1tch", "bitch", "bo0b", "boob", "c0ck", "c11t", "c1it", "ch1nk", "chink", "cl1t", "clit", "cock", "cracker", "crap", "cum", "cunt", "d11d0", "d11do", "d1ck", "d1ld0", "d1ldo", "damn", "di1d0", "di1do", "dick", "dild0", "dildo", "dyke", "enema", "fag", "fuck", "id10t", "id1ot", "idi0t", "idiot", "imbec11e", "imbec1le", "imbeci1e", "imbecile", "j1zz", "jerk", "jizz", "k1ke", "kike", "masturbat10n", "masturbat1on", "masturbate", "masturbati0n", "masturbation", "n1gger", "negr0", "negro", "nigger", "orgasm", "p00p", "p0op", "p0rn", "pen1s", "penis", "po0p", "poop", "porn", "pr1ck", "prick", "pussy", "rape", "retard", "s1ut", "sexy", "sh1t", "shit", "slut", "stup1d", "stupid", "sucker", "test1c1e", "test1cle", "testic1e", "testicle", "turd", "twat", "vag1na", "vagina", "wank" ]


{-| Spanish blocked words and their variations
-}
es : List String
es =
    [ "cabr0n", "cabron", "cagante", "caracu10", "caracu1o", "caracul0", "caraculo", "ch1ng0", "ch1ngadaz0s", "ch1ngadazos", "ch1ngader1ta", "ch1ngaderita", "ch1ngar", "ch1ngo", "ch1ngues", "ching0", "chingadaz0s", "chingadazos", "chingader1ta", "chingaderita", "chingar", "chingo", "chingues", "cu1er0", "cu1ero", "culer0", "culero", "estup1d0", "estup1do", "estupid0", "estupido", "m1erda", "mam0n", "mamahuev0", "mamahuevo", "mamon", "mierda", "p011a", "p01la", "p0l1a", "p0lla", "pendej0", "pendejo", "po11a", "po1la", "pol1a", "polla", "put1za", "puta", "putiza", "verga" ]


{-| French blocked words and their variations
-}
fr : List String
fr =
    [ "b1te", "b1tte", "bite", "bitte", "bran1age", "bran1er", "bran1ette", "bran1eur", "bran1euse", "branlage", "branler", "branlette", "branleur", "branleuse", "c0nnard", "c0nnasse", "c0nne", "c0u111es", "c0u11les", "c0u1l1es", "c0u1lles", "c0ui11es", "c0ui1les", "c0uil1es", "c0uilles", "c11t0", "c11to", "c1it0", "c1ito", "caca", "ch1asse", "ch1er", "chatte", "chiasse", "chier", "cl1t0", "cl1to", "clit0", "clito", "connard", "connasse", "conne", "cou111es", "cou11les", "cou1l1es", "cou1lles", "coui11es", "coui1les", "couil1es", "couilles", "encu1e", "encule", "enf01re", "enf0ire", "enfo1re", "enfoire", "etr0n", "etron", "f0utre", "foutre", "g0u1ne", "g0uine", "gou1ne", "gouine", "gr0gnasse", "grognasse", "merde", "negre", "p0uff1asse", "p0uffiasse", "p1p1", "p1pi", "p1sser", "pip1", "pipi", "pisser", "pouff1asse", "pouffiasse", "puta1n", "putain", "pute", "sa10pe", "sa1aud", "sa1ope", "sal0pe", "salaud", "salope", "tapette", "tr1ng1er", "tr1ngler", "tring1er", "tringler", "z1z1", "z1zi", "ziz1", "zizi" ]


{-| Hindi blocked words and their variations
-}
hi : List String
hi =
    [ "aand", "b00be", "b0obe", "ba1atkar", "balatkar", "bo0be", "boobe", "ch00t1a", "ch00t1ya", "ch00tia", "ch00tiya", "ch0d", "ch0ot1a", "ch0ot1ya", "ch0otia", "ch0otiya", "cho0t1a", "cho0t1ya", "cho0tia", "cho0tiya", "chod", "choot1a", "choot1ya", "chootia", "chootiya", "g00", "g0o", "gandu", "go0", "goo", "haram1", "harami", "haramzade", "kam1ne", "kamine", "patakha", "rand1", "randi" ]


{-| Italian blocked words and their variations
-}
it : List String
it =
    [ "1eccacu10", "1eccacu1o", "1eccacul0", "1eccaculo", "a11upat0", "a11upato", "a1lupat0", "a1lupato", "al1upat0", "al1upato", "allupat0", "allupato", "ana1e", "anale", "arrapat0", "arrapato", "b01ata", "b0iata", "batt0na", "battona", "bo1ata", "boiata", "c0g110ne", "c0g11one", "c0g1i0ne", "c0g1ione", "c0gl10ne", "c0gl1one", "c0gli0ne", "c0glione", "cacca", "cagare", "cagna", "cazz0", "cazz1mma", "cazzata", "cazzimma", "cazzo", "ch1avata", "chiavata", "cog110ne", "cog11one", "cog1i0ne", "cog1ione", "cogl10ne", "cogl1one", "cogli0ne", "coglione", "cu10", "cu1att0ne", "cu1attone", "cu1o", "cul0", "culatt0ne", "culattone", "culo", "f0ttere", "f0tters1", "f0ttersi", "f1ca", "f1ga", "fica", "figa", "fottere", "fotters1", "fottersi", "fr0c10", "fr0c1o", "fr0ci0", "fr0cio", "fr0sc10", "fr0sc1o", "fr0sci0", "fr0scio", "froc10", "froc1o", "froci0", "frocio", "frosc10", "frosc1o", "frosci0", "froscio", "leccacu10", "leccacu1o", "leccacul0", "leccaculo", "m1gn0tta", "m1gnotta", "m1nch1a", "m1nchia", "merd0s0", "merd0so", "merda", "merdos0", "merdoso", "mign0tta", "mignotta", "minch1a", "minchia", "nerch1a", "nerchia", "p0mp1n0", "p0mp1no", "p0mpin0", "p0mpino", "p0rca", "p1r1a", "p1rla", "p1sc10", "p1sc1o", "p1sci0", "p1scio", "pa11e", "pa1le", "pal1e", "palle", "pec0r1na", "pec0rina", "pecor1na", "pecorina", "pir1a", "pirla", "pisc10", "pisc1o", "pisci0", "piscio", "pomp1n0", "pomp1no", "pompin0", "pompino", "porca", "puttana", "r0mp1ba11e", "r0mp1ba1le", "r0mp1bal1e", "r0mp1balle", "r0mpiba11e", "r0mpiba1le", "r0mpibal1e", "r0mpiballe", "recch10ne", "recch1one", "recchi0ne", "recchione", "romp1ba11e", "romp1ba1le", "romp1bal1e", "romp1balle", "rompiba11e", "rompiba1le", "rompibal1e", "rompiballe", "ruff1an0", "ruff1ano", "ruffian0", "ruffiano", "sb0rr0ne", "sb0rra", "sb0rrone", "sbattere", "sbatters1", "sbattersi", "sborr0ne", "sborra", "sborrone", "sc0pare", "sc0pata", "scopare", "scopata", "sp0mp1nare", "sp0mpinare", "spomp1nare", "spompinare", "str0nz0", "str0nza", "str0nzo", "stronz0", "stronza", "stronzo", "succh1am1", "succh1ami", "succhiam1", "succhiami", "t0pa", "tette", "topa", "tr01a", "tr0ia", "tr0mbare", "tro1a", "troia", "trombare", "vaffancu10", "vaffancu1o", "vaffancul0", "vaffanculo", "z0cc01a", "z0cc0la", "z0cco1a", "z0ccola", "zocc01a", "zocc0la", "zocco1a", "zoccola" ]


{-| Portuguese blocked words and their variations
-}
pt : List String
pt =
    [ "b0ceta", "b0sta", "bastard0", "bastardo", "boceta", "bosta", "c0na", "cabra0", "cabrao", "cacete", "cagar", "cara1h0", "cara1ho", "caralh0", "caralho", "cona", "f0da", "f0der", "foda", "foder", "merda", "p0rra", "pane1e1r0", "pane1e1ro", "pane1eir0", "pane1eiro", "panele1r0", "panele1ro", "paneleir0", "paneleiro", "porra", "puta", "queca", "sacanagem", "x0ch0ta", "x0chota", "xana", "xoch0ta", "xochota" ]
