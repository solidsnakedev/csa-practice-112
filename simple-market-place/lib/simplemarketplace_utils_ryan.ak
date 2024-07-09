use aiken/builtin
use aiken/bytearray
use aiken/list
use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, ScriptContext, Spend, Transaction,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{
  AssetName, PolicyId, Value, ada_asset_name, ada_policy_id, from_asset,
}
use simplemarketplace_types_ryan.{VerificationKeyHash}

pub fn buy_function(
  ctx: ScriptContext,
  price_asset: Int,
  seller_addr: Address,
) -> Bool {
  let ScriptContext { transaction, purpose } = ctx
  let Transaction { inputs, outputs, .. } = transaction
  expect Spend(out_ref) = purpose
  // using own input - own output to avoid "double satisfaction" problems
  own_input_own_output(inputs, outputs, out_ref) && check_if_paid(
    outputs,
    price_asset,
    seller_addr,
  )
}

//looking to make sure the value from the transaction is in the list of outputs
pub fn check_if_paid(
  outputs: List<Output>,
  price_asset: Int,
  addr: Address,
) -> Bool {
  //constructing value to look for in outputs
  let val: Value = from_asset(ada_policy_id, ada_asset_name, price_asset)
  let filteredlist =
    list.filter(
      outputs,
      fn(output) { output.value == val && output.address == addr },
    )
  list.length(filteredlist) == 1
}

pub fn own_input_own_output(
  inputs: List<Input>,
  outputs: List<Output>,
  out_ref: OutputReference,
) -> Bool {
  let input: Input = find_own_input(inputs, out_ref)
  let outputs: List<Output> = output_by_value(outputs, input.output.value)
  //find_own_outputs(outputs, out_ref)
  list.any(
    outputs,
    fn(output) {
      output.address == input.output.address && datum_tagging_hash(
        output,
        out_ref,
      )
    },
  )
}

pub fn datum_tagging_hash(output: Output, out_ref: OutputReference) -> Bool {
  //************* todo:  ask question !!!!!!
  //  //should I use the blake2b function from the builtin or stdlib???
  // seems to me I should use the stdlib because it returns a hash<blake2b_356,a> 
  // whereas the builtin just return bytearry.  the jpg-store example uses the one from the builtin
  let datum_tag =
    out_ref
      |> builtin.serialise_data
      |> builtin.blake2b_256
      |> InlineDatum

  output.datum == datum_tag
}

pub fn must_be_signed_by(
  transaction: Transaction,
  vk: VerificationKeyHash,
) -> Bool {
  list.has(transaction.extra_signatories, vk)
}

// Get input from the script.
fn find_own_input(inputs: List<Input>, out_ref: OutputReference) -> Input {
  //expect and input from the out_ref.
  expect Some(input) =
    inputs
      |> transaction.find_input(out_ref)

  input
}

// // Get outputs to the script.
// fn find_own_outputs(
//   outputs: List<Output>,
//   out_ref: OutputReference,
// ) -> List<Output> {
//   //find the output based on the hash of the transaciton id hash
//   let own_outputs = outputs |> transaction.find_script_outputs(out_ref.transaction_id.hash)
//   own_outputs
// }

pub fn create_address(
  pkh: VerificationKeyHash,
  sc: VerificationKeyHash,
) -> Address {
  // empty bytearrays means dont add the sc to the pkh
  if bytearray.is_empty(sc) {
    credential.from_verification_key(pkh)
  } else {
    credential.from_verification_key(pkh)
      |> credential.with_delegation_key(sc)
  }
}

/// Return the first occurrence of an output that contains at least some specific
/// value. If nothing is found then error. This function
/// does not search for an exact UTxO match.
///
/// ```aiken
/// find.output_by_value(tx.outputs, just_token_value)
/// ```
pub fn output_by_value(outputs: List<Output>, value: Value) -> List<Output> {
  list.filter(outputs, fn(output) { output.value == value })
}

/// Prove that the target value is contained inside another value. Each token
/// inside the target must exist inside the total value. The quantity of each
/// token must be at least the target amount or greater.
///
/// ```aiken
/// values.contains(total_value, target_value)
/// ```
pub fn contains(total: Value, target: Value) -> Bool {
  let flat: List<(PolicyId, AssetName, Int)> = value.flatten(target)
  do_contains(total, flat)
}

// Internal only
fn do_contains(total: Value, flat: List<(PolicyId, AssetName, Int)>) -> Bool {
  when flat is {
    [(pid, tkn, amt), ..rest] ->
      if value.quantity_of(total, pid, tkn) >= amt {
        do_contains(total, rest)
      } else {
        // something is missing
        False
      }
    // found all of them
    [] -> True
  }
}
