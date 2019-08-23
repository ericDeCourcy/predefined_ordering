# Considerations for DEX's

In the application of a pre-defined ordering scheme for a decentralized exchange, some special considerations must exist. 
- users should be incentivized to NOT withdraw thier orders. Otherwise, users may submit many orders, choosing to only actually confirm those that work best for them. We'll ask that they submit and "anti-quitter stake"
- users should be incentivized to process thier own orders. The DEX and other users should not be responsible for paying the fees associated with order processing. This should hold true for all applications of pre-defined ordering
- users will need to allow the dex to access thier funds. They may not want to send ERC20 tokens directly, as it reveals information about thier txn, so the user will either need to give allowances to the DEX (which could also reveal information depending on how it's done) OR give custody of assets to the DEX entirely
- transactions may not "clear" if certain conditions that were true when the user submitted thier request are not true when the transaction is actually processed. The classic example would be if two users try to fill the same order. Only 1 will be able to
- transactions will not be processed in the order they come in. The logic of the protocol should be able to determine final state as well as whether transactions even "clear"
- the protocol will not be able to wait on a user to reveal and process thier own transactions. Ample time should be given for users to do so, as these transactions may cost significant gas. Consider allowing more blocks for processing than submission.
- consider limiting number of submissions per round in order to prevent the issue mentioned above

# DEX functionality

DEX's can be abstracted as an accounting ledger, managing values which represent balances of different accounts' different tokens. Any trade should modify 4 to 7 different values. In the following, assume that a trade is between token `BASE` and token `QUOTE`, and the users involved are `maker`, `taker`, and `exchange`. Assume that balances is a mapping of `address` and `tickerSymbol` to `uint`. Assume that the DEX may use a token `FEE` for fees:

1)  `balances[maker][BASE]`
2)  `balances[maker][QUOTE]`
3)  `balances[maker][FEE]`  (*optional*)
4)  `balances[taker][BASE]`
5)  `balances[taker][QUOTE]`
6)  `balances[taker][FEE]`   (*optional*)
7)  `balances[exchange][BASE]`  (*optional*)
8)  `balances[exchange][QUOTE]`   (*optional*)
9)  `balances[exchange][FEE]` (*optional*)

## Assumptions

- The DEX only functions via a "make order" and "take order" structure. There is no order-matching functionality built into the DEX. This allows us to search for interactions/effects via a single order index.

# Algoriddim

## Commit Stage

user sends in an encrypted call plus an anti-quitter stake and salt.
*optionally* if the stake is variable, user can send a stake within a predifined range
contract returns index of encrypted call.
encrypted call is saved to mapping of both index and roundNum.

## Reveal Stage

user reveals original, unencrypted hash of thier txn and salt, along with index assigned on commit
contract checks that roundNum for that index is accurate
contract checks anti-quitter stake to validate that is is correct. If not, transaction is cancelled and optionally all or some of quitter stake is refunded.
if not refunded, quitter stake is added to mapping assigned to this index/roundNum
totalQuitterStakes += this quitter stake

## Ordering reveal stage

This and the REVEAL stage should NOT be combined, as after the order-reveal stage is the cutoff for user reveals and initaites the beginning of the process stage. This stage is very short.

??? Should this stage come before reveal or after
  I think it should come after, because it prevents non-reveals due to users knowing thier transaction will be in a certain order

## Process Stage

The user calls to process thier claim. 
  if its to set a new order, 
    then the order and order ID are created and added to a mapping
    *optionally* pay exchange fee the make order fee 
  if its to fill an order,
    checks if the order has been filled by an "earlier" call
      if it has, cancel transaction
    else (order has NOT been filled by an EARLIER call)
      if order has been filled by a later call
        treat later caller as order maker, and this user sends funds/recieves funds to/from them. Effectively, this results in the "later" user's txn being reverted
        *optionally* send order fee to later caller (who should've paid exchange)
      else (order has not been filled period)
        send/recieve funds to/from maker
        *optionally* send exchange order fee
totalQuitterStakes -= anti-quitter stake
Refund the user their anti-quitter stake


## next-round stage
Contract owner kills process stake via some call
all balance changes are finalized
roundNum increments
totalQuitterStakes = 0
contract owner recieves totalQuitterStakes


