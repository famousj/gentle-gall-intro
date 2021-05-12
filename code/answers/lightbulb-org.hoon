::  lightbulb.hoon
::  Gall agent representing a lightbulb
::
/-  lighting
/+  dbug, default-agent
=,  lighting
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 lit=on-off]
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
  ?>  (team:title our.bowl src.bowl)
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
      ~[[%pass /bulb note]]
      ::
        [%subscribe @p]
      ~&  >  "%lightbulb subscribing to {<`@p`+.q.vase>}"
      =/  host  +.q.vase
      :_  this
      (sub-cards.hc host)
      ::
        %unsubscribe
      ~&  >  "%lightbulb unsubscribing"
      :_  this
      unsub-cards.hc
    ==
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%bulb ~]
    ?~  +.sign
      ~&  >>  "%lightbulb got successful {<-.sign>}"  `this
    (on-agent:def wire sign)
      _switch-wire.hc
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      =/  lit-atom  !<(@ q.cage.sign)
      =/  lit  ?+  lit-atom  !!
                 %on   %on
                 %off  %off
               ==
      ~&  >>  "%lightbulb received {<lit>} from {<src.bowl>} on {<`path`wire>}"
      [~ this(state [%0 lit])]
        %watch-ack
      ?~  +.sign
        ~&  >>  "%lightbulb got successful %watch-ack for {<`path`wire>}"  
        `this
      (on-agent:def wire sign)
        %kick
      ~&  >>  "%lightbulb got %kick-ed off {<`path`wire>}"  
      `this
    ==
  ==
++  on-leave  on-leave:def
++  on-watch  on-watch:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::
::  Helper core
|_  =bowl:gall
++  switch-wire  /switch/(scot %p our.bowl)
:: A card unsubscribing to %lightswitch on
:: the given ship
++  unsub-card-for-ship
  |=  =ship
  ^-  card
  =/  task  [%leave ~]
  =/  note  [%agent [ship %lightswitch] task]
  [%pass switch-wire note]
:: A card subscribing to %lightswitch on
:: the given ship
++  sub-card-for-ship
  |=  =ship
  ^-  card
  =/  task  [%watch /switch]
  =/  note  [%agent [ship %lightswitch] task]
  [%pass switch-wire note]
:: The cards to unsubscribe to a list of ships
++  unsub-cards-for-ships
  |=  ships=(list ship)
  ^-  (list card)
  ~&  >>  "Unsubscribing to {<ships>}"
  (turn ships unsub-card-for-ship)
:: Cards to unsubscribe to %lightswith
++  unsub-cards
  ^-  (list card)
  =/  ships  get-ships-for-lightswitch-subs
  (unsub-cards-for-ships ships)
:: All the cards to subscribe to %lightswitch on a ship,
:: plus cards to unsubscribe any current subscriptions
++  sub-cards
  |=  host=@p
  ^-  (list card)
  =/  ships  get-ships-for-lightswitch-subs
  ?.  =(~ (find ~[host] ships))
    ~&  >>  "Already subscribed on host {<host>}"
    ~
  %+  snoc
    (unsub-cards-for-ships ships)
  ~&  >>  "Subscribing to {<host>}"
  (sub-card-for-ship host)
:: The tuple that is the type of the key in the map
:: `wex.bowl`
+$  sub-tuple    [=wire =ship =term]
:: Returns the list of ships hosting %lightswitch
:: subscriptions
++  get-ships-for-lightswitch-subs
  ^-  (list ship)
  =/  keys=(set sub-tuple)       ~(key by wex.bowl)
  =/  key-list=(list sub-tuple)  ~(tap in keys)
  %+  murn
    key-list 
  |=(tup=sub-tuple ?.(=(%lightswitch term.tup) ~ `ship.tup))
--
