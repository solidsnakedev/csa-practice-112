use aiken/transaction.{ScriptContext}
use aiken/transaction/credential.{Address, VerificationKeyCredential}
use simplemarketplace_types_ryan.{Buy, MarketRedeemer, SimpleSale, Withdraw}
use simplemarketplace_utils_ryan.{buy_function, must_be_signed_by}

validator {
  fn mkmarket(
    dat: SimpleSale,
    action: MarketRedeemer,
    ctx: ScriptContext,
  ) -> Bool {
    expect VerificationKeyCredential(seller_pkh) =
      dat.sellerAddress.payment_credential

    when action is {
      Buy -> buy_function(ctx, dat.priceOfAsset, dat.sellerAddress)
      Withdraw -> must_be_signed_by(ctx.transaction, seller_pkh)
    }
  }
}
