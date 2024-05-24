import SwiftUI


struct ActivityView: View {
    @StateObject private var viewModel = PreferenceViewModel()
    @State private var navigationPath = NavigationPath()
//    @State private var isSaveButtonDisabled = false
    @AppStorage("userID") var LoginuserID: String = ""
    let tagIconLinks: [String: String] = [
        "shopping": "🍜",
        "spas": "💆‍♂️",
        "hiking": "⛰️",
        "beaches": "🏖️",
        "restaurant":"🍴",
        "yoga":"🧘",
        "aquariums":"🐠",
        "beautysvc":"💅",
        "fitness":"💪🏻"
    ]
    
    var body: some View {
        NavigationStack{
            VStack {
                SplitProgressBarView(leftProgress: 1, rightProgress: 0)
                    .frame(height: 4)
                    .padding(.vertical)
                
                HStack {
                    Spacer()
                    NavigationLink(destination: FoodAndDrinksView()) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                    }
                    
                }
                .padding(.horizontal,30)
                ZStack() {
                    Text("Activities")
                        .font(Font.custom("Inter", size: 34).weight(.semibold))
                        .foregroundColor(.primary)
                        .offset(x: -40, y: -10)
                    Text("Let us know your preferences.")
                        .font(Font.custom("Inter", size: 13))
                        .lineSpacing(19.50)
                        .foregroundColor(.primary.opacity(0.70))
                        .offset(x: -20, y: 25.50)
                }
                .frame(width: 295, height: 71)
                .padding(.leading,-80)
                .padding(.bottom,30)
                
                ScrollView {
                    let columns = [GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(viewModel.ACTags.enumerated()), id: \.element.0) { index, tag in
                            TagView(text: tag.0, isSelected: tag.1, icon: tagIconLinks[tag.0] ?? "")
                            .onTapGesture {
                                viewModel.toggleACTagSelection(for: tag.0)
                            }
                        }
                    }
                }
                .onAppear {
                viewModel.fetchTags(userId:LoginuserID,activityAllTags: ["shopping","spas","hiking","beaches","restaurant","yoga","aquariums","beautysvc","fitness"], foodAndDrinkAllTags: ["chinese","korean","japanese","italian","burgers","mexican","Hot Pot","Sushi","Tacos","coffee"])
                }
                Button(action: saveButtonAction) {
                    Text("Save")
                        .foregroundColor(/*isSaveButtonDisabled ? .gray :*/ .white)
                        .frame(width: 295, height: 56)
                        .background(/*isSaveButtonDisabled ? Color.gray :*/ Color.blue)
                        .cornerRadius(15)
                }
//                .disabled(isSaveButtonDisabled)
                .padding(.bottom,50)
            }
            .padding(.horizontal)

        }
    }
    private func saveButtonAction() {
//        isSaveButtonDisabled = true
        viewModel.saveSelectionsToDatabase(userId: LoginuserID)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.isSaveButtonDisabled = false
//        }
    }
}


struct ProgressBar: View {
    var step: Double
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: 10)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: geometry.size.width * step, height: 10)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear, value: 0.5)
            }
            .cornerRadius(45.0)
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
