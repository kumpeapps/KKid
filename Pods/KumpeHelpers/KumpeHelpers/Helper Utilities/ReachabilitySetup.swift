//
//  Reachability.swift
//  KKid
//
//  Created by Justin Kumpe on 9/24/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import Reachability

public class ReachabilitySetup{
    
//    MARK: Parameters
    public var isReachable: Bool = true
    public var reachability = try! Reachability(hostname: "api.kumpeapps.com")
    
    public init() {
        dispatchOnBackground {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(note:)), name: .reachabilityChanged, object: self.reachability)
            do{
                try self.reachability.startNotifier()
            }catch{
                Logger.log(.error, "could not start reachability notifier")
            }
        }
    }
    
    
    //    MARK: Reachability Changed
    //    Handles network connection issues
        @objc func reachabilityChanged(note: Notification) {
          let reachability = note.object as! Reachability

          switch reachability.connection {
          case .wifi:
            Logger.log(.success, "Reachability: Reachable via WiFi")
              ShowAlert.dismissStatic(id: "reachability")
          case .cellular:
            Logger.log(.success, "Reachability: Reachable via Cellular")
              ShowAlert.dismissStatic(id: "reachability")
          case .unavailable:
            Logger.log(.error, "Reachability: Network Unreachable")
            ShowAlert.statusLineStatic(id: "reachability", theme: .error, title: "Reachability Error", message: "Please check your internet connection!", blockInterface: false)
          case .none:
            Logger.log(.error, "Reachability: Error")
            ShowAlert.dismissStatic(id: "reachability")
            }
        }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
}
