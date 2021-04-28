# Arvo Agent Arms


- Copy `skeleton.hoon`

- Fill in all arms with `default-agent`

- KM Explain the `tistar`

- Looking at `lightswitch-0.hoon`

  - Ignore everything but `on-init`.

  - Note the return value: `^-  (quip card _this)`

  - `(quip a b)` makes the return type `[(list a) b]`

  - `card` is any events we want triggered.  In this case, we don't, so we 
  make this an empty list, `~`

  - `_this` means "whatever type `this` is"

  - `this(state [%0 %off])` means "use `this` but change out `state` for 
  `[%0 %off]`.

  - On line n we declare state to be the default value.  As it happens, the 
  default value for `on-off` is the last value, `%off`.  So we could have 
  just returned `this`.   

  - But it doesn't hurt to be explicit.  

  - Alternately, we could have returned:
  ```
  `this(state [%0 %off])
  ```

  - Or even
  ```
  `this
  ```

  - Make a note about the `backup-zod` thing if you need to iterate on the 
  `on-init` thing

- Now run `:lightswitch +dbug`

- As you can see, we have a state of `%off`

- KM Homework: make a lightswitch.  Like the lightbulb, it should have two states: `%on` and `%off`.  And for auditing purposes, it should also have a counter.

- KM Link to skeleton in the gall guide

- KM Do this and add it as an "answer"

## Pokes

- So how do we change the state and turn the light on?

- Before we do that, let's talk about the `bowl`.  You see this on line N:
```
|_  =bowl:gall
```

The `bowl` is the app state.  You can access it from any of the arms in the agent core.  

Since our app is wrapped in `dbug`, we can look at the `bowl` by running:
```
:lightswitch +dbug %bowl
```

If we look in `sys/lull.hoon`, we see the defintion for `bowl`.

```
  +$  bowl                                              ::  standard app state
          $:  $:  our=ship                              ::  host
                  src=ship                              ::  guest
                  dap=term                              ::  agent
              ==                                        ::
              $:  wex=boat                              ::  outgoing subs
                  sup=bitt                              ::  incoming subs
              ==                                        ::
              $:  act=@ud                               ::  change number
                  eny=@uvJ                              ::  entropy
                  now=@da                               ::  current time
                  byk=beak                              ::  load source
          ==  ==                                        ::
```

Of note here are the following:

- `our` is the address of the ship hosting the agent
- `src` is the address of the ship that created the message (possibly the same ship) KM
- `wex` is outgoing subs
- `sup` is incoming subs
- `eny` is freshly-squeezed entropy (i.e. a random number)
- `now` is the date/time

Now let's make a new `on-poke`.  This will duplicate what the debugger is doing.  Replace the `++  on-poke` arm with this:

```
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >>  state
      ~&  >>>  bowl
      [~ this]
    ==
  ==
```

A quick breakdown:

```
  |=  [=mark =vase]
```

- The `on-poke` arm takes two parameters: 

  - `mark` which is a data type, like `%noun`, which is any noun, or `%json`, which is JSON data
  - `vase`, which is a pair with the head, `p`, being a type and the tail, `q` 
  being the data.

  - The "type" for the `vase` is different than the "type" for the `mark`.  
  The `p.vase` is the hoon type, e.g.  a cell with two `@ud`s.  A `mark` is a more general data
  type.  We will discuss `mark`s later.

  - KM Make a vase in the dojo with `zapgar`

```
  ^-  (quip card _this)
```
- As with `on-init`, we use `quip` to return a list of cards and whatever type `this` is

```
  ?+    mark  (on-poke:def mark vase)
```

- The `?+` rune means "switch against a union, with a default".  The union in this the mark.  If we don't have code to handle the mark, we do the default action, i.e. `(on-poke:def mark vase)`.  This will just call the `on-poke` from the `default-actions` library.

- We could have used the `?-` rune, which doesn't have a default.  But since we could get anything for the `mark`, we accept everything, handle the things we're expecting, and use the default for everything else.

- The first mark we check is `%noun`.  If you try to do a poke without giving it an explicit type, it will fill in `%noun` as the `mark`.

```
  ?+    q.vase  (on-poke:def mark vase)
```
- We do another `?+` on `q.vase`, i.e. the actual noun that was sent in.  If we don't find what we're looking for, again we call the default action.


```
        %print-state
      ~&  >>  state
      ~&  >>>  bowl
      [~ this]

```
- If we receive `%print-state`, we do a debugging `printf` of the state and the bowl.  Then we return `[~ this]`, which means this `poke` didn't produce any new cards and we have no changes to the state.

- Once you've replaced the code for `++on-poke`, head to the dojo for your fakezod and run:
```
> |commit %home
```

KM Breakdown of what's actually happening here?

Then run
```
> :lightswitch %print-state
```

And you'll see the state printed out, just like with `:lightswitch +dbug` and you'll also see the entire `bowl` printed out.

Now, let's actually update the lightbulb's state.  Under the `[~ this]` for the `%print-state`, let's add another `%noun`, this time to toggle the switch:
KM Use a line number here.

