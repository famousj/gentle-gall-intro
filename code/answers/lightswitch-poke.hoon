::  lightswitch.hoon
::  Gall agent representing a light switch
::
/+  dbug, default-agent
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  on-off   $?(%on %off)
+$  state-0  [%0 pos=on-off counter=@ud]
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
  ~&  >  '%lightswitch initialized successfully'
  [~ this(state [%0 %off 0])]
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%lightswitch recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %toggle
      ~&  >  '%lightswitch got a %toggle'
      =/  new-pos  ?:(=(pos.state %on) %off %on)
      [~ this(state [%0 new-pos +(counter.state)])]
    ==
  ==
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
