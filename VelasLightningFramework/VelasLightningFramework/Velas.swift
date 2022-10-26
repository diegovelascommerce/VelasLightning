
/// Main Class that projects will use to interact with Bitcoin and Lightning
public class Velas {
    
    private var btc:Bitcoin!
    private var ln:Lightning!
    
    /// Initialize Bitcoin and Lightning
    public init() throws {
        btc = try Bitcoin()
        ln = Lightning()
    }
    
    /// Create a bolt11 invoice from the amount of satoshis passed in.
    ///
    /// params:
    ///   amt: amount in satoshis
    /// return:
    ///   A bolt11 string of the invoice just created
    private func createBolt11(sats: Int) -> String {
        return "lntb10u1p34nzegpp5740edx88s2dq605hrmadncqjutwgp2qmp0tue3lx3x7v4csmex0sdqqcqzpgxq9zm3kqsp59fr9mzs0yaaccvgx9vq74j2pljyk98arcnj7zl6rq0evmhz96c9s9qyyssq98leckfmjeunhweuulf3mc3cgqy2c8962w4gy2x2qzanfv93gxn38f4fancp9jmkmlp306l7rk6vhgcptxatsx9t5heletnag5avq3gq7lm5p4"
    }
    
    
    public func sendAward(sats: Int, callback:(String)->Void) -> Void {
        let bolt11 = createBolt11(sats: sats);
        callback(bolt11);
    }
}
