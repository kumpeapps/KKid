//
//  AllowanceLedgerViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/20/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit


class AllowanceLedgerViewController: UITableViewController{
    
//    MARK: Parameters
    var allowanceTransactions: [KKid_AllowanceTransaction]!
    
//    MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        verifyAuthenticated()
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
    }
            
//    MARK: verifyAuthenticated
    @objc func verifyAuthenticated(){
        KKidClient.verifyIsAuthenticated(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

//    MARK: numberOfSections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

//    MARK: tableView: numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allowanceTransactions?.count ?? 0
    }

//    MARK: tableView: cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let aTransaction = allowanceTransactions![indexPath.row]
        var amount = "\(aTransaction.amount)"
        cell.detailTextLabel?.text = aTransaction.transactionDescription
        if aTransaction.amount < 0{
            //cell.backgroundColor = UIColor.systemPink
            amount.remove(at: amount.startIndex)
            cell.textLabel?.text = "\(aTransaction.date): -$\(amount)"
            cell.imageView?.image = UIImage(named: "minus")
        }else{
            //cell.backgroundColor = UIColor.green
            cell.textLabel?.text = "\(aTransaction.date): $\(amount)"
            cell.imageView?.image = UIImage(named: "plus")
        }
        return cell
    }
}
