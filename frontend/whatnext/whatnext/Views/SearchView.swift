import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme
    private let lineHeight: CGFloat = 16
    @State private var chatText = ""
    @State private var accumulatedText = ""
    @State private var messages: [ChatContent] = []
    @State private var timer: Bool = true
    @State private var waitingForResponse: Bool = false
    @State private var showPopup: Bool = false
    @State private var sessionId: String? = nil
    @State private var textEditorHeight: CGFloat = 36
    @FocusState private var isTextEditorFocused: Bool
    @AppStorage("userID") private var userID: String = ""

    var body: some View {
        NavigationView{
            VStack(spacing:0){
                messagesView
                    .navigationTitle("Search")
                    .navigationBarItems(trailing: refreshButton)
                    .overlay(
                        Group {
                            if showPopup {
                                Text("Please wait for response")
                                    .padding()
                                    .background(Color.gray.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .transition(.opacity)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            }
                        }
                    )
                    .onChange(of: timer) { newValue in
                        checkConditionsAndSendMessage()
                    }
                    .onChange(of: accumulatedText) { newValue in
                        checkConditionsAndSendMessage()
                    }
                    .onChange(of: chatText) { newValue in
                        checkConditionsAndSendMessage()
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                chatBottomBar
                    .background(Color(UIColor.systemGroupedBackground))
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea(.keyboard))
        }
    }
    
    // Define the refresh button view
    private var refreshButton: some View {
        Button(action: restartConversation ) {
            Text("New Chat")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(.orange)
                .cornerRadius(5)
        }
    }
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader {scrollView in
                    VStack (spacing: 10) {
                        if messages.isEmpty {
                            VStack (spacing: 3){
                                Spacer(minLength:50)
                                Image("logo-1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 90, height: 90)
                                Text("Let's find your next favorite spot!")
                                    .font(.headline)
                                Text("What are you in the mood for?")
                                    .font(.headline)
                                Image("openai-icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120, alignment: .top)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        ForEach(messages.indices, id: \.self) { index in
                            Group {
                                switch messages[index] {
                                case .message(let message):
                                    messageView(for: message)
                                case .messageSecondary(let messageSecondary):
                                    messageSecondaryView(for: messageSecondary)
                                }
                            }
                            .id(index)
                        }
                    }
                    .onChange(of: messages.count) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            scrollView.scrollTo(messages.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    enum ChatContent {
        case message(Message)
        case messageSecondary(MessageSecondary)
    }
    
    private func messageSecondaryView(for message: MessageSecondary) -> some View {
        HStack {
            InteractiveLocationView(locations: message.content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 50)
            Spacer()
        }
    }
    
    private func messageView(for message: Message) -> some View {
        Group {
            if message.chat_type == "typing" {
                TypingIndicatorView()
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 50)
            } else {
                HStack {
                    if message.is_user_message == "true" {
                        Spacer()
                        Text(message.content)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.leading, 50)
                    } else {
                        Text(message.content)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 50)
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var chatBottomBar: some View {
        ZStack() {
            GeometryReader { geometry in
                Text("Type your message here...")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                TextEditor(text: $chatText)
                    .padding(.horizontal, 5)
                    .colorMultiply(colorScheme == .dark ? .white : Color(UIColor.systemGroupedBackground))
                    .foregroundColor(.primary)
                    .frame(width: geometry.size.width-36, height:geometry.size.height)
                    .opacity(chatText.isEmpty ? 0.5:1)
                    .focused($isTextEditorFocused)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray)
                    .frame(width: geometry.size.width, height:geometry.size.height)
                if !chatText.isEmpty {
                    Button(action: {
                        if !waitingForResponse {
                            let newMessage = Message(
                                session_id: sessionId,
                                user_id: userID,
                                content: chatText,
                                chat_type: "regular",
                                is_user_message: "true"
                            )
                            messages.append(.message(newMessage))
                            appendText()
                        } else {
                            withAnimation {
                                showPopup = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showPopup = false
                                }
                            }
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    .position(x: geometry.size.width-18, y: geometry.size.height-18)
                    .transition(.scale)
                }
            }
        }
        .frame(height: textEditorHeight)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
//        .padding(.bottom, isTextEditorFocused ? 6 : 50)
        .padding(.bottom, isTextEditorFocused ? 50 : 50)
        .animation(.linear, value: isTextEditorFocused)
        .background(GeometryReader { geometry in
            Text(chatText)
                .lineLimit(nil)
                .padding(.horizontal, 19)
                .padding(.vertical, (23/3))
                .opacity(0)
                .frame(width: geometry.size.width - 36, height: .infinity, alignment: .leading)
                .background(GeometryReader { textGeometry in
                    Color.clear.preference(key: ViewHeightKey.self, value: textGeometry.size.height)
                })
        })
        .onPreferenceChange(ViewHeightKey.self) { newHeight in
            self.textEditorHeight = max(newHeight,36)
        }
    }
    
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    private func appendText() {
        accumulatedText.append(chatText + " ")
        chatText = ""
        resetTimer()
    }
    
    private func sendMessage() {
        let newMessage = Message(
            session_id: sessionId,
            user_id: userID,
            content: accumulatedText,
            chat_type: "regular",
            is_user_message: "true")
        timer = true
        waitingForResponse = true
        let typingIndicatorMessage = Message(session_id: sessionId, user_id: userID, content: "typingIndicator", chat_type: "typing", is_user_message: "false")
        messages.append(.message(typingIndicatorMessage))
        let latitude = 32.88088
        let longitude = -117.23790
        let userId = userID
        let message = newMessage.content
        
        ChatService.shared.postMessage(latitude: latitude, longitude: longitude, userId: userId, sessionId: sessionId, message: message) { result, error in
            DispatchQueue.main.async {
                self.messages.removeAll(where: {
                    if case .message(let msg) = $0, msg.chat_type == "typing" {
                        return true
                    }
                    return false
                })
            }
            if let error = error {
                print("Error: \(error)")
            } else if let result = result {
                switch result {
                case .regular(let message):
                    sessionId = message.session_id
                    messages.append(.message(message))
                    self.waitingForResponse = false
                    self.accumulatedText = ""
                case .secondary(let message):
                    messages.append(.messageSecondary(message))
                    let followUpContent = Message(
                        session_id: sessionId,
                        user_id: userID,
                        content: "Swipe through these handpicked spots and share your thoughts on them!",
                        chat_type: "regular",
                        is_user_message: "false"
                    )
                    messages.append(.message(followUpContent))
                    self.waitingForResponse = false
                    self.accumulatedText = ""
                }
            }
        }
    }
    
    private func resetTimer() {
        timer = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            timer = false
        }
    }
    
    private func checkConditionsAndSendMessage() {
        if !timer && !accumulatedText.isEmpty && chatText.isEmpty {
            sendMessage()
        }
    }
    
    private func restartConversation() {
        if !waitingForResponse {
            messages.removeAll()
            sessionId = nil
            accumulatedText = ""
            chatText = ""
            waitingForResponse = false
        } else {
            withAnimation {
                showPopup = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showPopup = false
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