```
        %toggle
      ~&  >  '%lightswitch got a %toggle'
      =/  new-pos  ?:(=(pos.state %on) %off %on)
      [~ this(state [%0 new-pos])]
```

This is pretty straightforward.  We set the `new-pos` to whatever it wasn't before, and update the state with this value.

KM Do this in parts?  Part 1 updates the state and then part 2 sends a card?

Now, we could have just updated the state right there and returned that.  But instead of that, let's not do that

Now on our fakezod, run `|commit %home` and test it out:
```
> :lightswitch %toggle
> :lightswitch %print-state
```

Assuming it worked, you should see the state is now `%on`.

- KM Update your lightswitch to support a poke.  Let's assume it's one of those knob light switches, so you just press it and it will toggle the state from "off" to "on".
- So make a poke called `%toggle`, which will change the light switch state from %off to %on, or vice versa.  
- Also, every time %toggle is poked, increase the counter.

## Notes

- We have successfully poked our lightbulb agent.  Great success!

- You may recall that the return value for our `on-poke` and `on-init` arms are `(quip card _this)`.  So we return a list of `card`s and the updated state.  These `card`s are how you send messages to other agents or parts of the system.

- You may also recall in our discussion earlier that flipping a light switch to "off" does two things: it sets its state to "off" and it sends a message to a lightbulb to turn itself off.

- So let's use `card`s to turn the lightbulb on and off.

- We will be sending a `note`.  To send this note, we create a card with a type of `%pass`.

- If we look in `sys/arvo.hoon`, we see that a `%pass` card is defined as:

```
[%pass p=path q=a]
```

- The `path` is an address we define.  This should be unique to your ship.  
- KM pull in how to do a path from GG
- We'll set our path to `/lightbulb`

- The `q` is the note itself.

- Since the destination for our note is the agent itself, we will create an `%agent` note.   You can see this in `sys/lull.hoon` defined as:
```
[%agent [=ship name=term] =task]
```

- `ship` is one of the things that we get from the `bowl`.  Specifically `our.bowl` is the name of the ship that the agent is running on.

- The `name` is the name of the agent, i.e. `%lightbulb`.

- There are several possible `task`s we could send, which you can see if you go to `sys/lull.hoon`, look for `++  gall` and scroll down to `++  agent`.  (Note the two spaces)

- We are going to be sending a `poke` to ourself.  So our task will be: 
```
[%poke =cage]
```

- Okay, so what's a `cage`?  This is defined in `sys/arvo.hoon` as:
```
+$  cage  (cask vase)
```

- The `cask` in this case is our `mark`.  We aren't using a special `mark` (yet), so we'll use the extremely generic `mark` of `%noun`.  

- The `vase` is typed data.  You can create a `vase` automatically using the 'zapgar' rune, `!>`, which will make a pair with the type and the value.

- Whew.  I think we now have everything we need to make our `card`:

```
[%pass /lightbulb %agent [our.bowl %lightbulb] %agent %poke %noun !>([%set-pos %on])]
```

- KM Now make a %noun that will pass along this card.

- Pokes to other ships?

- KM Exercise: Update the `%lightswitch` app so that, when you get `poke`d with a `%toggle`, you ask the `%lighbulb` app to turn itself off or on, as appropriate. 

## Upgrading The State

Lightswitch-1

- KM Add a destination planet to the lightswitch

- Let's now model our lightswitch to have a color.  

- Use the state version to upgrade.

- Describe how the switch works.

- q.v. `lightswitch-1.hoon` 

## Poking Other Ships

- Hopefully you've been following along with the exercises and you have a working `%lightswitch` app.

- If not, here's a link to one.  KM

- Copy to `home/app` and `|commit %home`


## Subscribing

- Since the lightswitch doesn't have to be on the same ship as the lightbulb, it's now possible that we could have many lightswitches talking to the same lightbulb.

- This is a problem because now, if someone toggles the switch on `~nec`, then our switch on `~zod` is out of sync with the lightbulb. 

- (I wouldn't rate this as a huge problem, but this scenario is for pedagogic purposes.  Let's all just roll with it.)


- In our example, we have been assuming we have one lightswitch that controls a lightbulb.  You toggle the lightswitch and it sends a `poke` to the lightbulb turning it off or on.

- Now let's say that we could have many light switches talking to the same lightbulb.  So when the lightbulb turns off or on, we want to send a message back to the light switches telling them to 
change their toggle state to match the lightbulb.  So if the light is on, the toggle state is also on.



- KM Exercise: Update %lightswitch so it automatically subscribes when you create it?

- KM Exercise: Allow lightbulbs to subscribe to each other and sync up



## Marks and Surfaces

- KM `%noun` pokes are fine for dev and debugging purposes, or very simple apps like we've been making here.  

- They don't scale well

- We know exactly what we're going to get.

## Helper cores

### Parts of Urbit 

- Arvo: The OS

- Gall: The agent manager

## Anatomy of an Agent

- The core is both code and state



## Marks and Surfaces



## Talking to other vanes: Adding a timer



## HTTP input/output




## Other stuff

- Testing?



[n] Unless its a florescent light that's going bad and blinks on and off.
