# Subscriptions

As things stand with our `%lightbulb` and `%lightswitch` agents, we have a `lit` state on
the `%lightbulb` and a `pos` on the `%lightswitch`.  

What we would like is to wire these two agents together, so that changing the `pos` on 
the `%lightswitch` will cause the `lit` state on a `%lightbulb` to match.

We could do this by having the `%lightswitch` poke the `%lighbulb` when this happens.  
If we knew we were only going to have one `%lightbulb` connected to one `%lightswitch`, 
that might be the easiest way to do it.  

However, if we wanted several `%lightbulb`s all connected to the same `%lightswitch`, 
this could get complicated.  We would need to keep track of everyone that needs to be 
updated, and notify everyone at once, when the `%lightswitch` changed its `pos`.

The other problem with this is that the `%lightbulb` would receive pokes from all 
`%lightswitch`es everwhere.

Depending on how you want this to work, this might be fine.  But if there was only 
one `%lightswitch` that should be allowed to turn it off or on, you would be better 
off having the `%lightbulb` set this up.

The good news is, this all comes built-in if we use a subscription.  Each `%lighbulb` 
subscribes to changes on the `%lightbulb`.

Then when someone clicks the switch (i.e. pokes the `%toggle` task), the `%lightswitch` 
can inform all the connected `%lightbulbs` to change their `lit` state as appropriate.

## Subscription Architecture

Here's how some agent, let's call it agent A, would make a subscription on agent B.
Don't panic if this doesn't make any sense right now.  We will break it down in 
detail below:

- On A, you create a `%pass` card with a `%watch` note, which asks Gall to make a subscription 
on B.  This card contains:
  - The name of a path on B, let's call it `/path-B`.
  - The name of a wire on A, let's call it `/wire-A`.
- Gall calls the `on-watch` arm on B, telling it that agent A wants to subscribe to 
`/path-B`.
- Gall calls `on-agent` on A, and says there was a `%watch-ack` for `/wire-A`.

You might notice that this is exactly the same thing that happens when you do a poke.
Except that:
- You make a `%watch` note instead of a `%poke` note.
- Gall calls `on-watch` instead of `on-poke`.
- Gall replies with `%watch-ack` instead of `%poke-ack`.

Neither agent has to maintain a list of subscribers or subscriptions.  Gall does that for you.
You can access them from `bowl`, specifically:
- `wex.bowl` is the list of outgoing subscriptions.
- `sup.bowl` is the list of incoming subscriptions.

The subscription can be terminated for a variety of reasons:
- A can send a `%leave` note.  Gall will then call `on-leave` on B.
- B can send a `%kick`.  Gall will then call `on-agent` on A.
- One of the arms for handling the subscription crashes.  
- If you can't connect to the host, Arvo, the Urbit OS, might end your subscription.
- Any number of other reasons.

You should assume that the subscription can end at any time and code appropriately.

## The Gift

To keep subscribers up to date, we need to send a `gift`.  To send a gift we need
to create a `%give` card.  

A `%give` card has an even simpler definition than the `%pass` card. You can find in 
`sys/arvo.hoon`:
```
[%give p=b]
```

The `p` for our gift will be a `gift:agent:gall`.

If you check out the definition of `gift:agent:gall` in `sys/lull.hoon`, it looks a lot like 
the `sign:agent:hoon` which we used in `on-agent`.

The `gift` we want to return is the `%fact` gift:
```
[%fact paths=(list path) =cage]
```

`paths` is a list, in case we need to inform different groups of subscribers about this 
`%fact`.  We will use the path `/switch`, and this will be the only path we update.

We saw `cage` when we made the `%poke` task, a pair of `mark` and `vase`.  

Ideally we would set the `mark` to something specific to our subscription payload,
but since there's nothing about lightbulbs or lightswitches built into Urbit, 
we would have to write one ourselves.  (And we will in the next section.)

So for now, we're going to set our mark to `%atom`, and we'll pass a flag, where
`%.y` will be `%on` and `%.n` will be `%off`.

So the card to send an update to our subscribers will be:
```
[%give %fact paths=~[/switch] %atom !>(%.y)]
```

Gall keeps track of everyone subscribed to our paths.  Just return a card with paths 
and a new value, and Gall makes sure it gets to the right home.

## Supporting subscribers

Now, let's get down to brass tacks.

The first order of business is to update `%lightswitch` to support a subscription.

The code for the updated `lightswitch.hoon` is in 
[code/subscriptions/app/lightswitch.hoon](code/subscriptions/app/lightswitch.hoon).

### on-watch

Our updated `on-watch` is on lines 80-87.

Line 81:
```
  |=  =path
```

