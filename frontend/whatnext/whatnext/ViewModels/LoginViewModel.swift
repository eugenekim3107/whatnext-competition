//
//  LoginViewModel.swift
//  SignIn
//
//  Created by Nicholas Lyu on 2/19/24.
//

import SwiftUI
import Firebase
import CryptoKit
import AuthenticationServices
import GoogleSignIn

class LoginViewModel: ObservableObject {
    
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    @AppStorage("userID") var storedUserID: String = ""
    
    
    @Published var showError:Bool = false
    @Published var ErrorMessage: String = ""
    
    //App Login Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    //Apple Sign in properties
    @Published var nonce:String = ""
    
    
    // Firebase API
    func getOTPCode(){
        UIApplication.shared.closekeyboard()
        Task{
            do{
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+1\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body: {
                    CLIENT_CODE = code
                    withAnimation(.easeInOut){
                        showOTPField = true
                    }
                })
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    func VerifyOTPCode(){
        UIApplication.shared.closekeyboard()
        Task{
            do{
                let credential = PhoneAuthProvider.provider().credential(withVerificationID:CLIENT_CODE, verificationCode: otpCode)
                try await Auth.auth().signIn(with:credential)
                print("sucess")
                await MainActor.run(body:{
                    withAnimation(.easeInOut){
                        logStatus=true
                    }
                })
                
            }catch{
                await handleError(error: error)
            }
        }
        
    }
    // Logging Google User into Firebase
    func logGoogleUser(user: GIDGoogleUser){
        Task{
            do{
                guard let idToken = user.idToken else{return}
                let accesToken = user.accessToken
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accesToken.tokenString)
                
                try await Auth.auth().signIn(with: credential)
                
                guard let userID = Auth.auth().currentUser?.uid else {
                    return
                }
                
                await MainActor.run {
                    storedUserID = userID
                }

                await MainActor.run(body: {
                    withAnimation(.easeInOut){logStatus = true}
                })
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    
    
    // Apple SIgnin
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential){
        
        // getting Token....
        guard let token = credential.identityToken else{
            print("error with firebase")
            
            return
        }
        
        // Token String...
        guard let tokenString = String(data: token, encoding: .utf8) else{
            print("error with Token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString,rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            
            if let error = err{
                print(error.localizedDescription)
                return
            }
            
            // User Successfully Logged Into Firebase...
            print("Logged In Success")
            withAnimation(.easeInOut){
                self.logStatus=true
            }
        }
    }
    
    func handleError(error:Error)async{
        await MainActor.run(body: {
            ErrorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}


extension UIApplication{
    func closekeyboard(){
        sendAction(#selector(UIResponder.resignFirstResponder),to:nil,from:nil,for:nil)
    }
    
    func rootController()->UIViewController{
        guard let window = connectedScenes.first as? UIWindowScene else{return .init()}
        guard let viewcontroller = window.windows.last?.rootViewController else{return .init()}
        
        return viewcontroller
    }
}



func sha256(_ input: String) -> String {
 let inputData = Data(input.utf8)
 let hashedData = SHA256.hash(data: inputData)
 let hashString = hashedData.compactMap {
   return String(format: "%02x", $0)
 }.joined()

 return hashString
}

func randomNonceString(length: Int = 32) -> String {
 precondition(length > 0)
 let charset: Array<Character> =
     Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
 var result = ""
 var remainingLength = length

 while remainingLength > 0 {
   let randoms: [UInt8] = (0 ..< 16).map { _ in
     var random: UInt8 = 0
     let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
     if errorCode != errSecSuccess {
       fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
     }
     return random
   }

   randoms.forEach { random in
     if remainingLength == 0 {
       return
     }

     if random < charset.count {
       result.append(charset[Int(random)])
       remainingLength -= 1
     }
   }
 }

 return result
}
