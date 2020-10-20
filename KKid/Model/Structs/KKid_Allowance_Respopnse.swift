//
//  KKid_Allowance_Respopnse.swift
//  KKid
//
//  Created by Justin Kumpe on 9/18/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

struct KKid_AllowanceResponse: Codable {
    var status: Int
    let id: Int
    var balance: Float
    var lastUpdated: String
    var allowanceTransaction: [KKid_AllowanceTransaction]?
}

struct KKid_AllowanceTransaction: Codable {
    let transactionId: Int
    let userId: Int
    let transactionType: String
    var date: String
    var transactionDescription: String
    var amount: Float
}