`on-watch` only takes one argument, the path.  If you want to know the ship that is 
subscribing, you can get that from `src.bowl`.

Line 83:
```
  ?+     path  (on-watch:def path)
```

Use the 'wutlus' (`?+`) to switch on paths that we support.  The `default-agent` handler
for `on-watch` will return an error for every unsupported path.

Line 84:
```
      [%switch ~]
```

Recall that a path is a actually list of `@tas`.  These are equivalent:
```
/this/is/a/path
[%this %is %a %path ~]
```

However, to do pattern-matching like we're doing with the `?+`, you have to explicitly 
specify a list of `@tas`.  If we had specified `/switch` on line 84, we would have gotten an error.

If we needed to do any code to prepare for our new subscriber, this would be the place to 
do it.  As it is, we just print a message to the dojo on line 85.

Also, if you return any cards here, this will update the new subscriber.  You might want
to do this to get them in sync with the state here.

### Updating Subscribers

We have a new poke task, called `%give-pos` on lines 59-63, which returns the `%fact`
card we detailed above.

### Kicking

If the host wants to get rid of subscriber, you use a `%give` card with a `%kick`.

A `%kick` is defined in `gift:agent:gall` as 
```
[%kick paths=(list path) ship=(unit ship)]
```

`paths` is a list of subscription paths.  `ship` is the ship, as a unit.  

If `paths` is null, it will kick the `ship` off all the paths it's subscribed to.  
If `ship` is null, it will remove remove all subscribers from the `paths`.

(And before anyone asks, if `paths` and `ship` are both null, you get an error.)

On lines 64-67, we have a new `%poke` task called `%kick`.

Line 66:
```
      :-  ~[[%give %kick paths=~[/switch] `our.bowl]]
```

This card will kick any agent on this ship (`our.bowl`) listening to the `/switch` path.

### on-leave

The `on-leave` arm for `%lightswitch` has been filled in on lines 88-92.  

Line 89:
```
  |=  =path
```

Like `on-watch`, this only takes a path.  You can use this function if you need to
do any cleanup after a subscriber leaves.  If you use the `default-agent` handler, it
does nothing.

As with `on-watch`, we are just printing a debug message.

### Odds and Ends

All the `bad-poke` handlers are removed.  It's not generally considered best practice 
leave functions that do nothing but crash in your code.

To aid in testing, there's a `%set-pos` poke task on lines 42-45, so we can specify 
our `pos` directly without having it set as a side-effect of doing a `%toggle`.

## Making a subscription

Now, we need our `%lightbulb` agent to subscribe to this path.

This code for the updated `lightbulb.hoon` is in [code/subscriptions/app/lightbulb.hoon](code/subscriptions/app/lightbulb.hoon).  

### Subscription Cards

To subscribe to an agent, we need to create a `%pass` card.  This is the same kind of 
card we used to send a poke.

To review, a `%pass` is defined as:
```
[%pass p=path q=a]
```

For the path, we are going to use:
```
/switch/(scot %p our.src)
```

`scot` takes two arguments.  The first argument is type information, `%p` being a term
representing `@p`, and the data, `our.src` being our ship's name.

We add this to the `path` so that, if we have multiple `%lightbulb` agents connected 
to the same `%lightswitch`, we'll be able to tell at a glance which wire goes to which 
subscriber.

On the fakezod, this value will be `/switch/~zod`.

We will be `%pass`ing a `note:agent:gall`, specifically an `%agent`.

```
[%agent [=ship name=term] =task]
```

The `ship` is `our.bowl` and the `name` is `%lightswitch`.  The `task` will
be a `%watch`, which is defined as:

```
[%watch =path]
```

The `path` here is the same `/switch` we setup in the `on-watch` for `%lightswitch`

So our subscription card will be:
```
[%pass /switch/(scot %p our.src) %agent [our.bowl %lightswitch] %watch /switch]
```

There is a new `%subscribe` task in `on-poke` to create this card on lines 58-63.

### Unsubscribing

To unsubscribe, you create a `%pass` card that's almost identical to the card you
make to subscribe.  The task you need from `task:agent:gall` is `%leave`, which 
is defined as:
```
[%leave ~]
```

So this card will be:
```
[%pass /switch/(scot %p our.src) %agent [our.bowl %lightswitch] %leave ~]
```

There is a `%unsubscribe` task in `on-poke` on lines 65-70.

### Handling Subscription Updates

When updates come in, they'll come on the `/switch/~zod` wire.  So we need to tell
`on-agent` to handle those.  Those changes are on lines 81-93.

Line 81:
```
      [%switch @ ~]
