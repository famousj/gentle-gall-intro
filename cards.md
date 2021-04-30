# Cards

We have successfully poked our lightbulb agent and turned the lights on.  Great success!

So far, all of our pokes have come from the dojo.  This is perfectly fine for debugging 
or pedagogic purposes.  What we really want to do is send a poke from one agent to
another.

## The Bowl

Before we dig into that, let's talk about the `bowl`.  

We create the gall agent with this line here, line 20 in
[the lastest version of lightbulb.hoon](code/on-poke/app/lightbulb.hoon):
```
|_  =bowl:gall
```

The 'barcab' rune (`|_`) produces a `door`, which is a core with a sample.  The sample
is a `bowl`.  The bowl is a grab-bag of info about the state of the agent.

You can check out the definition of a `bowl` in `sys/lull.hoon`.  Since our app 
is wrapped in `dbug`, you can view the bowl for the `%lightbulb` app by running:

```
:lightbulb +dbug %bowl
```

Of note here are the following:

- `our` is the address of the ship the agent is running on.
- `src` is the address of the ship whose event started things.  So if we are in
the `on-poke` arm, then `src` will be the address of the ship that poked this agent.
- `eny` is freshly-squeezed entropy (i.e. a random number)
- `now` is the date/time

## Notes

You may recall that the return value for our `on-poke` and `on-init` arms are `(quip card _this)`, i.e. a list of `card`s and the agent, possibly with updates.

These `card`s are how you send messages and requests to other parts of the Urbit OS or to 
other agents.  It's the same card whether the agent is on your ship or some other ship
running on some other computer.

Let's say an agent wants to request that the `%lightbulb` turn itself on.  We have a poke 
task to do that, `%set-lit`.  So let's make a card for this.

The specific kind of card we need to create is a `note`.  To send a note, we create 
a `%pass` card.  

If we look in `sys/arvo.hoon`, we see that a `%pass` card is defined as:
```
[%pass p=path q=a]
```

The `p` is a path that the destination can use to send a reply to this card.

There are two ways to define a `path`.  These two are equivalent:
```
/this/is/a/path
[%this %is %a %path ~]
```

We can choose whatever we want here.  Let's use `/lightbulb-path`.

For the `q` in the `%pass` card, we're going to create a `node:agent:gall`.

If you'd like to look at the definition of `note:agent:gall`, go to `sys/lull.hoon`, find
`++  gall`, and scroll down to `++  agent`.  (Note the two spaces after the `++`).

There we see that `note:agent:gall` is defined as a union of:

```
[%arvo =note-arvo]
[%agent [=ship name=term] =task]
```

We want the `%agent` note, which has a destination pair and a `task`.

`ship` is the `@p` of the ship the agent is running on.  If the other agent is running 
on the same machine as this agent, we can pull the address out of the bowl,
specifically `our.bowl`.

`name` is the name of the agent, i.e. `%lightbulb`.

So far, our card looks like:

```
[%pass /lighbulb-path %agent [our.bowl %lightbulb] ...]
```

The last thing we need for our `%agent` note is the `task`.

We want a task specific to gall agents, a `task:agent:gall`.   This is defined right
below `note:agent:gall` in `sys/lull.hoon`.  We have several to choose from.  We
want the `%poke` task, which is defined as:

```
[%poke =cage]
```

The `cage` will be a pair of a `mark` and a `vase`, which not coincidentally is the input 
we use in `on-poke`.

We aren't (yet) using a special `mark`, so we'll use the generic `%noun` mark.

As I mentioned previously, you can generate a vase with the 'zapgar' rune (`!>`).

We are doing the `%set-lit` poke with either `%on` or `%off`.

So the vase will be:
```
!>([%set-lit %on])
```

Whew.  I think we now have everything we need to make our `card`:

```
[%pass /lightbulb-path %agent [our.bowl %lightbulb] %poke %noun !>([%set-lit %on])]
```

## Notes in Action

Now that we know what the card is going to look like, let's add this to an agent and
send it.

Cards are handled by gall, and only come as the result of running one of the `on-`
arms.  

We specify the destination for our `%agent` note with the pair `[=ship name=term]`.  
This could be another agent running on another ship, but there's no reason it can't be
this agent running on this ship.

So we're going to create a new task in `on-poke` of `lightbulb.hoon` to send a poke
to ourselves.

Updated code can be found in [code/cards/app/lightbulb.hoon](code/cards/app/lightbulb.hoon).

Our new poke is on lines 48-54.  Some notes:

Line 49:
```
      ~&  >  "%lightbulb passing {<+.q.vase>}"
```

We use string interpolation so we see the `on-off` value we are passing in.  

Lines 50-52:
```
      =/  new-lit  +.q.vase
      =/  task     [%poke %noun !>([%set-lit new-lit])]
      =/  note     [%agent [our.bowl %lightbulb] task]
```      	

The problem with our card is that it's too long. It's 83 characters wide, without
the indents..  So, we split the card into pieces to make it a bit more manageable
and readable.

Lines 53-54:
```
      :_  this
      ~[[%pass /lightbulb-path note]]
```

By convention, you want the "heaviest" code at the bottom.  So we use 'colcab' (`:_`) 
to make a cell in reverse order.

Copy [this file](code/cards/app/lightbulb.hoon) to your fakezod, `|commit %home`, and try
it out!

```
> :lightbulb [%pass-note %on]
```

We should should see this:
```
>   "%lightbulb passing %on"
>   '%lightbulb changing lit state'
```

The first message is from our new `%pass-note`, and the second one for the `%set-lit`.

## Exercises

A lightswitch is usually connected to a lightbulb somewhere.  So let's connect our 
`%lightswitch` agent to our `%lightbulb` agent.

Last time we added a `%toggle` task to our `%lightswitch`.  Now on top of updating the 
`%lightswitch` state, return a card to tell the `%lightbulb` agent to turn itself off or on.

One solution can be found here: [here](code/answers/lightswitch-poke.hoon).

[< on-poke](on-poke.md) |


