//
//  Velas.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 10/26/22.
//

public class Velas {
    
    private var btc:Bitcoin!
    private var ln:Lightning!
    
    public init() throws {
        btc = try Bitcoin()
        ln = Lightning()
    }
    
    
    public func sendAward(sats: Int) {
        print("sending a bolt11 invoice for \(sats)")
    }
}
