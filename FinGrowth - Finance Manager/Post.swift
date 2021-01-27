//
//  Post.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 27/1/21.
//

class Post{
    var title:String
    var image:String
    var description: String
    var stockSymbol: String
    var time: String
    var clues: String
    var userId: String
    var votes: Int
    
    init(title:String, image:String, description:String, symbol:String, time:String, clues:String, author: String, votes:Int) {
        self.title = title
        self.image = image
        self.description = description
        self.stockSymbol = symbol
        self.time = time
        self.clues = clues
        self.userId = author
        self.votes = votes
    }
}
