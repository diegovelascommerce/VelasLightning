

import LightningDevKit

var feerate_fast = 7500 // estimate fee rate in BTC/kB
var feerate_medium = 7500 // estimate fee rate in BTC/kB
var feerate_slow = 7500 // estimate fee rate in BTC/kB

/// What it is used for:  estimating fees for on-chain transactions
///
/// notes:
///   1. Fees must be returned in: satoshis per 1000 weight units
///   2. Fees returned must be no smaller than 253(equivalent to 1 satoshi)
///   3. To reduce network traffic, you may want to cache fee result rather than retrieveing
///      fresh ones every time
class MyFeeEstimator: FeeEstimator {
    
    override func get_est_sat_per_1000_weight(confirmation_target: LDKConfirmationTarget) -> UInt32 {
        if (confirmation_target as AnyObject === LDKConfirmationTarget_HighPriority as AnyObject) {
            print("LDK/FeeEstimator: \(UInt32(feerate_fast))")
            return UInt32(feerate_fast)
        }
        if (confirmation_target as AnyObject === LDKConfirmationTarget_Normal as AnyObject) {
            print("LDK/FeeEstimator: \(UInt32(feerate_medium))")
            return UInt32(feerate_medium)
        }
        print("LDK/FeeEstimator: \(UInt32(feerate_medium))")
        return UInt32(feerate_slow)
        //return 253
    }
    
}
