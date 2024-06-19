use aiken/list
use aiken/transaction.{ScriptContext}
use hello_types_ryan.{Datum, Redeemer}

pub fn hello_world_func(
  datum: Datum,
  redeemer: Redeemer,
  context: ScriptContext,
) -> Bool {
  let must_say_hello = redeemer.msg == "Hello, World!"
  let must_be_signed =
    list.has(context.transaction.extra_signatories, datum.owner)
  must_say_hello && must_be_signed
}
