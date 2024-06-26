use aiken/builtin.{serialise_data}
use aiken/bytearray
use aiken/hash.{blake2b_256}
use aiken/list
use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, ScriptContext, Spend, Transaction,
  find_script_outputs,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{Value, ada_asset_name, ada_policy_id, from_asset}
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
  let outputs: List<Output> = find_own_outputs(outputs, out_ref)
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

fn datum_tagging_hash(output: Output, out_ref: OutputReference) -> Bool {
  //************* todo:  ask question !!!!!!
  //  //should I use the blake2b function from the builtin or stdlib???
  // seems to me I should use the stdlib because it returns a hash<blake2b_356,a> 
  // whereas the builtin just return bytearry.  the jpg-store example uses the one from the builtin
  let datum_tag =
    out_ref
      |> serialise_data
      |> blake2b_256
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

// Get outputs to the script.
fn find_own_outputs(
  outputs: List<Output>,
  out_ref: OutputReference,
) -> List<Output> {
  //find the output based on the hash of the transaciton id hash
  let own_outputs = outputs |> find_script_outputs(out_ref.transaction_id.hash)
  own_outputs
}

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
