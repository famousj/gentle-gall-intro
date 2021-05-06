::  lightbulb.hoon
::  Gall agent representing a lightbulb
::
/+  dbug, default-agent
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  on-off   $?(%on %off)
+$  state-0  [%0 lit=on-off]
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
      ::
        [%set-lit on-off]
      ~&  >  '%lightbulb changing lit state'
      [~ this(state [%0 +.q.vase])]
      ::
        [%pass-note on-off]
      ~&  >  "%lightbulb passing {<+.q.vase>}"
      =/  new-lit  +.q.vase
      =/  task     [%poke %noun !>([%set-lit new-lit])]
      =/  note     [%agent [our.bowl %lightbulb] task]
      :_  this
      ~[[%pass /lightbulb-path note]]
      ::
        %subscribe
      ~&  >  "%lightbulb subscribing"
      =/  task     [%watch /switch]
      =/  note     [%agent [our.bowl %lightswitch] task]
      :_  this
      ~[[%pass /switch/(scot %p our.bowl) note]]
      ::
        %unsubscribe
      ~&  >  "%lightbulb unsubscribing"
      =/  task     [%leave ~]
      =/  note     [%agent [our.bowl %lightswitch] task]
      :_  this
      ~[[%pass /switch/(scot %p our.bowl) note]]
    ==
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%lightbulb-path ~]
    ?~  +.sign
      ~&  >>  "%lightbulb got successful {<-.sign>}"  `this
    (on-agent:def wire sign)
      [%switch @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      =/  fact-lit  !<(@ q.cage.sign)
      =/  lit       ?:  =(fact-lit %.y)  %on  %off
      ~&  >>  "%lighbtulb received {<lit>} from {<src.bowl>} on {<`path`wire>}"
      [~ this(state [%0 lit])]
        %watch-ack
      ?~  +.sign
        ~&  >>  "%lightbulb got successful %watch-ack for {<`path`wire>}"  `this
      (on-agent:def wire sign)
        %kick
      ~&  >>  "%lightbulb got %kick-ed off {<`path`wire>}"  `this
    ==
  ==
++  on-leave  on-leave:def
++  on-watch  on-watch:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
