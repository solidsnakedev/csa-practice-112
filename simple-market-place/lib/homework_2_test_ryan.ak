use aiken/builtin
use aiken/fuzz.{and_then, map}
use aiken/list
use aiken/transaction.{
  InlineDatum, Output, OutputReference, ScriptContext, Spend, Transaction,
  TransactionId,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{Value, ada_asset_name, ada_policy_id}
use simplemarketplace_utils_ryan.{buy_function} as util

// ************ test the performance of find and filter *********************
test find_test() {
  let test_list =
    [1, 2, 3, 4, 5, 6, 7, 8, 9]
  expect Some(_) = list.find(test_list, fn(x) { x == 4 })
  True
}

test filter_test() {
  let test_list =
    [1, 2, 3, 4, 5, 6, 7, 8, 9]
  expect [_] = list.filter(test_list, fn(x) { x == 4 })
  True
}

// ┍━ homework_2_test_ryan ━━━━━━━━━━━━━━━━━━━━
//     │ PASS [mem: 21682, cpu:  7735879] find_test
//     │ PASS [mem: 42962, cpu: 15512516] filter_test

// **************************************************************************
// ************ generate random address and test ***************************
// **************************************************************************
// 1st attempt
fn generate_address_byte_array() -> Fuzzer<(ByteArray, ByteArray)> {
  let byte1 <- and_then(fuzz.bytearray_between(0, 100))
  let byte2 <- map(fuzz.bytearray_between(0, 100))
  (byte1, byte2)
}

// 2nd attempt after looking at anastasia labs aiken design patterns
fn generate_address() -> Fuzzer<Address> {
  let byte1 <- and_then(fuzz.bytearray_between(56, 56))
  let byte2 <- map(fuzz.bytearray_between(56, 56))
  let addr: Address = util.create_address(byte1, byte2)
  addr
}

test create_random_addr(params via generate_address_byte_array()) {
  let (b1, b2) = params
  // expect Address(_, _) = util.create_address(b1, b2)  **** doesn't work. gets warning!!!!!
  let Address(_, _) = util.create_address(b1, b2)
  True
}

// **************************************************************************
// ********* generate random outref and test ********************************
// ***************************************************************************
// 1st attempt
fn generate_outref_data() -> Fuzzer<(Int, ByteArray)> {
  let index <- and_then(fuzz.int_between(0, 10))
  let hash <- map(fuzz.bytearray_between(1, 50))
  (index, hash)
}

// 2nd attempt after looking at anastasia labs aiken design patterns
fn generate_outref() -> Fuzzer<OutputReference> {
  let index <- and_then(fuzz.int_between(1, 5))
  let hash <- map(fuzz.bytearray_between(64, 64))
  let out: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash },
      output_index: index,
    }

  out
}

test create_outref_test(params via generate_outref_data()) {
  let (index, hash) = params
  let out_ref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash },
      output_index: index,
    }
  // expect OutputReference(_, _) = out_ref   *** doesn't work.. get's warnings
  let OutputReference(_, _) = out_ref
  True
}

// **************************************************************************
// ********* generate token value and test ********************************
// ***************************************************************************

// fn generate_token_value() -> Fuzzer<Value> {
//   fuzz.map3(
//     fuzz.bytearray_between(56, 56),
//     fuzz.bytearray_between(1, 32),
//     fuzz.int_between(10, 100),
//     fn(pid, tn, qty) { value.from_asset(pid, tn, qty) },
//   )
// }

// **************************************************************************
// ********* test buy_function ********************************
// ***************************************************************************

type WholeCTX {
  value: Value,
  out_ref: OutputReference,
  addr: Address,
  out: Output,
}

fn generate_whole_thing() -> Fuzzer<WholeCTX> {
  fuzz.map3(
    fuzz.int_between(1, 100),
    //generate_token_value(),
    generate_outref(),
    generate_address(),
    fn(val, out_ref, addr) {
      let datum_tag =
        out_ref |> builtin.serialise_data |> builtin.blake2b_256 |> InlineDatum
      let outputs: Output =
        Output {
          address: addr,
          value: value.from_asset(ada_policy_id, ada_asset_name, val),
          datum: datum_tag,
          reference_script: None,
        }
      WholeCTX(
        value.from_asset(ada_policy_id, ada_asset_name, val),
        out_ref,
        addr,
        outputs,
      )
    },
  )
}

test buy_function_prop_test(param via generate_whole_thing()) {
  let WholeCTX { value, out_ref, addr, out } = param
  let test_trans: Transaction =
    transaction.placeholder()
      |> fn(transaction) { Transaction { ..transaction, outputs: [out] } }

  let test_ctx: ScriptContext =
    ScriptContext { transaction: test_trans, purpose: Spend(out_ref) }

  buy_function(test_ctx, value.lovelace_of(value), addr)
}
