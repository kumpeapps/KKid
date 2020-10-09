//
//  HomeViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 10/5/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
//    MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    
//    MARK: Collection View
    @IBOutlet weak var collectionView: UICollectionView!
    
//    MARK: Reachability
    var reachable: ReachabilitySetup!
    
//    MARK: Parameters
    var modules:[KKid_Module] = [KKid_Module.init(title: "Logout", segue: nil, icon: #imageLiteral(resourceName: "logout-1"))]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reachable = ReachabilitySetup()
        imageLogo.image = AppDelegate().kkidLogo
        imageBackground.image = AppDelegate().kkidBackground
        if LoggedInUser.user == nil{
            LoggedInUser.setLoggedInUser()
        }
        
        if LoggedInUser.selectedUser == nil{
            LoggedInUser.setSelectedToLoggedIn()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        verifyAuthenticated()
        modules = [KKid_Module.init(title: "Logout", segue: nil, icon: #imageLiteral(resourceName: "logout-1"))]
        buildModules()
        
    }
    
//    MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: "UserLastUpdated") == nil || !Calendar.current.isDateInToday(UserDefaults.standard.value(forKey: "UserLastUpdated") as! Date){
            KKidClient.getUsers { [self] (success, error) in
                LoggedInUser.setLoggedInUser()
                buildModules()
            }
        }
    }
    
    
//    MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        reachable = nil
    }
    
    
//    MARK: verifyAuthenticated
    @objc func verifyAuthenticated(){
        guard UserDefaults.standard.bool(forKey: "isAuthenticated") else{
            modules = [KKid_Module.init(title: "Logout", segue: nil, icon: #imageLiteral(resourceName: "logout-1"))]
            collectionView.reloadData()
            performSegue(withIdentifier: "segueLogin", sender: self)
            LoggedInUser.user = nil
            LoggedInUser.selectedUser = nil
            return
        }
    }
    
//    MARK: buildModules
    func buildModules(){
        if let selectedUser = LoggedInUser.selectedUser{
            if LoggedInUser.selectedUser == LoggedInUser.user{
                self.title = "\(selectedUser.emoji!) \(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
            }else{
                self.title = "Selected: \(selectedUser.emoji!) \(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
            }
            if selectedUser.enableChores{
                modules.append(KKid_Module.init(title: "Chores", segue: "segueChores", icon: #imageLiteral(resourceName: "chores")))
            }
            
            if selectedUser.enableAllowance{
                modules.append(KKid_Module.init(title: "Allowance", segue: "segueAllowance", icon: #imageLiteral(resourceName: "allowance")))
            }
            
            modules.append(KKid_Module.init(title: "Edit Profile", segue: "segueEditProfile", icon: #imageLiteral(resourceName: "profile")))
            
            if LoggedInUser.user!.isAdmin{
                modules.append(KKid_Module.init(title: "Select User", segue: "segueSelectUser", icon: #imageLiteral(resourceName: "select_user")))
            }
        }
        collectionView.reloadData()
    }
    
//    MARK: pressedLogout
    func pressedLogout(){
        
        KKidClient.logout(userInitiated: true)
    }
    
}


//MARK: - Collection View Functions
extension HomeViewController{
    
    //  MARK: Set Number of Items
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return modules.count
        }
        
    //    MARK: Build Items
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let module = modules[(indexPath as NSIndexPath).row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModuleCollectionViewCell
            cell.imageView.image = module.icon
            cell.title.text = module.title
            return cell
        }
        
    //    MARK: Did Select Item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let module = modules[indexPath.row]
            switch module.title {
            case "Logout":
                pressedLogout()
            default:
                performSegue(withIdentifier: module.segue!, sender: self)
            }
        }
}
