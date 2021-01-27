//
//  Wallet.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 27/1/21.
//

class Wallet{
    var walletId: String
    var name:String
    var balance:Double
    var walletIcon: String
    var UserId: String
    
    init(name:String, bal:Double, icon:String, userId: String) {
        self.walletId = ""
        self.name = name
        self.balance = bal
        self.walletIcon = icon
        self.UserId = userId
    }
    
    init(walletId: String, name:String, bal:Double, icon:String, userId: String) {
        self.walletId = walletId
        self.name = name
        self.balance = bal
        self.walletIcon = icon
        self.UserId = userId
    }
}
