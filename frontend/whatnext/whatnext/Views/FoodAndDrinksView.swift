import SwiftUI

struct FoodAndDrinksView: View {
    @StateObject var viewModel = PreferenceViewModel()
    @AppStorage("userID") var LoginuserID: String = ""
    let tagIconLinks: [String: String] = [
        "chinese": "🍜",
        "korean": "🍱",
        "italian": "🍕",
        "japanese": "🍣",
        "burgers": "🍔",
        "mexican": "🥙",
        "Hot Pot":"🫕",
        "Sushi":"🍣",
        "Tacos":"🌮",
        "coffee":"☕️"
    ]
    var activityTags = [(String, Bool)]()
    @State private var isSaveButtonDisabled = false
    var body: some View {
        
        VStack {
            SplitProgressBarView(leftProgress: 0, rightProgress: 1)
                .frame(height: 4)
                .padding(.vertical)
            Spacer().frame(height: 50)
            ZStack() {
              Text("Food & Drinks")
                .font(Font.custom("Inter", size: 34).weight(.semibold))
                .foregroundColor(.primary)
                .offset(x:0, y: -10)
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
                    ForEach(Array(viewModel.FDTags.enumerated()), id: \.element.0) { index, tag in
                        TagView(text: tag.0, isSelected: tag.1, icon: tagIconLinks[tag.0] ?? "")
                            .onTapGesture {
                                viewModel.toggleFDTagSelection(for: tag.0)
                            }
                        
                    }
                }
            }
            .onAppear {
                viewModel.fetchTags(userId:LoginuserID,activityAllTags:["shopping","spas","hiking","beaches","restaurant","yoga","aquariums","beautysvc","fitness"],foodAndDrinkAllTags: ["chinese","korean","japanese","italian","burgers","mexican","Hot Pot","Sushi","Tacos","coffee"])
            }
            
            Button(action: saveButtonAction) {
                 Text("Save")
                     .foregroundColor(isSaveButtonDisabled ? .gray : .white)
                     .frame(width: 295, height: 56)
                     .background(isSaveButtonDisabled ? Color.gray : Color.blue)
                     .cornerRadius(15)
             }
            .disabled(isSaveButtonDisabled)
            .padding(.bottom,50)
        }
    }
    private func saveButtonAction() {
        isSaveButtonDisabled = true
        viewModel.saveSelectionsToDatabase(userId: LoginuserID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSaveButtonDisabled = false
        }
    }
}


struct FoodAndDrinksView_Previews: PreviewProvider {
    static var previews: some View {
        FoodAndDrinksView()
    }
}
