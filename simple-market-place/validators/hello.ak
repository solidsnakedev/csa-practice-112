use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{
  OutputReference, ScriptContext, Spend, Transaction, TransactionId,
}
use aiken/transaction/credential.{VerificationKey}

type Datum {
  owner: Hash<Blake2b_224, VerificationKey>,
}

type Redeemer {
  msg: ByteArray,
}

// aiken human readable -> serialise cbor -> deserialise uplc
// validator_uplc -> flat encoding -> cbor_bytestring(bytestring)
// cbor_bytestring(cbor_bytestring(bytestring))

// cbor
// - integer
// - string
// - bytestring
// - list
// ....

// onchain - 10%
// offchain - 30-40% -> side effects - blockchain - time - apis - user actions
// frontend
// backend

validator {
  fn hello_world(
    datum: Datum,
    redeemer: Redeemer,
    context: ScriptContext,
  ) -> Bool {
    let must_say_hello = redeemer.msg == "Hello, World!"
    let must_be_signed =
      list.has(context.transaction.extra_signatories, datum.owner)
    must_say_hello && must_be_signed
  }
}

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
  hello_world(datum, redeemer, context)
}
