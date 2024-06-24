use aiken/transaction.{NoDatum, Output}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{Value, ada_asset_name, ada_policy_id, from_asset}
use simplemarketplace_utils_ryan.{check_if_paid}

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

  // let test_trans: Transaction =
  //   transaction.placeholder()
  //     |> fn(transaction) { Transaction { ..transaction, outputs: [test_out] } }
  // let test_out_ref: OutputReference =
  //   OutputReference {
  //     transaction_id: TransactionId { hash: #"aaaa" },
  //     output_index: 1,
  //   }
  // let test_ctx: ScriptContext =
  //   ScriptContext { transaction: test_trans, purpose: Spend(test_out_ref) }
  check_if_paid([test_out], 100, addr)
}

test check_if_paid_test_fail() fail {
  let addr: Address = simplemarketplace_utils_ryan.create_address(#"acab", #"")
  let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
  let test_out: Output =
    Output {
      address: simplemarketplace_utils_ryan.create_address(#"acab", #""),
      value: val,
      datum: NoDatum,
      reference_script: None,
    }

  // let test_trans: Transaction =
  //   transaction.placeholder()
  //     |> fn(transaction) { Transaction { ..transaction, outputs: [test_out] } }
  // let test_out_ref: OutputReference =
  //   OutputReference {
  //     transaction_id: TransactionId { hash: #"aaaa" },
  //     output_index: 1,
  //   }
  // let test_ctx: ScriptContext =
  //   ScriptContext { transaction: test_trans, purpose: Spend(test_out_ref) }
  check_if_paid([test_out], 100, addr)
}
//*****************************************************************************************************
// test ownin_ownout() {
//   let val: Value = from_asset(ada_policy_id, ada_asset_name, 500)
//   let test_out: Output =
//     Output {
//       address: simplemarketplace_utils.create_address(#"acab", #""),
//       value: val,
//       datum: InlineDatum(#""),
//       reference_script: None,
//     }

//   let test_out_ref: OutputReference = fake_tx.test_out_ref()

//   // OutputReference {
//   //   transaction_id: TransactionId { hash: #"aaaa" },
//   //   output_index: 1,
//   // }
//   let test_input: Input =
//     Input { output_reference: test_out_ref, output: test_out }

//   let test_trans1: Transaction =
//     transaction.placeholder()
//       |> fn(transaction) {
//           Transaction {
//             ..transaction,
//             inputs: [test_input],
//             reference_inputs: [],
//             outputs: [test_out],
//           }
//         }

//   //let test_trans = Transaction { inputs: [test_input] , reference_inputs: [], outputs: [test_out] , .. }
//   let test_ctx: ScriptContext =
//     ScriptContext { transaction: test_trans1, purpose: Spend(test_out_ref) }

//   own_input_own_output(test_ctx)
// }
