use aiken/builtin
use aiken/transaction.{
  InlineDatum, NoDatum, Output, OutputReference, ScriptContext, Spend,
  Transaction, TransactionId,
}
use aiken/transaction/value.{Value, ada_asset_name, ada_policy_id, from_asset}
use simplemarketplace_utils_ryan.{buy_function, datum_tagging_hash}

test datum_tag_test() {
  let out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"0000" },
      output_index: 0,
    }

  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum

  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: value.from_lovelace(200000),
      datum: datum_tag,
      reference_script: None,
    }

  datum_tagging_hash(test_out, out_ref)
}

test buy_function_test() {
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 100)

  let out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"0000" },
      output_index: 0,
    }

  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum

  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: datum_tag,
      reference_script: None,
    }

  let test_trans: Transaction =
    transaction.placeholder()
      |> fn(transaction) { Transaction { ..transaction, outputs: [test_out] } }

  let test_ctx: ScriptContext =
    ScriptContext { transaction: test_trans, purpose: Spend(out_ref) }

  buy_function(
    test_ctx,
    100,
    simplemarketplace_utils_ryan.create_address(#"acab", #""),
  )
}

test buy_function_test_bad_price() fail {
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 100)

  let out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"0000" },
      output_index: 0,
    }

  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum

  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: datum_tag,
      reference_script: None,
    }

  let test_trans: Transaction =
    transaction.placeholder()
      |> fn(transaction) { Transaction { ..transaction, outputs: [test_out] } }

  let test_ctx: ScriptContext =
    ScriptContext { transaction: test_trans, purpose: Spend(out_ref) }

  buy_function(
    test_ctx,
    300,
    simplemarketplace_utils_ryan.create_address(#"acab", #""),
  )
}

test buy_function_test_bad_addr() fail {
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 100)

  let out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"0000" },
      output_index: 0,
    }

  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum

  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: datum_tag,
      reference_script: None,
    }

  let test_trans: Transaction =
    transaction.placeholder()
      |> fn(transaction) { Transaction { ..transaction, outputs: [test_out] } }

  let test_ctx: ScriptContext =
    ScriptContext { transaction: test_trans, purpose: Spend(out_ref) }

  buy_function(
    test_ctx,
    100,
    simplemarketplace_utils_ryan.create_address(#"beef", #""),
  )
}

test buy_function_test_bad_datum() fail {
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 100)

  let out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"0000" },
      output_index: 0,
    }

  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }

  let test_trans: Transaction =
    transaction.placeholder()
      |> fn(transaction) { Transaction { ..transaction, outputs: [test_out] } }

  let test_ctx: ScriptContext =
    ScriptContext { transaction: test_trans, purpose: Spend(out_ref) }

  buy_function(
    test_ctx,
    100,
    simplemarketplace_utils_ryan.create_address(#"acab", #""),
  )
}

test buy_function_test_multiple_outputs() fail {
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 100)
  let out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"0000" },
      output_index: 0,
    }

  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum

  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: datum_tag,
      reference_script: None,
    }

  let test_out1: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: datum_tag,
      reference_script: None,
    }

  let test_trans: Transaction =
    transaction.placeholder()
      |> fn(transaction) {
          Transaction { ..transaction, outputs: [test_out, test_out1] }
        }

  let test_ctx: ScriptContext =
    ScriptContext { transaction: test_trans, purpose: Spend(out_ref) }

  buy_function(
    test_ctx,
    100,
    simplemarketplace_utils_ryan.create_address(#"acab", #""),
  )
}
