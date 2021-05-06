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
        [%set-pos on-off]
      ~&  >  '%lightswitch got a %set-pos'
      =/  new-pos    +.q.vase
      `this(state [%0 new-pos counter.state])
      ::
         %toggle
      ~&  >  '%lightswitch got a %toggle'
      =/  new-pos    ?:(=(pos.state %on) %off %on)
      =/  incr-task  [%poke %noun !>(%increment-counter)]
      =/  incr-note  [%agent [our.bowl %lightswitch] incr-task]
      :-  ~[[%pass /lightswitch-path incr-note]]
      this(state [%0 new-pos counter.state])
      ::
        %increment-counter
      ~&  >  '%lightswitch is doing counter++'
      [~ this(state [%0 pos +(counter.state)])]
      ::
        %give-pos
      ~&  >  '%lightswitch is sending its pos'
      =/  fact-pos=?  ?:  =(pos.state %on)  %.y  %.n
      :-  ~[[%give %fact paths=~[/switch] %atom !>(fact-pos)]]
      this
      ::
        %kick
      ~&  >  '%lightswitch is doing a %kick' 
      :-  ~[[%give %kick paths=~[/switch] ~]]
      this
      ::
     ==
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%lightswitch-path ~]
    ?~  +.sign
      ~&  >>  "%lightswitch got successful {<-.sign>}"  `this
    (on-agent:def wire sign)
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+     path  (on-watch:def path)
      [%switch ~]
    ~&  >>  "%lightswitch got switch subscription from {<src.bowl>}"
    [~ this]
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
