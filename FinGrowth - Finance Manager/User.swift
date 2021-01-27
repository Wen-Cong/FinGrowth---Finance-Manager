//
//  User.swift
//  FinGrowth - Finance Manager
//
//  Created by Yeo Wen Cong on 27/1/21.
//

class User{
    var username:String
    var dob:String
    var riskProfile: String
    
    init(username:String, dob:String, risk:String) {
        self.username = username
        self.dob = dob
        self.riskProfile = risk
    }
}
