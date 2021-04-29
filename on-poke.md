# Pokes

## The Bowl

So how do we change the state and turn the light on?

I have updated our lightbulb code to do that.  You can see in 
[code/on-poke/app/lightbulb.hoon](code/on-poke/app/lightbulb.hoon).

Before we dig into that, let's talk about the `bowl`.  

We actually create the gall agent starting on line 21:
```
|_  =bowl:gall
```

The 'barcab' rune (`|_`) produces a `door`, which is a core with a sample.  The sample
is a `bowl`, which is the app state.

(Do you know why it's called a "bowl"?  Neither do I.)

Since the bowl is the sample for the agent, you can access it from any of the agent
core's arms.  

You can checkout the definition of a `bowl` in `sys/lull.hoon`.  Since our app 
is wrapped in `dbug`, you can view the bowl by running:
```
:lightswitch +dbug %bowl
```

Of note here are the following:

- `our` is the address of the ship hosting the agent
- `src` is the address of the ship whose event kicked off the arm that's running 
(possibly the same ship) 
- `eny` is freshly-squeezed entropy (i.e. a random number)
- `now` is the date/time

## `on-poke`

There are two ways to get events from outside the app: subscriptions and pokes.  We'll 
cover subscriptions in a later chapter.  For now, let's talk about pokes.

A "poke" is a one-time action coming from outside the agent.  Gall receives the poke,
and it calls the `on-poke` arm for the appropriate agent.

The [updated lightbulb](code/on-poke/app/lightbulb.hoon) has the `on-poke` arm filled out.

On line 37, we see this
```
  |=  [=mark =vase]
```

`on-poke` takes two parameters, a `mark` and a `vase`:

A `mark` is a term representing a data type.  `%noun` is a mark representing any noun. `%json` means JSON data.

A `vase` is a pair with the head, `p`, being a type and the tail, `q` being the data.

The "type" for the `vase` is different than the "type" for the `mark`.  The `p.vase` is the 
hoon type, e.g.  a cell with two `@ud`s.  A `mark` is a more general data type.  We will 
discuss `mark`s later.

You can make a vase in the dojo.  The 'zapgar' rune (`!>`) is used for this:
```
> !>([~tul 0x42])                                                                                  [#t/[@p @ux] q=[42 66]]
```

On line 38:
```
  ^-  (quip card _this)
```

Like `on-init`, the return value for this arm will be a list of cards and this agent, 
possibly with changes.

On line 39:
```
  ?+    mark  (on-poke:def mark vase)
```

Now we're going to switch against the mark.  Since a mark is just a `@tas`, it could be 
practically anything.  So we use the 'wutlus' rune (`?+`), which means "switch 
against a union, with a default".  In the very real likelihood we get a mark we aren't
expecting, we call the `agent-default` version of `on-poke`.

The next two lines, 40-41:
```
      %noun
    ?+    q.vase  (on-poke:def mark vase)
```

The first mark we check is `%noun`.  For now, this is the only mark
we are checking for, but we'll add more in a later chapter.

If we get a `%noun` mark, we then inspect the `q` in the `vase`, i.e. the data part.
Again, this could be anything, so we use the `?+` rune. If we get something 
we aren't expecting, we use `on-poke` from `default-agent`.

```
        %print-state
      ~&  >>  state
      ~&  >>>  bowl
      [~ this]
    ==
```

If we get sent `%print-state`, we are going to print the state and the bowl, then we 
are going to update with no cards and no changes to the state.

The `>>` and `>>>` after the 'sigpam' will output in different colors.

Line 46:
```
        [%set-lit on-off]
```

We need to match both `%set-lit` and a valid on-off state.

Line 49:
```
      [~ this(state [%0 lit=+.q.vase])]
```

We set `lit` state to `+.q.vase`, i.e. the tail of the data part of `vase`.

We return no new cards and the updated `this`.

## Pokes in Action

Copy the file [`code/on-poke/app/lightbulb.hoon`](code/on-poke/app/lightbulb.hoon) into the `app` 
directory on your `zod/home`.

If you have cloned this repo, you can run:
```
rsync -av gentle-gall-intro/code/on-poke/ fakezod/home/
```

Then in the dojo run:
```
|commit %home
```

If everything worked, you'll see this:
```
>   '%lightbulb recompiled successfully'
```

Now let's test some pokes!

If you try to do a poke from the dojo without explicitly
specifying what mark you are using, the mark will be set to `%noun`.  

So let's do that.  Run this in the dojo.
```
:lightbulb %print-state
```

We should see the state and the bowl printed out.

Now run this:
```
:lightbulb [%set-lit %on]
```

We see this output:
```
>   '%lightbulb changing lit state'
```

But did it work?  Let's run:
```
:lightbulb +dbug
```

And this confirms that the lights are now on.

Of course, we shouldn't stop with the things we're expecting to work.  We 
should also test the things we're expecting _not_ to work.

```
:lightbulb %unexpected-noun
:lightbulb [%set-lit %neither-off-nor-on]
```

Both of those should give us
```
"unexpected poke to %lightbulb with mark %noun"                                                    
```

Totally as expected.

## Exercises

- Update your `lightswitch.hoon` to support a poke.
   - Let's assume this is one of those knob switches, so you press it and it toggles the 
   state from "off" to "on", or "on" to "off".
   - So make a poke called `%toggle`, which changes the state to whichever state it isn't.
   - Also, every time you get a poke on `%toggle`, increase the counter by 1

- You can find my answer [here](code/answers/lightswitch-poke.hoon).
