//
//  Logger.swift
//  Virtual Tourist
//
//  Created by Justin Kumpe on 8/23/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
// Copied Logger code from Lenda at https://stackoverflow.com/questions/40583721/print-to-console-log-with-color/41740104

public enum LogType: String{
    case error
    case warning
    case codeWarning
    case success
    case action
    case canceled
    case codeError
    case authentication
}


public class Logger{

 public static func log(_ logType:LogType,_ message:Any){
        switch logType {
            case LogType.error:
                print("\n📕 Error: \(message)\n")
            case LogType.warning:
                print("\n📙 Warning: \(message)\n")
            case LogType.codeWarning:
                print("\n⚠️ Code Warning: \(message)\n")
            case LogType.success:
                print("\n📗 Success: \(message)\n")
            case LogType.action:
                print("\n📘 Action: \(message)\n")
            case LogType.canceled:
                print("\n📓 Cancelled: \(message)\n")
            case LogType.codeError:
                print("\n🛑 Code Error: \(message)\n")
            case LogType.authentication:
                print("\n🔐 Authentication: \(message)\n")
        }
    }

}
