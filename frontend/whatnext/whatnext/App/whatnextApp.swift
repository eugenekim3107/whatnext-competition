
import SwiftUI
import Firebase
import GoogleSignIn

import SwiftUI

@main
struct whatnextApp: App {
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


      var body: some Scene {
        WindowGroup {
          NavigationView {
              LoadingView()
          }
        }
      }
}
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    if let clientID = FirebaseApp.app()?.options.clientID{
          let config = GIDConfiguration(clientID: clientID)
          GIDSignIn.sharedInstance.configuration = config
      }
      return true

  }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult{
        return .noData
    }
}
