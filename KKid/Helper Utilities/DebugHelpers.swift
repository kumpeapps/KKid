//
//  DebugHelpers.swift
//  KKid
//
//  Created by Justin Kumpe on 9/15/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "This function is for debugging and development notes only. Please remove for final build.")
class DebugHelpers{
    
    
    static func logDocumentsUrl(){
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        Logger.log(.codeWarning, "App Document Directory is: \(urls[urls.count-1] as URL)")
    }
    
    static func dumpToLog(dump: Any){
        Logger.log(.codeWarning, dump)
    }
    
    static func dumpErrorToLog(dump: Any){
        Logger.log(.codeError, dump)
    }
    
    @available(*, deprecated, message: "Warning: This is a TODO Item")
    static func notImplementedBanner(){
        ShowAlert.banner(theme: .warning, title: "Not Implemented", message: "This feature is not yet implemented.")
    }
}
