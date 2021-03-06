::  lightbulb.hoon
::  Gall agent representing a lightbulb
::
/-  lighting
/+  dbug, default-agent
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 lit=on-off:lighting]
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%lightbulb initialized successfully'
  [~ this(state [%0 %off])]
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%lightbulb recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >>  state
      [~ this]
        [%set-lit on-off:lighting]
      ~&  >  '%lightbulb changing lit state'
      [~ this(state [%0 +.q.vase])]
        [%pass-note on-off:lighting]
      ~&  >  "%lightbulb passing {<+.q.vase>}"
      =/  new-lit  +.q.vase
      =/  task     [%poke %noun !>([%set-lit new-lit])]
      =/  note     [%agent [our.bowl %lightbulb] task]
      :_  this
      ~[[%pass /lightbulb-path note]]
    ==
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%lightbulb-path ~]
    ?~  +.sign
      ~&  >>  "successful {<-.sign>}"  `this
    (on-agent:def wire sign)
  ==
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
