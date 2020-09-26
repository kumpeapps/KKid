//
//  ChoresViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/2/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData

class ChoresViewController: UIViewController{
    
//    MARK: Parameters
    var selectedUser:User?
    
//    MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    
//    MARK: Table View
    @IBOutlet weak var tableView: UITableView!
        
    //    MARK: Reachability
        var reachable: ReachabilitySetup!
    
//    MARK: Buttons
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    
    
/*    MARK: Refresh Control
        Adds functionality to swipe down to refresh table
*/
    private let refreshControl = UIRefreshControl()
    
//    MARK: fetchedResultsController
    var fetchedResultsController:NSFetchedResultsController<Chore>!

//    MARK: setupFetchedResultsController
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Chore> = Chore.fetchRequest()
        let predicate = NSPredicate(format: "kid IN %@", [selectedUser!.username!,"any"])
        fetchRequest.predicate = predicate
        let sortByDayNumber = NSSortDescriptor(key: "dayAsNumber", ascending: true)
        let sortByChoreNumber = NSSortDescriptor(key: "choreNumber", ascending: true)
        fetchRequest.sortDescriptors = [sortByDayNumber, sortByChoreNumber]
            
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: "dayAsNumber", cacheName: nil)
        fetchedResultsController.delegate = self
            
        do {
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
//    MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
        setupFetchedResultsController()
        tableView.delegate = self
        tableView.dataSource = self
        imageLogo.image = AppDelegate().kkidLogo
        imageBackground.image = AppDelegate().kkidBackground
        buttonAdd.isEnabled = LoggedInUser.user!.isAdmin
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        verifyAuthenticated()
    }
    
//    MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: "ChoreLastUpdated") == nil || !Calendar.current.isDateInToday(UserDefaults.standard.value(forKey: "ChoreLastUpdated") as! Date){
            getChores()
        }
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.getChores), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Chore List")
        refreshControl.endRefreshing()
    }

    
//    MARK: viewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reachable = nil
        NotificationCenter.default.removeObserver(self)
        fetchedResultsController = nil
    }
    
//    MARK: verifyAuthenticated
    @objc func verifyAuthenticated(){
        KKidClient.verifyIsAuthenticated(self)
    }
    
//    MARK: getChores
    @objc func getChores() {
        KKidClient.getChores { (success, error) in
            Logger.log(.success, "getChores completed")
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
//    MARK: addChore
    @IBAction func addChore(){
        performSegue(withIdentifier: "segueAddChore", sender: self)
    }
    
//    MARK: prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMarkChore"{
            let viewController = segue.destination as! MarkChoreViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                viewController.chore = fetchedResultsController.object(at: indexPath)
                viewController.selectedUser = selectedUser!
            }
        }else if segue.identifier == "segueAddChore"{
            let viewController = segue.destination as! AddChoreViewController
            viewController.selectedUser = selectedUser
        }
    }
}

   // MARK: - Table View Delegates

extension ChoresViewController: UITableViewDataSource, UITableViewDelegate{

//    MARK: numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
//    MARK: tableView- section headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        if let sectionName = fetchedResultsController.sections?[section].name{
            switch sectionName {
            case "1":
                return "Sunday"
            case "2":
                return "Monday"
            case "3":
                return "Tuesday"
            case "4":
                return "Wednesday"
            case "5":
                return "Thursday"
            case "6":
                return "Friday"
            case "7":
                return "Saturday"
            default:
                return "Weekly"
            }
        }else{
            return "Weekly"
        }
    }

//    MARK: tableView: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

//    MARK: tableView: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aChore = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if aChore.optional{
            cell.textLabel?.text = "\(aChore.choreName ?? "") (\(aChore.day ?? "") Optional)"
        }else{
            cell.textLabel?.text = "\(aChore.choreName ?? "") (\(aChore.day ?? ""))"
        }
        
        if aChore.extraAllowance > 0.00{
            cell.detailTextLabel?.text = "[+$\(aChore.extraAllowance)] \(aChore.choreDescription ?? "")"
        }else{
            cell.detailTextLabel?.text = aChore.choreDescription ?? ""
        }
        cell.imageView?.image = ChoreStatus.init(rawValue: aChore.status!)?.image
        let itemSize = CGSize.init(width: 35, height: 25)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell.imageView?.image!.draw(in: imageRect)
        cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return cell
    }
    
//    MARK: tableView: editingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
//        If user is an admin then delete else show error
        if LoggedInUser.user!.isAdmin && editingStyle == .delete{
            let chore = fetchedResultsController.object(at: indexPath)
            KKidClient.deleteChore(chore.id) { (success, error) in
                if success{
                    DataController.shared.viewContext.delete(chore)
                    try? DataController.shared.viewContext.save()
                }else{
                    ShowAlert.banner(title: "Delete Error", message: "Unable to delete chore. Please try again.")
                }
            }
        }else{
            ShowAlert.banner(title: "Not Authorized", message: "Only Parents/Admins can delete chores!")
        }
    }
    
//    MARK: tableView: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aChore = fetchedResultsController.object(at: indexPath)
        
//        Block stolen chores unless user is an Admin. Else segue to mark chore unless chore is actually a calendar notation
        if !LoggedInUser.user!.isAdmin && aChore.stolenBy != nil && aChore.stolenBy! != ""{
            ShowAlert.banner(title: "Not Authorized", message: "Only Parents/Admins can edit an optional or stolen chore after it has already been marked off!")
        }else if !aChore.isCalendar{
            performSegue(withIdentifier: "segueMarkChore", sender: self)
        }
    }

}


// MARK: - NSFetchedResultsControllerDelegate

extension ChoresViewController:NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            tableView.setNeedsLayout()
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        @unknown default:
            break
        }
    }
    
}
