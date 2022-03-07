//
//  Logger.swift
//  Virtual Tourist
//
//  Created by Justin Kumpe on 8/23/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
// Copied Logger code from Lenda at https://stackoverflow.com/questions/40583721/print-to-console-log-with-color/41740104

#if canImport(ShipBookSDK)
import ShipBookSDK
#endif

public enum LogType: String {
    case error
    case warning
    case codeWarning
    case success
    case action
    case canceled
    case codeError
    case authentication
}

public class Logger {

public static func log(_ logType:LogType,_ message:Any) {
        switch logType {
        case LogType.error:
            print("\n📕 Error: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.e("\n📕 Error: \(message)\n")
            #endif
        case LogType.warning:
            print("\n📙 Warning: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.w("\n📙 Warning: \(message)\n")
            #endif
        case LogType.codeWarning:
            print("\n⚠️ Code Warning: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.d("\n⚠️ Code Warning: \(message)\n")
            #endif
        case LogType.success:
            print("\n📗 Success: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.i("\n📗 Success: \(message)\n")
            #endif
        case LogType.action:
            print("\n📘 Action: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.v("\n📘 Action: \(message)\n")
            #endif
        case LogType.canceled:
            print("\n📓 Cancelled: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.v("\n📓 Cancelled: \(message)\n")
            #endif
        case LogType.codeError:
            print("\n🛑 Code Error: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.d("\n🛑 Code Error: \(message)\n")
            #endif
        case LogType.authentication:
            print("\n🔐 Authentication: \(message)\n")
            #if canImport(ShipBookSDK)
            Log.v("\n🔐 Authentication: \(message)\n")
            #endif
        }
    }

}
