//
//  Transaction.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 27/1/21.
//

class Transaction{
    var transactionId: String
    var name:String
    var amount:Double
    var time: String
    var category: String
    var type: String
    var walletId: String
    
    init(name:String, amt:Double, time:String, cat:String, type:String, walletId: String) {
        self.transactionId = ""
        self.name = name
        self.amount = amt
        self.time = time
        self.category = cat
        self.type = type
        self.walletId = walletId
    }

    init(id:String, name:String, amt:Double, time:String, cat:String, type:String, walletId: String) {
        self.transactionId = id
        self.name = name
        self.amount = amt
        self.time = time
        self.category = cat
        self.type = type
        self.walletId = walletId
    }
    
}
