

import LightningDevKit

var feerate_fast = 7500
var feerate_medium = 1000
var feerate_slow = 253 

class MyFeeEstimator: FeeEstimator {
    
    override func getEstSatPer_1000Weight(confirmationTarget: Bindings.ConfirmationTarget) -> UInt32 {
//        if (confirmationTarget as AnyObject === LDKConfirmationTarget_HighPriority as AnyObject) {
//            print("LDK/FeeEstimator: \(UInt32(feerate_fast))")
//            return UInt32(feerate_fast)
//        }
//        if (confirmationTarget as AnyObject === LDKConfirmationTarget_Normal as AnyObject) {
//            print("LDK/FeeEstimator: \(UInt32(feerate_medium))")
//            return UInt32(feerate_medium)
//        }
        return UInt32(feerate_medium)
    }
    
}
