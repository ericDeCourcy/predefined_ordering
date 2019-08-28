# Introduction

This scheme has 2 states, the first is the `makeCalls` state, where users can call the contract and add transactions. The second is the `finalization` state, where those calls are placed into a pre-defined order and state changes resulting from them occur.

## `makeCalls` state

When the contract is in this state, users can make calls to the contract and have them placed into an array/mapping which keeps them until the `finalization` state is reached. The array used can be a 2-D mapping, with the first dimension being the address making the call, and the second dimension being an index for what order to make those calls in. This allows users to make a set of calls rather than just a single one. The user can place calls into this mapping in whichever spot they choose regarding the second dimension, to order contract calls in the manner they prefer. Once these calls are stored, they can be deleted by the user up until the end of the `makeCalls` period, but not within the `finalization` period. This is keep users from selectively omitting transactions for malicious reasons.

??? How does the contract keep track of how many calls are made per user in a dynamic 2D setting?

## `finalization` state

After the contract transitions to the `finalization` state, an order for the contract calls is determined and set. This can either be pre-discussed and understood, such as starting with the user with the lowest address, starting with the user that was previously last, or doing some sort of round-robin style in which the first user rotates through all users.

While in this state, and after an order is set, each user can submit thier transaction for processing. For each submitted transaction, all changes are logged. If a userA can prove that another user has submitted already, but with a later order than userA, the original submitter's changes are reversed, and userA's changes are applied and logged.

It should be ensure that, since this state may require more `gas`, it should potentially be allowed more time than the  `makeCalls` state.

# NOTES

??? managing transactions that would have been possible, but now are not as things have changed between when they were called and when they are executed in the `finalization` stage

  ??? doing so in a gneralized, abstracted way
  
  ??? doing so in common scenarios, such as games or DEX's
  
??? how to manage reverts in a general way. consider not only explicit reverts, but also "out of gas" calls

  ??? could be done with an error system rather than reverts
  
  ??? how to manage out of gas though???
    
  ??? could finalize calls in a more general way, constructing some sort of tree describing effects for each call and times. This may add a second, intermediate stage, perhaps called `determine effects`
