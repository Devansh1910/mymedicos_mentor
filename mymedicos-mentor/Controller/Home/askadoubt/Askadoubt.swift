import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatModel: Identifiable {
    var id = UUID()
    var profile: String
    var name: String
    var lastMessage: String
    var time: TimeInterval
    var speciality: String
    var mentorId: String?
    var mentorName: String?
    var chatId: String
    var isClosed: Bool
}

struct AskaDoubtPGView: View {
    @State private var chatData: [ChatModel] = []
    @State private var searchText = ""
    @State private var selectedChat: ChatModel?
    @State private var isSubjectSheetPresented = false
    @State private var isNewChatSheetPresented = false
    @State private var selectedCategory = ""
    @State private var selectedSegment = 0
    @State private var isLoading = true
    @State private var requestedChats: [ChatModel] = []
    @State private var showRequestPopup = false
    @State private var selectedRequest: ChatModel?

    
    let hardcodedPhoneNumber = Auth.auth().currentUser?.phoneNumber ?? "default"
    
    var filteredChats: [ChatModel] {
        switch selectedSegment {
        case 0: // Live
            return chatData.filter { !$0.isClosed }
        case 1: // Requested
            return requestedChats
        case 2: // Closed
            return chatData.filter { $0.isClosed }
        default:
            return []
        }
    }

    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    // Search Bar
                    HStack {
                        TextField("Search chats", text: $searchText)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        Button(action: {
                            isSubjectSheetPresented = true // Show the subject selection sheet
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(UIColor(hex: "#2BD0BF")))
                        }
                        .padding(.trailing, 16)
                    }
                    
