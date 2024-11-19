# Event Sourcing
Event Sourcing allows us to persist an ordered sequence of transactions.

A Transaction means:
  [current state]->
  [This happened]->
  [That happened]->
  [end state]

This and That both occurred in a Transaction, which is simply a sequence of events that all happen together, or not at all.

We don't necessarily "roll-back This", This did occur, but if it may only occur if That happened too, then we "roll-back" which in Event Terms, means we change This back to what it was at Current State, but we have a Causation of That Failed.

There are many ways to actually achieve this, but what is more important is that we have measured and defined when it is done.
