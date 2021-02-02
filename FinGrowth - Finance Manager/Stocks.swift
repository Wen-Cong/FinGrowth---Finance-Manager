//
//  Stocks.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 27/1/21.
//

class Stocks{
    var id: String
    var name:String
    var symbol:String
    var quantity: Int
    var priceBought: Double
    var DateBought: String
    
    init(id:String, name:String, symbol:String, qty:Int, priceBought:Double, date:String) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.quantity = qty
        self.priceBought = priceBought
        self.DateBought = date
    }
}
