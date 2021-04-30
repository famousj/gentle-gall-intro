# Pokes

So how do we change the state and turn the light on?

There are two ways to get events from outside the app: subscriptions and pokes.  We'll 
cover subscriptions in a later chapter.  For now, let's talk about pokes.

A "poke" is a one-time action coming from outside the agent.  Gall receives the poke,
and it calls the `on-poke` arm for the appropriate agent.

Here's an [updated lightbulb agent](code/on-poke/app/lightbulb.hoon) has the `on-poke` arm 
filled out.

On line 37, we see this
```
  |=  [=mark =vase]
```

`on-poke` takes two parameters, a `mark` and a `vase`:

A `mark` is a term representing a data type.  `%noun` is a mark representing any noun. `%json` means JSON data.

A `vase` is a pair whose head, `p`, is a type and whose tail, `q`, is data.

The "type" for the `vase` is different than the "type" for the `mark`.  `p.vase` is a 
hoon type, something like "a cell with two `@ud`s".  A `mark` is a more general data type.  
We will talk more about `mark`s later.

You can make a vase in the dojo, using the 'zapgar' rune (`!>`):
```
> !>([~tul 0x42])
[#t/[@p @ux] q=[42 66]]
```

Line 38:
```
  ^-  (quip card _this)
```

Like `on-init`, the return value for this arm will be a list of cards and this agent, 
possibly with changes.

Line 39:
```
  ?+    mark  (on-poke:def mark vase)
```

We are going to switch against the mark.  There are two ways to do a switch in Hoon, 
`?-` and `?+`.  'wuthep' (`?-`) requires an exhaustive search.  For 'wutlus' (`?+`), 
doesn't have to be exhaustive; you provide a default, in case you find something
you weren't expecting.

Since a mark is just a `@tas`, it could be practically anything.  Therefore we use 
`?+` , and use the `default-agent` version of `on-poke` in the very real likelihood we
get a mark we aren't expecting.

The next two lines, 40-41:
```
      %noun
    ?+    q.vase  (on-poke:def mark vase)
```

The first mark we check is `%noun`, the mark for any noun.  For now, this is the only 
mark we are checking for, but in the future we will make a custom mark for this.

If we get a `%noun` mark, we then inspect the `q` in the `vase`, i.e. the data part.
Again, this could be anything, so we use the `?+` rune and `on-poke` from 
`default-agent` as the default.

```
        %print-state
      ~&  >>  state
      [~ this]
    ==
```

If we get sent `%print-state`, we are going to print the state, then 
return with no new cards and no changes to the state.

We add a `>>` after the 'sigpam' to output in a different color.

Line 45:
```
        [%set-lit on-off]
```

For this to match, we need to have been sent both `%set-lit` and a valid `on-off` state.

Line 47:
```
      [~ this(state [%0 lit=+.q.vase])]
```

We update the `state` for `this`, setting `lit` to `+.q.vase`, i.e. the tail of the data 
part of `vase`, the `on-off` value.

We return no new cards and the newly-updated `this`.

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

We should see the state printed out, just like with `+dbug`.

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
:lightbulb %print-state
```

This confirms that the lights are now on.

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
   - Also, every time you get a poke on `%toggle`, increase the counter by 1.

- You can find my answer [here](code/answers/lightswitch-poke.hoon).

[< on-init](on-init.md) | [Home](overview.md) | [Cards >](cards.md)
