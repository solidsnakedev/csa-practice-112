use aiken/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, TransactionId,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{Value, ada_asset_name, ada_policy_id, from_asset}
use simplemarketplace_utils_ryan.{
  check_if_paid, datum_tagging_hash, own_input_own_output,
}

//************************** testing check_if_paid function *********************************************
test check_if_paid_test_pass() {
  let addr: Address = simplemarketplace_utils_ryan.create_address(#"acab", #"")
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 100)
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }
  check_if_paid([test_out], 100, addr)
}

test check_if_paid_test_fail_bad_value() fail {
  let addr: Address = simplemarketplace_utils_ryan.create_address(#"acab", #"")
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }

  check_if_paid([test_out], 100, addr)
}

test check_if_paid_test_fail_bad_addr() fail {
  let addr: Address = simplemarketplace_utils_ryan.create_address(#"deff", #"")
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }

  check_if_paid([test_out], 100, addr)
}

//*****************************************************************************************************
test ownin_ownout() {
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }

  let test_out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"aaaa" },
      output_index: 0,
    }
  let test_input: Input =
    Input { output_reference: test_out_ref, output: test_out }

  own_input_own_output([test_input], [test_out], test_out_ref)
}

test datum_tag_test() {
  let test_datum: ByteArray = #"acabbeeffacecafe"
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: InlineDatum(test_datum),
      reference_script: None,
    }

  let test_out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: #"acabbeeffacecafe" },
      output_index: 0,
    }
  datum_tagging_hash(test_out, test_out_ref)
}
