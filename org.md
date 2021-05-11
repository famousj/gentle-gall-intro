# Getting Organized

We've been adding functionality without much concern for how the code should be organized.

This isn't a huge problem yet, since our agents are short and don't have a lot of 
functionality.  Even so, there's already some improvement we could do.  And now is a
good time to consider where we might put any future functionality.

Hoon certainly looks different than the code you might be used to, but in the end,
good software design principles still apply.  

Consider the code for `lightswitch.hoon` as it stands after doing the exercises at
the end of the last chapter.  You can check it out here: 
[code/answers/lightswitch-subs.hoon](code/answers/lightswitch-subs.hoon)

(Note: this is my solution.  If your solution is a tidier and doesn't have these 
issues, great success!)

We're creating more or less identical `%fact` cards in three places, on line 54 and 
line 65 in `on-poke`, and on line 91 in `on-watch`.

Ideally, what we'd want to do is make a separate function for this, possibly in
the same core we're working in.  The problem is that `agent:gall` has to be a door 
with exactly 10 arms.

So, if not in the agent core, where should we put it?  

We already defined a separate core at the top of `lightswitch.hoon`, on lines 5-15.
This declares some types we use for our state, and we should probably leave this
only containing type definitions.

One answer is to make another core to keep our otherwise-duplicated functionality.  
Let's call this a "helper core", since that's what everyone else calls it.

So where should we put the helper core?

## Composition and Inversion

An updated, reorganized version of `%lightswitch` is in 
[code/org/app/lightswitch.hoon](code/org/app/lightswitch.hoon).

One line to take note of is line 20:
```
=<
```

Generally speaking, in a hoon file, you have access to everything defined above where you
are.  So that if you have code like this:
```
=/  plus-four  |=  a=@  (add a 4)
(plus-four 8)
```

You define `plus-four` and then you use it to figure out what 8 + 4 is.

If for some reason you wanted to invert this, perhaps to follow the Hoon style 
heuristic of "heavier code at the bottom", you can use the 'tisgal' rune (`=<`).
```
=<
(plus-four 8)
=/  plus-four  |=  a=@  (add a 4)
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

To access the helper core, we define an alias on line 24:
```
    hc    ~(. +> bowl)
```

The executive summary is that this is an alias for helper core with the
current bowl.  If you're content with that, skip to the next section.
Otherwise, read on while we go into the weeds and figure out how it works.

`~(a b c)` means "call `a` in door `b` with sample `c`.  

In this case, we use `+>` for the door.  `+>` is short for `+>:.`, where `.` 
means `this`, i.e. the agent core, and `+>:.` means means "the tail of the tail 
of `this`".  You may have read somewhere that a door is defined as a pair 
of `[battery payload]` where the battery is the code and the payload is the data.  
The payload for a door is a pair of `[sample context]`, so the tail of the tail 
of the agent core is the context.

When we used the `=<` rune, we explicitly set the context to be the helper 
core.  So the value of `+>`, the door we're calling from, is the helper core.

As for what we're calling in `+>`, instead of giving an arm name, we just ask 
for `.`, which means `this`.  So `.` will return the entire helper core.

Then we set the bowl as the sample. Note that, since this is an alias, this 
will be whatever the value of the bowl is at the time the `on-` arm is called.  
So if we use `hc` in the `on-poke` arm, this will be the value of `bowl` for the 
poke we're handling.

So, the `hc` alias means "the helper core with whatever the value of `bowl`
is a that time.

## Code Heuristics

As an aside, our helper core is actually way lighter than the agent core.  So
you could argue that we should therefore put it above the agent core.  But 
another heuristic to consider is maintainability.

As such, you should try to organize your code to minimize the mental overhead 
needed for someone else, or you in the future, to figure out what  it's doing.  
Most times the helper core is below the main agent core and that's where people 
will be expecting it.

There's an alternate way of adding functionality while keeping with the mandatory
10-arm door structure.  This involves the `|^` rune.  We'll discuss that in a future 
chapter.

## Security

There's another new line at 41:
```
?>  (team:title our.bowl src.bowl)
```

As we left things at the end of the last chapter, anyone could send a poke to our
`%lightswitch` agent.  This is a fairly substantial security hole that is 
fortunately very easy to fix.

The 'wutgar' (`?>`) is a "positive assertion".  It checks to see if something is
true (`%.y`) and if not, it crashes.  

The `team:title` function will return `%.y` if `src.bowl` is either this ship or
one of its moons.  If not, the `on-poke` method will crash.  (Note: when I say
"crash", the agent itself will still be running, but the `on-poke` method will 
halt right there.)

You can test this out and see, by starting `%lightswitch` on a different ship, like 
`~sampel`, and editing one of the cards so it's addressed to `~zod` instead of 
`our.bowl`.  

## Exercises

This was a pretty short chapter, so to make up for it, the exercises are especially
challenging.

In our last chapter, we added the ability to subscribe to a lightbulb running on
a different ship.  So instead of poking `%subscribe` and assuming `%lightswitch` is
running on `our.bowl`, we poke `[%subscribe @p]` and pass in the name of the other 
ship.

If you didn't finish that one, you can start with this version:
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
  - If you're subscribed somewhere else, unsubscribe from the other ship you're
  currently subscribed to and subscribe to the new ship.
  - Otherwise, just subscribe as usual.

(If you're totally stumped, I provided some [hints here](org-hints.md).)

[&lt; Subscriptions](subscriptions.md) | [Home](overview.md)

