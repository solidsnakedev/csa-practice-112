use aiken/builtin
use aiken/fuzz.{int, label}
use aiken/transaction.{
  InlineDatum, NoDatum, Output, OutputReference, TransactionId,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{Value, ada_asset_name, ada_policy_id, from_asset}
use simplemarketplace_utils_ryan.{check_if_paid, datum_tagging_hash}

//************************** testing check_if_paid function *********************************************
test check_if_paid_test_pass() {
  let addr: Address = simplemarketplace_utils_ryan.create_address(#"acab", #"")
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 100)
  let out_ref =
    OutputReference { transaction_id: TransactionId(#"acab"), output_index: 2 }
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
  check_if_paid([test_out], 100, addr, datum_tag)
}

test check_if_paid_test_fail_bad_value() fail {
  let addr: Address = simplemarketplace_utils_ryan.create_address(#"acab", #"")
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
  let out_ref =
    OutputReference { transaction_id: TransactionId(#"acab"), output_index: 2 }
  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }

  check_if_paid([test_out], 100, addr, datum_tag)
}

test check_if_paid_test_fail_bad_addr() fail {
  let addr: Address = simplemarketplace_utils_ryan.create_address(#"deff", #"")
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
  let out_ref =
    OutputReference { transaction_id: TransactionId(#"acab"), output_index: 2 }
  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }

  check_if_paid([test_out], 100, addr, datum_tag)
}

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

//*****************************************************************************************************
// test ownin_ownout_test() {
//   let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)

//   let out_ref: OutputReference =
//     OutputReference {
//       transaction_id: TransactionId { hash: #"0000" },
//       output_index: 0,
//     }

//   let datum_tag =
//     out_ref
//       |> builtin.serialise_data
//       |> builtin.blake2b_256
//       |> InlineDatum

//   let test_out: Output =
//     Output {
//       address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
//       value: val,
//       datum: datum_tag,
//       reference_script: None,
//     }

//   let test_input: Input = Input { output_reference: out_ref, output: test_out }

//   own_input_own_output([test_input], [test_out], out_ref)
// }

test prop_int_distribution(n via int()) {
  label(
    if n < -255 {
      fail @"n < -max_u8"
    } else if n < 0 {
      @"[-255; 0["
    } else if n == 0 {
      @"0"
    } else if n < 256 {
      @"]0; 255]"
    } else if n < 16383 {
      @"[256; 16383]"
    } else {
      fail @"n > 16383"
    },
  )

  True
}
