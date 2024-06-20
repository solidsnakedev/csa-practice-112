use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction/credential.{Address, VerificationKey}

pub type SimpleSale {
  sellerAddress: Address,
  priceOfAsset: Int,
}

pub type MarketRedeemer {
  Buy
  Withdraw
}

pub type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>
