# Finding the Subscription Host

I made this assignment without having any idea how I would figure out how I would
actually find the ship that we are subscribed on.  It turns out it's harder than
I had expected.

So I thought I'd lay out some of the steps I took to find a solution and some
links to how you can fill in any gaps you might have in your understanding.

Note that if you struggle with this and find your own solution, it will 
probably stick in your memory better than reading what some other person did.  
So try it out, and read on only if you're completely stuck or you're done and
just want to hear if there's an easier way to do it.

First off, incoming subscription info is stored in `wex.bowl`.  

If you have a subscription and you run
```
> :lightbulb +dbug %bowl
```

You'll see something like this for `wex`:
```
wex={[p=[wire=/switch/~zod ship=~zod term=%lightswitch] q=[acked=%.y path=/switch]]}
```
	
First, you'll want to search for the definition of `wex`.  Turns out it's in 
`sys/lull.hoon`.

It seems that `wex` is a map, with the key being the tuple of `[=wire =ship =term]`.

We need to figure out which key has a `term` of `%lightswitch` and then grab
the `ship` from it.  

A search of the [Urbit docs](https://urbit.org/docs) reveals some links:

[Map functions in the stdlib are here](https://urbit.org/docs/hoon/reference/stdlib/2i/)

[Map discussion from Hoon School here](https://urbit.org/docs/hoon/hoon-school/trees-sets-and-maps/#maps)

This reveals [`key:by`](https://urbit.org/docs/hoon/reference/stdlib/2i/#key-by), 
which will return all the keys as a `set`.

So what can we do with a set?

[Set functions in the stdlib are here](https://urbit.org/docs/hoon/reference/stdlib/2h/)

[Set discussion from Hoon School here](https://urbit.org/docs/hoon/hoon-school/trees-sets-and-maps/#sets)

It seems that there's a lot more functionality available if we turn the set into a `list`, 
and we can convert a set into a list with 
[`tap:in`](https://urbit.org/docs/hoon/reference/stdlib/2h/#tap-in).

[List functions in the stdlib are here](https://urbit.org/docs/hoon/reference/stdlib/2b/)

[List discussion from Hoon School here](https://urbit.org/docs/hoon/hoon-school/lists/)

Of note is [`murn`](https://urbit.org/docs/hoon/reference/stdlib/2b/#murn), which seems 
to be short for "maybe [`turn`](https://urbit.org/docs/hoon/reference/stdlib/2b/#turn)".  
Basically this takes an arm that returns a unit and strips out all the null values.

So we need a gate that takes the key tuple from `wex` and if the `term` matches
`%lightswitch`, we return `` `ship `` i.e. "unit of `ship`").  If it doesn't match, 
we return `~`.

Then we run that through `murn` and that will give us a list of all the ships 
for which we're subscribed to their `%lightswitch`.  Or an empty list.

Then we can use [`turn`](https://urbit.org/docs/hoon/reference/stdlib/2b/#turn)"
to  make cards out of all those ships, and return those with `%unsubscribe`.

And if all else fails, you can check out one solution at 
[code/answers/lightbulb-org.hoon](code/answers/lightbulb-org.hoon).

