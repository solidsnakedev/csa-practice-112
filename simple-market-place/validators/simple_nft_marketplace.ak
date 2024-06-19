// homework
// code translation
// https://github.com/dQuadrant/cardano-marketplace/blob/main/marketplace-plutus/Plutus/Contracts/V2/SimpleMarketplace.hs

// {-# INLINABLE allScriptInputsCount #-}
// allScriptInputsCount:: ScriptContext ->Integer
// allScriptInputsCount ctx@(ScriptContext info purpose)=
//     foldl (\c txOutTx-> c + countTxOut txOutTx) 0 (txInfoInputs  info)
//   where
//   countTxOut (TxInInfo _ (TxOut addr _ _ _)) = case addr of { Address cre m_sc -> case cre of
//                                                               PubKeyCredential pkh -> 0
//                                                               ScriptCredential vh -> 1  } 

// data MarketRedeemer =  Buy | Withdraw
//     deriving (Generic,FromJSON,ToJSON,Show,Prelude.Eq)
// PlutusTx.makeIsDataIndexed ''MarketRedeemer [('Buy, 0), ('Withdraw,1)]

// data SimpleSale=SimpleSale{
//     sellerAddress:: Address, -- The main seller Note that we are using address 
//     priceOfAsset:: Integer  -- cost of the value in it
//   } deriving(Show,Generic)

// PlutusTx.makeIsDataIndexed ''SimpleSale [('SimpleSale, 0)]    

// {-# INLINABLE mkMarket #-}
// mkMarket ::  SimpleSale   -> MarketRedeemer -> ScriptContext    -> Bool
// mkMarket  ds@SimpleSale{sellerAddress,priceOfAsset}  action ctx =
//   case sellerPkh of 
//     Nothing -> traceError "Script Address in seller"
//     Just pkh -> case  action of
//         Buy       -> traceIfFalse "Multiple script inputs" (allScriptInputsCount  ctx == 1)  && 
//                      traceIfFalse "Seller not paid" (assetClassValueOf   (valuePaidTo info pkh) adaAsset >= priceOfAsset)
//         Withdraw -> traceIfFalse "Seller Signature Missing" $ txSignedBy info pkh

//     where
//       sellerPkh= case sellerAddress of { Address cre m_sc -> case cre of
//                                                            PubKeyCredential pkh -> Just pkh
//                                                            ScriptCredential vh -> Nothing  }
//       info  =  scriptContextTxInfo ctx
//       adaAsset=AssetClass (adaSymbol,adaToken )
