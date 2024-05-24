//
//  LoginView.swift
//  SignIn
//
//  Created by Nicholas Lyu on 2/19/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    @StateObject var loginModel: LoginViewModel = .init()
    var body: some View {
        ZStack {
            Color(hex: "5BC0EB")
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical,showsIndicators: false){
                Spacer().frame(height:200)
                VStack(alignment:.center, spacing: 15) {
                    Image("logo-3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200,height: 200)
                        .padding(.bottom,-20)
                    Spacer().frame(height:2)
                    
                    HStack(spacing: 8){
                        
                        CustomButton(isGoogle: true)
                            .overlay {
                                
                                GoogleSignInButton{
                                    Task{
                                        do{
                                            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController())
                                            
                                            loginModel.logGoogleUser(user: result.user)
                                            
                                        }catch{
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                                .blendMode(.overlay)
                            }
                            .clipped()
                    }
                }
                .padding(.leading,30)
                .padding(.trailing,30)
                .padding(.vertical,10)
                .alert(loginModel.ErrorMessage,isPresented: $loginModel.showError){
                }
            }
        }
    }
        
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false)->some View{
        HStack{
            Group{
                if isGoogle{
                    Image("Google")
                        .resizable()
                        .renderingMode(.template)
                }else{
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .frame(height: 62)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign in")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal,15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}
        
    
struct LoginView_Previews:PreviewProvider{
        static var previews: some View{
            ContentView()
        }
}
