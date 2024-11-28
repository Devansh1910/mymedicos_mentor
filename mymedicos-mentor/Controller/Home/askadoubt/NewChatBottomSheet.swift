import SwiftUI
import FirebaseFirestore

struct NewChatBottomSheet: View {
    let category: String // Pass the selected specialty
    @Binding var isPresented: Bool // Binding to toggle the sheet visibility
    let userPhoneNumber: String // Pass the current user's phone number
    let mentorDetails: (id: String, name: String) = ("mentor2", "Subject matter expert") // Example mentor details
    var onChatCreated: (() -> Void)? // Completion handler to notify chat creation

    @State private var raisedText: String = "" // Input field for raising a doubt text
    @State private var showAlert: Bool = false // To show an alert
    @State private var alertMessage: String = "" // Message for the alert

    var body: some View {
        VStack(spacing: 0) {
            // Sheet header
            HStack {
                Text("New Chat - \(category)")
                    .font(.headline)
                Spacer()
                Button(action: {
                    isPresented = false // Close the sheet
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding()

            Divider()

            // New chat form or actions
            VStack(spacing: 12) {
                HStack {
                    // Prefix that is non-editable
                    Text("@\(category)/")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    // Editable input field for user's doubt/question
                    TextField("Type your question...", text: $raisedText)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                Button(action: {
                    validateAndStartChat()
                }) {
                    Text("Start Chat")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((raisedText.isEmpty ? Color.gray : Color.blue))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(raisedText.isEmpty) // Disable the button if no text is entered
            }
            .padding()

            Spacer()
        }
        .padding(.top)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.5) // Adjust height
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    /// Validate and start a new chat
    func validateAndStartChat() {
        let firestore = Firestore.firestore()
        let completeMessage = "@\(category)/\(raisedText)" // Concatenate the prefix with user input

        // Check for existing pending requests
        firestore.collection("MentorChatRequests")
            .whereField("user", isEqualTo: userPhoneNumber)
            .whereField("speciality", isEqualTo: category)
            .whereField("accepted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking for pending chats: \(error.localizedDescription)")
                    alertMessage = "An error occurred while checking for pending requests. Please try again."
                    showAlert = true
                    return
                }

                // If there are existing pending requests
                if let documents = snapshot?.documents, !documents.isEmpty {
                    let document = documents.first
                    if let timestamp = document?.data()["time"] as? Timestamp {
                        let timeSinceRequest = Date().timeIntervalSince(timestamp.dateValue())
                        if timeSinceRequest < 48 * 3600 { // Check if 48 hours have passed
                            alertMessage = "A pending request for \(category) already exists. You can retry after 48 hours."
                        } else {
                            alertMessage = "A previous request is still pending for \(category), but you can retry now."
                        }
                        showAlert = true
                    }
                } else {
                    // No pending request found, proceed to create a new chat
                    startNewChat(with: completeMessage)
                }
            }
    }

    /// Function to start a new chat and update Firestore
    func startNewChat(with message: String) {
        let firestore = Firestore.firestore()
        let newChatRef = firestore.collection("MentorChatRequests").document() // Auto-generate document ID
        let chatId = newChatRef.documentID // Get the generated document ID

        // Update MentorChatRequests
        let newChatData: [String: Any] = [
            "accepted": false,
            "acceptedBy": "none",
            "chatId": chatId, // Use the auto-generated document ID as the chatId
            "section": "PGNEET",
            "speciality": category,
            "user": userPhoneNumber, // Use the current user's phone number
            "time": Date() // Store the timestamp
        ]

        newChatRef.setData(newChatData) { error in
            if let error = error {
                print("Error creating new chat in MentorChatRequests: \(error.localizedDescription)")
                alertMessage = "An error occurred while creating the chat request. Please try again."
                showAlert = true
                return
            }
            print("New chat request created successfully in MentorChatRequests with chatId: \(chatId)")

            // Update MentorChats
            updateMentorChats(chatId: chatId, with: message)
        }
    }

    /// Function to update the MentorChats collection
    func updateMentorChats(chatId: String, with message: String) {
        let firestore = Firestore.firestore()
        let mentorChatsRef = firestore.collection("MentorChats").document(userPhoneNumber)

        mentorChatsRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching MentorChats document: \(error.localizedDescription)")
                alertMessage = "An error occurred while updating mentor chats. Please try again."
                showAlert = true
                return
            }

            if snapshot?.exists == true {
                // Update the existing document
                mentorChatsRef.updateData([
                    "all": FieldValue.arrayUnion([
                        [
                            "completed": false,
                            "id": chatId,
                            "mentor": [
                                "id": mentorDetails.id,
                                "name": mentorDetails.name
                            ],
                            "name": message
                        ]
                    ])
                ]) { error in
                    if let error = error {
                        print("Error updating MentorChats: \(error.localizedDescription)")
                        return
                    }
                    print("MentorChats updated successfully for existing user.")
                    addInitialMessageToChat(chatId: chatId, with: message) // Add the initial message
                }
            } else {
                // Create a new document
                mentorChatsRef.setData([
                    "all": [
                        [
                            "completed": false,
                            "id": chatId,
                            "mentor": [
                                "id": mentorDetails.id,
                                "name": mentorDetails.name
                            ],
                            "name": message
                        ]
                    ]
                ]) { error in
                    if let error = error {
                        print("Error creating MentorChats: \(error.localizedDescription)")
                        return
                    }
                    print("MentorChats created successfully for new user.")
                    addInitialMessageToChat(chatId: chatId, with: message) // Add the initial message
                }
            }
        }
    }

    /// Function to add the initial message in the chatId collection
    func addInitialMessageToChat(chatId: String, with message: String) {
        let firestore = Firestore.firestore()
        let chatCollectionRef = firestore.collection("MentorChats")
            .document(userPhoneNumber)
            .collection(chatId) // Create the collection for the chatId

        let initialMessage: [String: Any] = [
            "message": message,
            "sender": "user",
            "time": Date() // Current timestamp
        ]

        chatCollectionRef.addDocument(data: initialMessage) { error in
            if let error = error {
                print("Error adding initial message: \(error.localizedDescription)")
                return
            }
            print("Initial message added to chatId collection successfully.")
            isPresented = false // Dismiss the bottom sheet
            onChatCreated?() // Notify chat creation
        }
    }
}
