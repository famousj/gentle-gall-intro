# Intro

## What Is an Agent Anyway?

In this guide, we're going to be writing agents for gall.

So what is a gall agent?

A gall agent, or "agent" as we'll call it, is kind of like a database.  It holds onto some data, and you can update the data based on inputs and events.  It's also kind of like a Unix daemon.  It's a service that's running all the time your Urbit ship is running and it can listen for events, send replies, and other services can listen in and get updates when they happen.

But the best way to think about an agent is as a [state machine](https://en.wikipedia.org/wiki/Finite-state_machine)

## States and Events

A state machine, in computer science terms, is a system with some number of states, that get changed based on time or some other thing interacting with it.  

Most things can be thought of as state machines.  A good example is a lightbulb.

In the simplest case, the lights have two states: "on" and "off".  If it's an old wonky florescent light, it might hvea a state of "flickering and making a very annoying buzzing sound".  And some lights have a dimmer, so they have a number of states between "fully on" and "fully off".

Stoplights (usually) have four states: "the green light is on", "the yellow light is on", "the red light is on", or "none of the lights are on".  Or after dark, they might have that "red light is blinking" state.

For the state to change on a light, the input can be a light switch.  Someone flips the switch, i.e. changes the light switch's state to "off".  This is an "event".  The light switch now has a state of "off".

Then, through a process that only electricians need to care about, this event sends a signal to the lightbulb it's connected to to turn itself off.

So you can think of flipping the light switch as having two effects:

1. Set the light switch state to "off"
1. Send a message to the lightbulb to turn itself off.

All of Urbit is basically a state machine.  Your Urbit ship gets events, like key presses in the CLI or a new DM from another ship.  Based on these events, new events might be created and the ship's state changes.

If you have other inputs and states you'd like to keep track of, beyond the ones that you get "out of the box", you need a new program for that, specifically an agent.  An Urbit agent does the same things the lights do, it keeps track of its state ("on" or "off") and listens for events ("tell the lightbulb to turn itself off").

It might listen to other parts of the Urbit OS (like for HTTP calls or `behn`, the Urbit timer system).  It might listen to other agents, much like the lightbulb listens for messages from the light switch (or however that all works).

But as we will see, our Urbit agents can do quite a bit more than a light switch, but conceptually, they're more or less the same.

[&lt; Overview](overview.md) [Getting Started &gt;](init.md)

