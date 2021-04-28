# Getting Started

In the interest of making things as easy on ourselves as possible, we're going to use the simplest state machine I can think of, a regular old incandescent lighbulb.  It's got two states: on and off.

Rather than start from scratch, the OG [Gall Guide](https://github.com/timlucmiptev/gall-guide) has provided a [starter app](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/skeleton.hoon).  So I have copied that and made some changes, in [code/init/lightbulb.hoon](code/init/lightbulb.hoon).

## Code Show-and-Tell

I'll point out a few things, and you can safely ignore everything else for now.

First off, on line 3, we see:
```
/+  dbug, default-agent
```

These are library imports.  

`dbug` will let us inspect the agent's state, which we will use later.  As for `default-agent`, 
every gall agent must be a `door` with exactly ten arms.  Specifically all the arms you see that 
start with `on-`.  `default-agent` has stubbed out versions of all these arms.  So if there are 
any arms you don't care about, you can call the `default-agent` version of that arm.

Then lines 10:
```
+$  on-off   $?(%on %off)
```

The 'lusbuc' rune, `+$`, declares a "structure" arm, i.e. an arm that defines a type.  

`%on` and `%off` are `term`s.  A term can act as both data and a type with one possible value, 
itself.  

We use 'bucwut' (`$?`) to declare a union of these two types.  

Note that for union types, the last type is the default.

Then on line 11:
```
+$  state-0  [%0 light=on-off]
```

Our state has two elements, `%0` which is the version, and `lit`, which uses that union type we just declared.

Now the only arm of this that's not boilerplate is `on-init`, lines 24-27:
```
++  on-init
  ^-  (quip card _this) 
  ~&  >  '%lightbulb initialized successfully'
  [~ this(state [%0 *on-off])]
```

First off, we cast the results to `(quip card _this)`.  Most of the arms of a gall agent have this return type, so let's break it down.

`(quip a b)` creates a type of `[(list a) b]`.  

A `card` is any new event we want to trigger, something like a subscription to another agent or possibly an HTTP call maybe.

`_this` means "whatever the type of `this` is", specifically the agent.

Thus, line 25 means this arm is going to return a list of new events to create and a possibly-updated version of this agent.  

Line 26 is a debugging message.  If everything works, we should see this in the dojo.

Line 27 is our return for this arm:
```
[~ this(state [%0 %off])]
```

The first `~` means we aren't kicking off any new events.  

`this(state [%0 %off])` will return `this` with the state set to `[%0 %off]`.

For union types, the default is the last type given, in this case `%off`.  So 
the state will be set to `[%0 %off]` by default.  Thus we could have returned, 
`[~ this]`.

But there's enough magic in Hoon as it is, and I thought I'd be explicit here.

Another way this could be written would be:
```
`this(state [%0 %off])
```

Or even:
```
`this
```

I would prefer `[~ this]`, since again, it's a bit more explicit what you're doing
here, but these are equivalent.

Before we move on, on line 21-22, we see this:
```
+*  this      . 
    def   ~(. (default-agent this %|) bowl)
```

I mentioned that a gall agent has to be a door with exactly ten `on-` arms.  This is true.  The 'lustar' (`+*`) is a "virtual arm".  It declares a couple of aliases that can be used by each of the non-virtual arms in the door.

## Running the Agent

Okay, now that we know what some of the code does, let's try this out!

Assuming you're running a fake ~zod, copy the file [`code/init/lightbulb.hoon`](code/init/lightbulb.hoon) into the `app` directory on your `zod/home`.

Then in the dojo run:
```
|commit %home
|start %lightbulb
```

Hopefully you see this:
```
>   '%lightbulb initialized successfully'
```

Now how do we look at the state?  Run this:
```
:lightbulb +dbug
```

We get back:
```
>   [%0 lit=%off]                                                                                  
```

Congratulations!  We now have an agent running, representing a lightbulb that is set to `%off`.

What if we want to turn it `%on`?  We'll do that next!

A quick development note: The `on-init` arm runs when the agent successfully 
compiles and never runs again.  It's like Eminem in [that one song](https://www.youtube.com/watch?v=SW-BU6keEUw); 
you only get one shot.  So if you're working on the `on-init` arm, it is a great 
time-saver to do the Gall Guide's 
[Faster Fakeship Startup](https://github.com/timlucmiptev/gall-guide/blob/master/workflow.md#faster-fakeship-startup).  

Then when you make changes to `on-init` you can quickly spin up a fresh ship to test your
changes on.

## Exercises

- Starting with the Gall Guide's 
[starter app](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/skeleton.hoon) 
or the [lightbulb code](code/init/lightbulb.hoon) make another agent representing a light switch.  
  - Like the lightbulb, should have an `%on`/`%off` state.
  - Also, it should have a counter to keep track of the number of times it's switched.

- You can find my answer [here](code/init/lightswitch.hoon).

