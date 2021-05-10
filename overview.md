# A Gentle Introduction to Gall

## by ~ribben-donnyl

Table of Contents

[Introduction](intro.md)

[Getting Started](on-init.md)

[Pokes](on-poke.md)

[Cards](cards.md)

[Subscriptions](subscriptions.md)

[Code Organization](org.md)

This document is for people who want in on the glamorous and fast-paced world of writing Gall agents.  

It assumes you have some idea of [what Hoon is](https://urbit.org/docs/glossary/hoon/).  Preferrably you should have finished [Hoon School through part 1](https://urbit.org/docs/hoon/hoon-school/).  If you don't know what a [core](https://urbit.org/docs/hoon/hoon-school/arms-and-cores/) or a [door](https://urbit.org/docs/hoon/hoon-school/doors/) are, you're going to have a bad time.

Ideally you should also know at least one other programming language and have some familiarity with computer science topics.  But I'll try to break things down, so hopefully this will be helpful but not necessary.

Also, in later chapters, when we start plugging things into Landscape, you'll need some familiarity with web programming.  At the very least you should know how to spell HTML.

I primarily wrote this for my sake to help me understand how everything comes together.  
When I drill into a piece of code, I'm usually writing out the answers to 
questions I myself had about it, and sparing you the research I needed to do.  

Urbit code is notoriously cryptic, but if you take the time to break down all the 
runes and odd made-up words as variable names, it starts to make sense.

So if you understand the basics of Hoon, but don't feel like you really "get" it, 
this might also help on that.

If you have any questions, comments, suggestions, whatever, send a DM to ~ribben-donnyl.

Before you get started, you might want to read the [workflow](https://github.com/timlucmiptev/gall-guide/blob/master/workflow.md) section of the OG [Gall guide](https://github.com/timlucmiptev/gall-guide), (to which this introduction owes a tremendous debt of gratitude, by the way).

I wrote all the examples for running on a fake ~zod, so if you don't have one of those setup, [please do that now](https://urbit.org/docs/development/environment/).  Note that developing apps on your personal Urbit ship on the live network is not generally considered a good idea.

**FINAL NOTE**: This is a work in progress!  Hopefully you learn some things reading this
but the early chapters are geared towards teaching concepts, not producing code that your
mother will speak of with pride.  For now, when you're finished, I will again refer you
to [~timluc-miptev's Gall guide](https://github.com/timlucmiptev/gall-guide).

And if you find this helpful, feel free to send a few satoshis my way:

<img src="wallet.png" width="100px"/>

[Intro >](intro.md)

