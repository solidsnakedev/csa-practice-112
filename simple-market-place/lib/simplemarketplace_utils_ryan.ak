use aiken/bytearray
use aiken/list
use aiken/transaction.{
  Input, Output, ScriptContext, Spend, Transaction, find_script_outputs,
}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{Value, ada_asset_name, ada_policy_id, from_asset}
use simplemarketplace_types_ryan.{VerificationKeyHash}

pub fn buy_function(ctx: ScriptContext, price_asset: Int) -> Bool {
  // using own input - own output to avoid "double satisfaction" problems
  own_input_own_output(ctx) && check_if_paid(ctx, price_asset)
}

//looking to make sure the value from the transaction is in the list of outputs
pub fn check_if_paid(ctx: ScriptContext, price_asset: Int) -> Bool {
  //constructing value to look for in outputs
  let val: Value = from_asset(ada_policy_id, ada_asset_name, price_asset)
  list.any(ctx.transaction.outputs, fn(output) { output.value == val })
}

pub fn own_input_own_output(ctx: ScriptContext) -> Bool {
  let input: Input = find_own_input(ctx)
  let outputs: List<Output> = find_own_outputs(ctx)
  list.any(outputs, fn(output) { output.address == input.output.address })
}

pub fn must_be_signed_by(
  transaction: Transaction,
  vk: VerificationKeyHash,
) -> Bool {
  list.has(transaction.extra_signatories, vk)
}

// Get input from the script.
fn find_own_input(ctx: ScriptContext) -> Input {
  let ScriptContext { transaction, purpose } = ctx
  let Transaction { inputs, .. } = transaction

  //expect that it is a spend purpose with an out_ref
  expect Spend(out_ref) = purpose

  //expect and input from the out_ref.
  expect Some(input) =
    inputs
      |> transaction.find_input(out_ref)

  input
}

// Get outputs to the script.
fn find_own_outputs(ctx: ScriptContext) -> List<Output> {
  let ScriptContext { transaction, purpose } = ctx
  let Transaction { outputs, .. } = transaction

  //expect that it is a spend purpose with an out_ref
  expect Spend(out_ref) = purpose

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