                    // Segment Control
                    Picker("", selection: $selectedSegment) {
                        Text("Live").tag(0)
                        Text("Requested").tag(1)
                        Text("Closed").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    
                    // Chat List or Loader
                    if isLoading {
                        // Show loader while data is loading
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor(hex: "#2BD0BF"))))
                                .scaleEffect(2)
                                .padding()
                            Text("Loading tickets...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredChats.isEmpty {
                        // Show placeholder when no tickets are available
                        VStack(spacing: 16) {
                            Image(systemName: "ticket.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color(UIColor(hex: "#2BD0BF")))
                            
                            Text("No tickets available")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            Text("Click on the top '+' icon to create a new ticket.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Show chat list
                        List(filteredChats) { chat in
                            ChatRow(chat: chat,
                                   showRequestPopup: $showRequestPopup,
                                   selectedRequest: $selectedRequest)
                        }
                        .listStyle(PlainListStyle())

                        
                        if showRequestPopup, let request = selectedRequest {
                            ChatRequestPopup(
                                isPresented: $showRequestPopup,
                                userPhoneNumber: hardcodedPhoneNumber,
                                requestData: request
                            ) {
                                fetchChats()
                            }
                        }
                    }
                }
                .onAppear(perform: fetchChats)
                .fullScreenCover(item: $selectedChat) { chat in
                    ChatInterfaceView(chatId: chat.chatId, mentorName: chat.mentorName ?? "Mentor", userPhoneNumber: hardcodedPhoneNumber)
                }
                
                if isSubjectSheetPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isSubjectSheetPresented = false
                        }
                    
                    VStack {
                        Spacer()
                        SelectSubjectBottomSheetView(
                            isPresented: $isSubjectSheetPresented,
                            userPhoneNumber: hardcodedPhoneNumber,
                            onSubjectSelected: { selectedSubject in
                                selectedCategory = selectedSubject
                                isSubjectSheetPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isNewChatSheetPresented = true
                                }
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
                }
                
                if isNewChatSheetPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isNewChatSheetPresented = false
                        }
                    
                    VStack {
                        Spacer()
                        NewChatBottomSheet(
                            category: selectedCategory,
                            isPresented: $isNewChatSheetPresented,
                            userPhoneNumber: hardcodedPhoneNumber,
                            onChatCreated: {
                                fetchChats()
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
                }
            }
        }
    }
    
    func fetchChats() {
        isLoading = true
        let firestore = Firestore.firestore()
        let userPhoneNumber = hardcodedPhoneNumber
        
        print("Fetching chats for current user's phone number: \(userPhoneNumber)")
        
        firestore.collection("MentorChats")
            .document(userPhoneNumber)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    print("Error fetching live/closed chats: \(error?.localizedDescription ?? "Unknown error")")
                    self.chatData = [] // Clear chat data if error
                    self.isLoading = false
                    return
                }
                
                guard let allChats = data["all"] as? [[String: Any]] else {
                    print("No live or closed chats found.")
                    self.chatData = []
                    self.isLoading = false
                    return
                }
                
                var tempChatData: [ChatModel] = []
                
                for chat in allChats {
                    guard let chatId = chat["id"] as? String else { continue }
                    
                    let isClosed = chat["completed"] as? Bool ?? false
                    let mentor = chat["mentor"] as? [String: Any]
                    let mentorName = mentor?["name"] as? String ?? "Unknown"
                    let speciality = chat["name"] as? String ?? "Unknown"
                    
                    var chatModel = ChatModel(
                        profile: "profile_placeholder",
                        name: speciality,
                        lastMessage: "",
                        time: Date().timeIntervalSince1970,
                        speciality: speciality,
                        mentorId: mentor?["id"] as? String,
                        mentorName: mentorName,
                        chatId: chatId,
                        isClosed: isClosed
                    )
                    
                    firestore.collection("MentorChats")
                        .document(userPhoneNumber)
                        .collection(chatId)
                        .order(by: "time", descending: true)
                        .limit(to: 1)
                        .getDocuments { messageSnapshot, error in
                            if let lastMessageDocument = messageSnapshot?.documents.first {
                                chatModel.lastMessage = lastMessageDocument.data()["message"] as? String ?? ""
                            } else {
                                chatModel.lastMessage = "No messages yet."
                            }
                            
                            DispatchQueue.main.async {
                                if let index = tempChatData.firstIndex(where: { $0.chatId == chatId }) {
                                    tempChatData[index] = chatModel
                                } else {
                                    tempChatData.append(chatModel)
                                }
                                self.chatData = tempChatData.sorted { $0.time > $1.time }
                                self.isLoading = false // Stop loading
                            }
                        }
                }
            }
        
        firestore.collection("MentorChatRequests")
            .whereField("accepted", isEqualTo: false) // Only fetch unaccepted requests
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching requested chats: \(error?.localizedDescription ?? "Unknown error")")
                    self.requestedChats = [] // Clear requested chats if error
                    return
                }
                
                var tempRequestedChats: [ChatModel] = []
                
                for document in documents {
                    let data = document.data()
                    guard let chatId = data["chatId"] as? String,
                          let speciality = data["speciality"] as? String,
                          let time = (data["time"] as? Timestamp)?.dateValue(),
                          let mentor = data["mentor"] as? [String: Any],
                          let mentorId = mentor["id"] as? String,
                          mentorId == userPhoneNumber,
                          let mentorName = mentor["name"] as? String else { continue }
                    
                    let chatModel = ChatModel(
                        profile: "profile_placeholder",
                        name: speciality,
                        lastMessage: "Request Pending",
                        time: time.timeIntervalSince1970,
                        speciality: speciality,
                        mentorId: mentorId,
                        mentorName: mentorName,
                        chatId: chatId,
                        isClosed: false
                    )
                    
                    tempRequestedChats.append(chatModel)
                }
                
                DispatchQueue.main.async {
                    self.requestedChats = tempRequestedChats.sorted { $0.time > $1.time }
                }
            }
    }

}

struct ChatRequestPopup: View {
    @Binding var isPresented: Bool
    let userPhoneNumber: String
    let requestData: ChatModel
    let onAccept: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("New Request")
                    .font(.headline)
                    .padding(.top)
                
                Text("Would you like to confirm the request raised by \(requestData.mentorId ?? "User")?")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("No")
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        acceptRequest()
                    }) {
                        Text("Yes")
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color(UIColor(hex: "#2BD0BF")))
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom)
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
    }
    
    private func acceptRequest() {
        let firestore = Firestore.firestore()
        
        // Query to find the specific request document
        firestore.collection("MentorChatRequests")
            .whereField("chatId", isEqualTo: requestData.chatId)
            .getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    print("Request document not found")
                    return
                }
                
                // Update the request document
                document.reference.updateData([
                    "accepted": true,
                    "acceptedBy": userPhoneNumber
                ]) { error in
                    if let error = error {
                        print("Error updating request: \(error.localizedDescription)")
                        return
                    }
                    
                    print("Request accepted successfully")
                    onAccept()
                    isPresented = false
                }
            }
    }
}

