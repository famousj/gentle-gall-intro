::  lightswitch.hoon
::  Gall agent representing a light switch
::
/-  lighting
/+  dbug, default-agent
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 pos=on-off:lighting counter=@ud]
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
      =/  new-pos    ?:(=(pos.state %on) %off %on)
      =/  incr-task  [%poke %noun !>(%increment-counter)]
      =/  incr-note  [%agent [our.bowl %lightswitch] incr-task]
      :-  ~[[%pass /lightswitch-path incr-note]]
      this(state [%0 new-pos counter.state])
        %increment-counter
      ~&  >  '%lightswitch is doing counter++'
      [~ this(state [%0 pos +(counter.state)])]
        %bad-poke
      !!
        %send-bad-poke
      =/  bad-task  [%poke %noun !>(%bad-poke)]
      =/  bad-note  [%agent [our.bowl %lightswitch] bad-task]
      :-  ~[[%pass /lightswitch-path bad-note]]
      this
     ==
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%lightswitch-path ~]
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
