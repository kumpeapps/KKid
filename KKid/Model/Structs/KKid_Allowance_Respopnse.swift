//
//  KKid_Allowance_Respopnse.swift
//  KKid
//
//  Created by Justin Kumpe on 9/18/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

struct KKid_AllowanceResponse: Codable {
    var success: Bool
    var status: Int {
        return success ? 1: 0
    }
    let id: Int
    var balance: Float
    var lastUpdated: String
    var allowanceTransaction: [KKid_AllowanceTransaction]?

    enum CodingKeys: String, CodingKey {
        case success
        case id
        case balance
        case lastUpdated = "last_updated"
        case allowanceTransaction = "allowance_transaction"
    }
}

struct KKid_AllowanceTransaction: Codable {
    let transactionId: Int
    let userId: Int
    let transactionType: String
    var date: String
    var transactionDescription: String
    var amount: Float

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case userId = "user_id"
        case transactionType = "transaction_type"
        case date
        case transactionDescription = "transaction_description"
        case amount
    }
}