```

We are doing a pattern match on the path.  Written this way, it will
match a path whose first part is `/switch/` and whose second part is `@`, i.e. any atom.

Lines 84:
```
      =/  fact-lit  !<(@ q.cage.sign)
```

The 'zapgal' rune (`!<`) is the opposite of the `!>` rune.  `!>` creates a vase.  
`!<` takes a type and a vase and returns the data, with the type assigned.  

On lines 87-92, we handle `%watch-ack` and `%kick`.  If you have any setup or
cleanup on the subscriber-side you want to do, this is the place to do it.

## Trying it out

We have two files to copy over.  You can do it manually or run something like this to 
copy them both over.
```
rsync -av gentle-gall-intro/code/subscriptions/ fakezod/home/
```

Then do a `|commit %home`.

First, let's subscribe and see what happens:
```
> :lightbulb %subscribe
```

This gives us:
```
>   "%lightbulb subscribing"
>>  "%lightswitch got switch subscription from ~zod"
>>  "%lightbulb got successful %watch-ack for /switch/~zod"
```

The first message is from the `on-poke`.  The second message is from `on-watch` on
`%lightswitch`.  The last message is `on-agent` handling our `%watch-ack` from 
`%lightswitch`.  

So `%lightbulb` sent a subscription request, `%lightswitch` handled the request, and 
then Gall sent `%lightbulb` a `%watch-ack`.

Now let's setup our states and have `%lightswitch` send an update to its subscribers:
```
> :lightswitch [%set-pos %on]
> :lightbulb [%set-lit %off]
> :lightswitch %give-pos
```

We can check the state of `%lighbulb`:
```
> :lightbulb +dbug
```

The state should be: `[%0 lit=%on]`

The subscription status for the agents can be accessed from the `bowl`:
```
> :lightbulb +dbug %bowl
> :lightswitch +dbug %bowl
```

Outgoing subscriptions are in `wex`.  Incoming subscriptions are in `sup`.

So we should see that `%lightbulb` has one outgoing subscription in `wex` and 
`%lightswitch` has one incoming subscription in `sup`.

If we `%leave` from `%lightbulb`:
```
> :lightbulb %unsubscribe
```

We get a message that `%lightswitch` lost a subscriber:
```
>>   "%lighswitch got leave request for /switch from ~zod"
```

If we check out the `bowl`s for `%lightbulb` and `%lightswitch` they should show no 
subscriptions.

If we resubscribe and then do a kick from `%lightswitch`:
```
> :lightbulb %subscribe
> :lightswitch %kick
```

We get a message from `%lightbulb`:
```
>>  "%lightbulb got %kick-ed off /switch/~zod"
```

Again, the respective `bowl`s for `%lightbulb` and `%lightswitch` should show no 
subscriptions.

## Exercises

### lightswitch.hoon

First off, in `%lightswitch` we have been manually pushing out updates by sending a 
poke on the dojo.  What we really want to do is have the `%lightbulb` automatically 
updated whenever someone does a `%toggle`. 

- Update the `%toggle` poke handler to notify subscribers of our new `pos`.

- Also, we want new subscribers to sync up their state with the lightswitch.  So in
the `on-watch` handler for our path, send a subscription notification with the 
current `pos`.

- One possible solution can be found [here](code/answers/lightswitch-subs.hoon)

### lightbulb.hoon

So far, both agents were running on the same fakezod, but everything works exactly the same 
whether the agents are both running on the same ship or if they're running on different ships 
on different computers in different parts of the world.

So let's update `lightbulb.hoon` to support the lightswitch being on another machine.
- Update the `%subscribe` poke to also accept the `@p` of the ship that's hosting the
`%lightswitch`.
- Also update the `%unsubscribe` poke task to accept an `@p`.

You should probably first test this out to see if it all works when everything is running 
on the same fakezod.

Then once that's working, make another fake ship, with whatever address you want.  Let's 
say `~sampel`.  

Copy your updated `lightbulb.hoon` to it and get the `%lightbulb` agent on `~sampel`
subscribed to the `%lightswitch` agent running on `~zod`.

If you still have the `%lightbulb` agent subscribed on `~zod`, when you `%toggle` the 
`%lightswitch`, you should get an update on both agents.

- One possible solution can be found [here](code/answers/lightbulb-subs.hoon)

#### Extra Credit

- Instead of passing in the `@p` of the ship that's hosting `%lightswitch`, use
`wex.bowl` to figure out which ship the agent is running on.  
- In the `%subscribe` poke task, check to see if you are already subscribed on 
`/switch` somewhere else.  If so, unsubscribe from that ship.

[< Cards](cards.md) | [Home](overview.md)

