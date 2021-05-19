# Marks

So, after adding the helper core and doing some reorg, here's how things look
for the `%lightbulb` agent:
[code/answers/lightbulb-org.hoon](code/answers/lightbulb-org.hoon)

We handle our incoming `%fact` from `%lightswitch` on lines 84-91.  

On line 85, we extract the data from the card:
```
       =/  lit-atom  !<(@ q.cage.sign)
```

Then we cast it to an `on-off` on line 87:
```
      =/  lit  ;;(on-off lit-atom)
```

I mentioned in a previous chapter that a term, like `%on` or `%off`, can act
as either data or a type, depending on the context.  

Our `on-off` type is a union of two terms as types: `%on` or `%off`.

But when we created our `%fact` card, we gave it the mark of `%atom`, and
passed the `%on` or `%off` terms as data.  So the compiler had no way to know if 
we were sending `%on` or `%off` or `%.y` or `42` or `.6.28` or anything else.

So we use `;;` to cast the atom as an `on-off`.  If we don't get `%on` or `%off`, 
we crash at runtime.  A runtime failure is bad enough, but if we crash in the 
middle of `on-agent`, this will automatically cancel our subscription.  

What we need to do is create our own mark, so that we can send `%on` or 
`%off` directly, and then give the subscriber some hint about the subscription
payload so it will better be able to handle it.

## Marks

There's an updated project with a mark for our `on-off` type.  You can find in 
[code/marks](code/marks).

First, let's look at the mark file itself, in
[code/marks/mar/lighting/on-off.hoon](code/marks/mar/lighting/on-off.hoon)

The first thing to note is the filename.  Since this mark is specific to our
two agents, we keep the `mar` directory tidy by putting our mark `.hoon` file
in a subdirectory, called `lighting`.  If we create any more marks, they
can also go in `lighting`.

Line 1:
```
/-  lighting
```

We first import the `lighting` surface.

Line 2:
```
|_  =on-off:lighting
```

Much like our `agent:gall` is a door with ten arms, a `mark` is a door with 
three arms, named `grab`, `grow`, and `grad`.  Our sample is an `on-off`.

Lines 3-6;
```
++  grab
  |%
  ++  noun  on-off:lighting
  --
```

The `grab` arm will "grab" data from another mark and turn it into this
mark.  `grab` a core, where each arm is another mark we can convert from.

Line 5:
```
  ++  noun  on-off:lighting
```

For `noun`, we are casting our noun as an `on-off`.  This is sometimes called 
"clamming".  

Much like when we handle our `%fact` card in `%lightbulb`, if we end up with 
a noun that isn't `%on` or `%off`, this will give us an error.

Lines 7-10:
```
++  grow
  |%
  ++  noun  on-off
  --
```

The `grow` arm is for converting (or "grow"-ing) from this mark to another 
mark.

It's another core, with each arm being the marks we can convert to.  In this
case, we return the sample for our door, `on-off`.

Line 11:
```
++  grad  %noun
```

Marks were developed for Clay, which is the Urbit typed, and version controlled 
file system.  The `grad` arm is for does diffs between versions of the data.  
("grad" might be short for "upgrade".  Even if it isn't, it's a decent mnemonic
for it.)

In our case, we don't need to define any special behavior, so this line says
that if we need to call `grad`, we should convert our `%on-off` mark to a 
`%noun`, do the diff, then convert back to an `%on-off`.

Unlike the other two arms, the mark file will not compile without a `grad`
defined, even though in this case it is not being used.

## Sending with Marks

Here's an updated version of `%lightswitch`
[code/marks/app/lightswitch.hoon](code/marks/app/lightswitch.hoon)

The one change in this file is line 107:
```
  [%give %fact paths=~[/switch] %lighting-on-off !>(pos)]
```

Our mark has changed from `%atom` to `%lighting-on-off`.  

It's defined in `mar/lighting/on-off.hoon`, but in making this into a term, 
the 'fas' (`/`) in `lighting/on-off` was turned into a 'hep' (`-`).

Note that the sender doesn't actually use the mark file.  It just creates a vase
and a term and lets the recipient take it from there.

So what does the recipient do with it?

##  Receiving with Marks

Here's the updated version of `%lightbulb`
[code/marks/app/lightbulb.hoon](code/marks/app/lightbulb.hoon)

We updated the handler for `%fact` cards in `on-agent` on lines 84-90:
```
        %fact
      ?+    p.cage.sign  (on-poke:def mark vase)
          %lighting-on-off
        =/  lit  !<(on-off q.cage.sign)
        ~&  >>  "%lightbulb received {<lit>} from {<src.bowl>} on {<`path`wire>}"
        [~ this(state [%0 lit])]
      ==
```

On line 85:
```
      ?+    p.cage.sign  (on-poke:def mark vase)
```

A `cage` is a pair of `p=mark` and `q=vase`.  Previously we had been ignoring 
the mark.  But since we're now expecting something specific from the vase,
so it's a good idea to check for a mark of `%lighting-on-off` and fall back to 
our `default-agent` handler if we get something different.

Bear in mind that there are no checks to make sure the data is valid before
it shows up at the recipient.  The sender could set the mark to `%lighting-on-off`
and then create a vase with `!>(%neither-on-nor-off)`.  

## Exercises

There's one other thing to note: If the agent and the subscriber are running on the 
same ship, Gall gives the card directly to the subscriber and ignores the mark.

So your exercise is to fire up two fake ships, `rsync` the code from 
[code/marks](code/marks) to both of them, and have `%lightbulb` on one of them 
subscribe to `%lightswitch` on the other.

Then run...
```
:lightswitch %give-pos
```
...on whichever ship is running `%lightswitch`.  

Once you've confirmed that's working, edit `app/lightswitch.hoon` and 
have it send a `%fact` card with either a bad mark or bad data, and make sure
this does what you're expecting.

Next time we'll add a much more complicated mark, and we'll have more substantial
homework then.

[&lt; Getting Organized] | [Home](overview.md) 
