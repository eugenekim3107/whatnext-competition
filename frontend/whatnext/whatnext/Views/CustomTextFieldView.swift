//
//  CustomTextFieldView.swift
//  SignIn
//
//  Created by Nicholas Lyu on 2/19/24.
//

import SwiftUI

struct CustomTextFieldView: View {
    @Binding var text:String
    var hint:String
    var contentType:UITextContentType = .telephoneNumber
    @FocusState var isEnabled:Bool
    var body:some View{
        VStack(alignment: .leading, spacing:15) {
            TextField(hint,text:$text)
                .keyboardType(.numberPad)
                .textContentType(contentType)
                .focused($isEnabled)
            
            ZStack(alignment: .leading){
                Rectangle().fill(.black.opacity(0.2))
                
                Rectangle()
                    .fill(.black)
                    .frame(width: isEnabled ? nil:0)
                    .animation(.easeInOut(duration: 0.3),value:isEnabled)
            }
            .frame(height:2)
            
                
            
        }
        
    }
}

struct CustonTextFieldView_Previews:PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
