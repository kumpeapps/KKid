//
//  ShowAlert.swift
//  KKid
//
//  Created by Justin Kumpe on 8/17/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftMessages

/* MARK: ShowAlert
 Class to hold reusable UIAlerts
*/
class ShowAlert {

//    Display alert with OK Button
    @available(*, deprecated, message: "banner() or centerView() function is recommended")
    static func error(viewController: UIViewController, title: String, message: String) {
        // Ensure alert is called on Main incase it is called from background
        dispatchOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

//    Display alert with completion block
    static func alertDestructive(viewController: UIViewController, title: String, message: String, okButton: String = "Ok", cancelbutton: String = "Cancel", completion: @escaping (Bool) -> Void){
        dispatchOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okButton, style: .destructive, handler: {(alert: UIAlertAction!) in completion(true)}))
            alert.addAction(UIAlertAction(title: cancelbutton, style: .default, handler: {(alert: UIAlertAction!) in completion(false)}))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
//    Display Top Banner
    static func banner(theme: Theme = .error, title: String, message: String, seconds: Double = 10){
        dispatchOnMain{
            SwiftMessages.hideAll()
            let view = MessageView.viewFromNib(layout: .cardView)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .statusBar)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: seconds)
            config.dimMode = .gray(interactive: true)
            SwiftMessages.show(config: config, view: view)
        }
    }
    
//    Display Status Bar Banner
    static func statusLine(theme: Theme = .error, title: String, message: String, seconds: Double = 10, dim: Bool = true){
        dispatchOnMain{
            let view = MessageView.viewFromNib(layout: .statusLine)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: seconds)
            if dim{
                config.dimMode = .gray(interactive: true)
            }
            SwiftMessages.show(config: config, view: view)
        }
    }
    
//    Display Static Status Bar Banner
    static func statusLineStatic(id: String, theme: Theme = .error, title: String, message: String, blockInterface: Bool = false){
        dispatchOnMain{
            let view = MessageView.viewFromNib(layout: .statusLine)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .forever
            if blockInterface{
                config.dimMode = .gray(interactive: false)
            }
            view.id = id
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    
    
//    Dismisses Static Alert/Banner
    static func dismissStatic(id: String){
        dispatchOnMain {
            SwiftMessages.hide(id: id)
        }
    }
    
//    Display Center Banner
    static func centerView(theme: Theme = .error, title: String, message: String, seconds: Double = 10){
        dispatchOnMain{
            let view = MessageView.viewFromNib(layout: .centeredView)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: seconds)
            config.dimMode = .gray(interactive: true)
            SwiftMessages.show(config: config, view: view)
        }
    }
    
//    Display Message View Alert
    static func messageView(theme: Theme = .error, title: String, message: String, seconds: Double = 10){
        dispatchOnMain{
            SwiftMessages.hideAll()
            let view = MessageView.viewFromNib(layout: .messageView)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: seconds)
            config.dimMode = .gray(interactive: true)
            SwiftMessages.show(config: config, view: view)
        }
    }
    
//    Display banner with confirm button and completion closure
    static func choiceMessage(theme: Theme = .error, title: String, message: String, buttonTitle: String = "Confirm", completion: @escaping (Bool) -> Void){
        dispatchOnMain {
            SwiftMessages.hideAll()
            let view = MessageView.viewFromNib(layout: .messageView)
            var config = SwiftMessages.Config()
            view.configureTheme(theme)
            view.configureContent(title: title, body: message)
            view.button?.setTitle(buttonTitle, for: .normal)
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            view.buttonTapHandler = { _ in SwiftMessages.hide(); completion(true)}
            SwiftMessages.show(config: config, view: view)
            
        }
    }
    
}
