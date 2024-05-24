
//Created By Wenzhou Lyu
import SwiftUI

struct ProfileView: View {
    @StateObject var userViewModel = ProfileViewModel()
    @StateObject var friendModel = ProfileRowViewModel()
    @StateObject var favoritesModel = LocationRowViewModel()
    @StateObject var visitedModel = LocationRowViewModel()
    @AppStorage("userID") var LoginuserID: String = ""
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    UserInfoView(
                        viewModel: userViewModel,
                        userId: LoginuserID
                    )
                    ProfileRowView(
                        viewModel: friendModel,
                        title: "Friends",
                        userId: LoginuserID
                    )
                    FavoritesRowView(
                        viewModel: favoritesModel,
                        title: "Favorites",
                        userId: LoginuserID
                    )
                    VisitedRowView(
                        viewModel: visitedModel,
                        title: "Visited",
                        userId: LoginuserID
                    )
                }
                .navigationBarTitle("Profile", displayMode: .large)
                .padding(.bottom, 50)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .refreshable {
                userViewModel.refreshDataUserProfile(userId: LoginuserID)
                friendModel.refreshDataProfiles(userId: LoginuserID)
                favoritesModel.refreshDataFavorites(userId: LoginuserID)
                visitedModel.refreshDataVisited(userId:LoginuserID)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

