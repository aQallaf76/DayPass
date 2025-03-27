//
//  SceneDelegate.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Create the SwiftUI view and set it as the root view
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            // Check if user is logged in
            if AuthManager.shared.isUserLoggedIn() {
                window.rootViewController = UIHostingController(rootView: MainTabView().environmentObject(AuthViewModel()))
            } else {
                window.rootViewController = UIHostingController(rootView: OnboardingView().environmentObject(AuthViewModel()))
            }
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when a scene is being released by the system
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when a scene has become active
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when a scene will resign active
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when a scene is about to enter the foreground
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when a scene has entered the background
    }
}
