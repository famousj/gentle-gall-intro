# Surfaces

Depending on how you implemented the solution to adding an "on-off" state to 
`lightswitch.hoon`, you might have duplicated the `on-off` state from
`lightbulb.hoon`.  Or you might have done something completely different.

Consider the two files as implemented by me:

- [code/on-init/app/lightbulb.hoon](code/on-init/app/lightbulb.hoon)

- [code/answers/lightswitch-init.hoon](code/answers/lightswitch-init.hoon)

They both declare the same `on-off` type, which is a union of `%on` and `%off`.

This scenario is extremely simple (by design), but if we had a more complicated
type we wanted to use in two different files, we would probably not want to 
rely on copying and pasting.

The Hoon solution to this is to create a "surface", which is a custom
type.

Surfaces are written into `.hoon` files and stored in the `sur` 
directory.

There's a surface for our shared `on-off` type in 
[code/sur/sur/lighting.hoon](code/surfaces/sur/lighting.hoon).

This file is a big three lines long, and here's the whole thing
```
|%
+$  on-off  $?(%on %off)
--
```

An updated version of `lightbulb.hoon` can be found at 
[code/sur/app/lightbulb.hoon](code/sur/app/lightbulb.hoon).

On line 4:
```
/-  lighting
```

We import a surface with the 'fashep' rune (`/-`).

Line 11:
```
+$  state-0  [%0 lit=on-off:lighting]
```

Wherever we use `on-off`, we now have to explicitly say that this type
is found in `lighting`.  

Alternately, we could expose the whole `lighting` namespace using the 
'tiscom' rune, (`=,`).  Like so:
```
=,  lighting
```

We're only using `on-off` in one place, so consider the tradeoff 
between brevity and clarity, since `on-off:lighting` is a bit shorter
but it's much more clear where it's coming from.

If you would like to try out the surface (and you should!) 
you can run this to copy the updated `app/lightbulb.hoon` and 
`sur/lighting.hoon` with this command:

```
rsync -av gentle-gall-intro/code/sur/ fakezod/home/
```

(Adjust your directories as needed.)

When we start sending messages between lightbulbs and lightswitches, we'll
revisit this surface.  But this is enough for now.

## Exercise

Import the `lighting` surface into `lightswitch.hoon` and remove 
whatever type you had been using for the position state.

One solution can be found [here](code/answers/lightswitch-sur.hoon)

[&lt; on-poke](on-poke.md) | [Home](overview.md) | [Cards &gt;](cards.md)

