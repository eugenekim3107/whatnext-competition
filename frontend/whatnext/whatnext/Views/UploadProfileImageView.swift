import SwiftUI

struct UploadProfileImageView: View {
    var body: some View {
        VStack {
            ProgressBar(step:0.33).frame(height: 4).padding(.vertical)
            Spacer()
            Image(systemName:"person") // Replace with your image name
                .font(.system(size:90))
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))

                .padding(.top)
                Spacer()
                
            Button(action: {
                // Action for the camera button
            }) {
                Image(systemName: "camera") // Use the camera icon
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color:Color(red: 0.91, green: 0.90, blue: 0.92),radius: 1)
            }
            .padding(.top)

            Spacer()
        } // Adjust the size as needed

        .shadow(radius: 10)
    }
}

struct UploadProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        UploadProfileImageView()
    }
}

