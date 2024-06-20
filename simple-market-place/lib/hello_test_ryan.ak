use aiken/transaction.{
  OutputReference, ScriptContext, Spend, Transaction, TransactionId,
}
use hello_types_ryan.{Datum, Redeemer}
use hello_util_ryan.{hello_world_func}

// ...rest of the code is unchanged
test hello_world_example() {
  let datum =
    Datum { owner: #"00000000000000000000000000000000000000000000000000000000" }
  let redeemer = Redeemer { msg: "Hello, World!" }
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }
  let context =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: transaction.placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, extra_signatories: [datum.owner] }
          },
    }
  hello_world_func(datum, redeemer, context)
}