// Update the ChatRow to handle request taps
struct ChatRow: View {
    let chat: ChatModel
    @Binding var showRequestPopup: Bool
    @Binding var selectedRequest: ChatModel?
    
    var formattedSpeciality: String {
        let components = chat.speciality.components(separatedBy: "/")
        if let specialityName = components.first {
            return specialityName.replacingOccurrences(of: "@", with: "")
        }
        return chat.speciality
    }
    
    var body: some View {
        Button(action: {
            if chat.lastMessage == "Request Pending" {
                selectedRequest = chat
                showRequestPopup = true
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(chat.isClosed ? Color.gray : Color(UIColor(hex: "#2BD0BF")))
                        .frame(width: 40, height: 40)
                    
                    Text(String(formattedSpeciality.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedSpeciality)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    if chat.lastMessage == "Request Pending" {
                        Text("New Request")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    } else {
                        Text(chat.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if chat.isClosed {
                    Text("Closed")
                        .font(.caption)
                        .foregroundColor(.red)
                } else if chat.lastMessage == "Request Pending" {
                    Text("Pending")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("Live")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 4)
        }
    }
}



struct SelectSubjectBottomSheetView: View {
    @Binding var isPresented: Bool
    let userPhoneNumber: String
    let onSubjectSelected: (String) -> Void

    @State private var disabledSubjects: [String: Date] = [:] // Track disabled subjects and their timestamps
    @State private var showAlert: Bool = false // To show an alert
    @State private var alertMessage: String = "" // Message for the alert

    let subjects = ["Anatomy", "Physiology", "Chemistry", "Orthopedics", "Radiology", "Pharmacology"]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Select a Subject")
                    .font(.headline)
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding()

            Divider()

            // Subject List
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(subjects, id: \.self) { subject in
                        Button(action: {
                            if let disabledTimestamp = disabledSubjects[subject] {
                                let timeIntervalSinceRequest = Date().timeIntervalSince(disabledTimestamp)
                                if timeIntervalSinceRequest < 48 * 3600 { // Check if 48 hours have passed
                                    alertMessage = "A pending request is already available for \(subject). Please wait or retry after 48 hours."
                                    showAlert = true
                                } else {
                                    // Allow retry after 48 hours
                                    onSubjectSelected(subject)
                                }
                            } else {
                                // Allow creating a new chat
                                onSubjectSelected(subject)
                            }
                        }) {
                            HStack {
                                Text(subject)
                                    .font(.headline)
                                    .foregroundColor(disabledSubjects.keys.contains(subject) ? .gray : .black)
                                    .lineLimit(1)
                                if let disabledTimestamp = disabledSubjects[subject] {
                                    let timeIntervalSinceRequest = Date().timeIntervalSince(disabledTimestamp)
                                    if timeIntervalSinceRequest < 48 * 3600 {
                                        Spacer()
                                        Text("Pending")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor(hex: "#F2F2F7")))
                            .cornerRadius(10)
                        }
                        .disabled(disabledSubjects.keys.contains(subject))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .background(Color.white)
        .onAppear(perform: checkPendingRequests) // Check for pending requests on appear
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    /// Check Firestore for pending requests for each subject
    func checkPendingRequests() {
        let firestore = Firestore.firestore()
        firestore.collection("MentorChatRequests")
            .whereField("user", isEqualTo: userPhoneNumber)
            .whereField("accepted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking pending requests: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }

                var tempDisabledSubjects: [String: Date] = [:]

                for document in documents {
                    let data = document.data()
                    if let speciality = data["speciality"] as? String,
                       let timestamp = data["time"] as? Timestamp {
                        let requestDate = timestamp.dateValue()
                        tempDisabledSubjects[speciality] = requestDate
                    }
                }

                DispatchQueue.main.async {
                    disabledSubjects = tempDisabledSubjects
                }
            }
    }
}
