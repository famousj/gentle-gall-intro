# Intro

## Agents

A gall agent, sometimes known as a "gall app" or an "agent", is kind of like a database.  It holds onto some data, and you can update the data based on inputs and events.  It's also kind of like a Unix daemon.  It's a service that's running all the time your Urbit ship is running and it can listen for events, send replies, and other services can listen in and get updates when they happen.

But the best way to think about an agent is as a state machine. 


## States and Events

A state machine is a system with some number of states, that get changed based on time or some 
other thing interacting with it.  

Many things can be thought of as state machines.  A lightbulb, for instance.

In the simplest case, a lightbulb have two states: "on" and "off".  If it's an old florescent light that's going bad, it might have a state of "flickering and making a very annoying buzzing sound".  And some lights have a dimmer, so they have a number of states between "fully on" and "fully off".

Stoplights have four states: "the green light is on", "the yellow light is on", "the red light is on", or "none of the lights are on".  After hours, they might have that "red light is blinking" state.

For the state to change on a light, you need some kind of input, like a light switch.  Someone flips the switch.  This is an "event".  This changes the light switch's state to "off".

Then, through a process that only electricians need to care about, the light switch sends a signal to the lightbulb it's connected to, and the lightbulb changes its state, i.e. turns off.

So you can think of flipping the light switch as having two effects:

1. Set the light switch state to "off"
1. Send a message to the lightbulb to turn itself off.

A somewhat more complicated example is one of those old-school subway turnstyles.  It's state is "locked" until you insert a token (an event) and its state becomes "unlocked".  Then when someone pushes through it (a different event), and its state resets to "locked".

All of Urbit is a state machine.  Your Urbit ship gets events, like key presses in the CLI or a new DM from another ship.  Based on these events, new events might be created and the ship's state changes.

If you have other inputs and states you'd like to keep track of, beyond the ones that come built-in, you need a new program for that.  That program is an agent. 

An Urbit agent does the same things lightbulbs or turnstyles.  It keeps track of its state ("on" or "locked") and listens for events ("tell the lightbulb to turn itself off", "someone inserted a token").

It might listen to other parts of the Urbit OS (like for HTTP calls or `behn`, the Urbit timer system).  It might listen to other agents, like how the lightbulb listens for messages from the light switch (however that all works).

Urbit agents can do quite a bit more than a light switch, but conceptually, that's what's going on.

Here's wikipedia on [finite-state machines](https://en.wikipedia.org/wiki/Finite-state_machine).  A gall agent can handle infinitely many states, whatever you want to keep track of.  But the basic concept is the same.

[Home](overview.md) | [Getting Started &gt;](on-init.md)

