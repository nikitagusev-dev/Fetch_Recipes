//
//  AppDelegate.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private var launcher: Launcher?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        launcher = Launcher(window: window)
        launcher?.launch()
        
        return true
    }
}
