# Getting Organized

We've been adding functionality without much concern for how the code should be organized.

This isn't a huge problem yet, since our agents are short and don't have a lot of 
functionality.  Even so, there's already some improvement we could do.

Hoon certainly looks different than the code you might be used to, but in the end
it's just software and good software development principles still apply.  

Consider the code for `lightswitch.hoon` as it stands after doing the exercises at
the end of the last chapter.  You can check this out here: 
[code/answers/lightswitch-subs.hoon](code/answers/lightswitch-subs.hoon)

(Note: this is my solution.  If your solution is a tidier and doesn't have these 
issues, great success!)

We're creating more or less identical `%fact` cards in three places, on line 54 and 
line 65 in `on-poke`, and on line 91 in `on-watch`.

Ideally, what we'd want to do is make a separate function for this, possibly in
the same core we're working in.  The problem is that `agent:gall` has to be a door 
with exactly 10 arms.

So, if not in the agent core, where should we put it?  One answer is to make another core
where we keep a lot of duplicated functionality or things we'd rather not repeat ourselves
with.

We already defined a separate core at the top of `lightswitch.hoon`, on lines 5-15.
This declares some types we use for our state.

So where should we put the helper core?

## Composition and Inversion

An updated, reorganized version of `%lightswitch` is in [code/org/app/lightswitch.hoon](code/org/app/lightswitch.hoon).

The line to take note of is line 20:
```
=<
```

Generally speaking, in a hoon file, you have access to everything defined above where you
are.  So that if you have code like this:
```
|=  plus-four  a  (add a 4)
(plus-four 8)
```

You define `plus-four` and then you use it to figure out what 8 + 4 is.

If for some reason you wanted to invert this, perhaps to follow the Hoon style 
heuristic of "heavier code at the bottom", you can use the 'tisgal' rune (`=<`).
```
=<
(plus-four 8)
|=  plus-four  a  (add a 4)
```

 `=<  a  b` says "evaluate `b` and then evaluate `a` with whatever changes 
were made when you were evaluating `b`.  So `b` defines the `plus-four` arm and
then `a` uses it to do very simple arithmetic.

It's the same principle in our agent, even if `a` and `b` are both cores that are
dozens of lines long.  

We'd like somewhere to put our extra functionality, perhaps to define some arms
where we can put some functionality that would otherwise be duplicated.

But also we'd like the agent core to be lightweight and nearer the top.

Hence the `=<` rune, which lets us do both.

## The Helper Core

So our helper core is below our agent core in the code, but the agent core still has
access to everything within.

As an aside, our helper core is actually way lighter than the agent core.  So
you could argue that we should therefore put it above the agent core.  But 
another heuristic to consider is maintainability.

As such, you should try to organize your code to minimize the mental overhead 
needed to figure out what it's doing.  Most times the helper core is below the main 
agent core and that's where people will be expecting it.

It's defined on line 95:
```
|_  =bowl:gall
```

Note that the helper core, like the agent core, is a door that has a `bowl:gall` as
a sample.  Thus we can use the same `bowl` we use in any of the arms.

There's an alternate way of adding functionality while keeping with the mandatory
10-arm door.  This involves the `|^` rune.  We'll discuss that in a future chapter.


## Exercises

This was a pretty short chapter, so to make up for it, the exercises are especially
challenging.

In our last exercise, we added the ability to subscribe to a lightbulb running on
a different ship.  So instead of poking `%subscribe` and assuming `%lightswitch` is
on `our.bowl`, we poke `[%subscribe @p]` and pass in the name of the other ship.

If you didn't finish that one, you can start with version:
[code/answers/lightbulb-subs.hoon](code/answers/lightbulb-subs.hoon)

1. Add a helper core.  If you find some logic or definitions you'd like to separate 
from the agent core, put them in there.  (This isn't the challenging part, by the 
way.)

2. Add an arm to your helper core that will examine the list of outgoing subscriptions
and determine the ship that you're subscribed to (if any).  (Hint: you'll need
to use `wex.bowl`)

3. Change the `[%unsubscribe @p]` poke handler back to `%unsubscribe`.  Use the 
arm you just wrote to determine if you have any outgoing subscriptions, and 
unsubscribe.

4. There are currently two problems with the `%subscribe` poke.  First off, if you
try to subscribe to a ship you're already subscribed to, you get a somewhat
cryptic error message.  Also, there's nothing stopping you from subscribing a
`%lightbulb` to two different `%lightswitch`es.

So, fix both these by calling the "where am I subscribed?" arm from #2 in the
`%subscribe` handler.  

  - If you're already subscribed on that ship, print a message, but don't 
  try to subscribe again.
  - If you're subscribed somewhere else, unsubscribe from the other ship

[&lt; Subscriptions](subscriptions.md) | [Home](overview.md)

