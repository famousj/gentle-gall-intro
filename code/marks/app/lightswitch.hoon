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
=<
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
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
  ?>  (team:title our.bowl src.bowl)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        [%set-pos on-off:lighting]
      ~&  >  '%lightswitch got a %set-pos'
      =/  new-pos    +.q.vase
      [~ this(state [%0 new-pos counter.state])]
      ::
         %toggle
      ~&  >  '%lightswitch got a %toggle'
      =/  new-pos     ?:(=(pos.state %on) %off %on)
      :-  ~[incr-card.hc (pos-card.hc new-pos)]
      this(state [%0 new-pos counter.state])
      ::
        %increment-counter
      ~&  >  '%lightswitch is doing counter++'
      [~ this(state [%0 pos +(counter.state)])]
      ::
        %give-pos
      ~&  >  '%lightswitch is sending its pos'
      [~[(pos-card.hc pos.state)] this]
      ::
        %kick
      ~&  >  '%lightswitch is doing a %kick' 
      [~[kick-card.hc] this]
      ::
     ==
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%incr ~]
    ?~  +.sign
      ~&  >>  "%lightswitch got successful {<-.sign>} on {<`path`wire>}"
      [~ this]
    (on-agent:def wire sign)
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+     path  (on-watch:def path)
      [%switch ~]
    ~&  >>  "%lightswitch got switch subscription from {<src.bowl>}"
    [~[(pos-card.hc pos.state)] this]
  ==
++  on-leave
  |=  =path
  ^-  (quip card _this)
  ~&  >>  "%lighswitch got leave request for {<path>} from {<src.bowl>}"
  [~ this]
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::  Begin helper core
|_  =bowl:gall
++  incr-card
  ^-  card
  =/  incr-task   [%poke %noun !>(%increment-counter)]
  =/  incr-note   [%agent [our.bowl %lightswitch] incr-task]
  [%pass /incr incr-note]
++  pos-card
  |=  pos=on-off:lighting
  ^-  card
  [%give %fact paths=~[/switch] %lighting-on-off !>(pos)]
++  kick-card
  [%give %kick paths=~[/switch] ~]
--
