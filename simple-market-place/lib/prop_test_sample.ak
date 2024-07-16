use aiken/builtin
use aiken/bytearray
use aiken/fuzz.{and_then, bool, int, int_between, label, list_between, map}
use aiken/list
use aiken/string
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

test prop_int_between_distribution(n via int_between(-100, 100)) {
  // buckets(n, -100, 100, fn(n) { n + 25 })
  n >= -100 && n <= 100
}

test prop_int_between_large(
  n via int_between(0, 340_282_366_920_938_463_463_374_607_431_768_211_455),
) fail {
  n <= 18_446_744_073_709_551_615
}

test prop_bool_distribution(is_true via bool()) {
  label(
    if is_true {
      @"True"
    } else {
      @"False"
    },
  )

  True
}

test prop_list_distribution_small(xs via list_between(int(), 0, 10)) {
  let len = list.length(xs)
  buckets(len, 0, 11, fn(n) { n + 1 })
  len >= 0 && len <= 10
}

fn is_even(x: Int) -> Bool {
  x % 2 == 0
}

test prop_such_that(x via int()) {
  is_even(x)
}

// custom generator
fn list_at_least() -> Fuzzer<(Int, List<Int>)> {
  let min <- and_then(int_between(0, 10))
  let xs <- map(fuzz.list_at_least(int(), min))
  (min, xs)
}

test prop_list_at_least(params via list_at_least()) {
  let (min, xs) = params
  list.length(xs) >= min
}

fn bytearray_between() -> Fuzzer<(Int, Int, ByteArray)> {
  let min <- and_then(int_between(0, 50))
  let max <- and_then(int_between(min, 5 * min))
  let bytes <- map(fuzz.bytearray_between(min, max))
  (min, max, bytes)
}

test prop_bytearray_between(params via bytearray_between()) {
  let (min, max, bytes) = params

  let len = bytearray.length(bytes)

  let mid = ( min + max ) / 2

  label(
    if len < min {
      @"< min (impossible)"
    } else if len <= mid {
      @"<= mid (~50%)"
    } else if len <= max {
      @"<= max (~50%)"
    } else {
      @"> max (impossible)"
    },
  )

  len >= min && len <= max
}

/// A small function for automatically labelling a range of ints.
fn buckets(n, start, end, increment) -> Void {
  expect n >= start
  let next = increment(start)
  if next >= end {
    label(
      [string.from_int(start), @"->", string.from_int(end)]
        |> string.join(@" "),
    )
  } else if n < next {
    label(
      [string.from_int(start), @"->", string.from_int(next)]
        |> string.join(@" "),
    )
  } else {
    buckets(n, next, end, increment)
  }
}
