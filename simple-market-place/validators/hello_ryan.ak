use aiken/transaction.{ScriptContext}
use hello_types_ryan.{Datum, Redeemer}
use hello_util_ryan.{hello_world_func}

validator {
  fn hello_world(
    datum: Datum,
    redeemer: Redeemer,
    context: ScriptContext,
  ) -> Bool {
    hello_world_func(datum, redeemer, context)
  }
}
