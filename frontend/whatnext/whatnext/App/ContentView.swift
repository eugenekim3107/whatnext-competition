import SwiftUI

struct ContentView: View {
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    
    
    var body: some View {
        if logStatus {
            AfterLoginView()
        } else {
            LoginView()
            
        }
    }
}

struct AfterLoginView: View {
    @State private var selectedTab = Tab.explore
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                MapView()
                    .edgesIgnoringSafeArea(.bottom)
                    .animation(nil, value: selectedTab)
                    .tag(Tab.map)
                
                SearchView()
                    .animation(nil, value: selectedTab)
                    .tag(Tab.search)
                
                ExploreView()
                    .animation(nil, value: selectedTab)
                    .tag(Tab.explore)
                
                ProfileView()
                    .animation(nil, value: selectedTab)
                    .tag(Tab.profile)
                
                MoreView()
                    .animation(nil, value: selectedTab)
                    .tag(Tab.more)
            }
            VStack {
                Spacer()
                TabBarView(selectedTab: $selectedTab)
                // Your custom TabBarView here
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
