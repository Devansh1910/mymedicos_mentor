import SwiftUI
import FirebaseFirestore

struct ChatInterfaceView: View {
    let chatId: String
    let mentorName: String
    let userPhoneNumber: String

    @State private var messages: [MessageModel] = []
    @State private var messageText = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showCloseTicketAlert = false
    @State private var isTicketClosed = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient background
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the current view
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                Spacer()
                Text(mentorName)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()

                if !isTicketClosed {
                    Button(action: {
                        showCloseTicketAlert = true
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .alert(isPresented: $showCloseTicketAlert) {
                        Alert(
                            title: Text("Close Ticket"),
                            message: Text("Are you sure you want to close this ticket?"),
                            primaryButton: .destructive(Text("Close")) {
                                closeTicket()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [Color(UIColor(hex: "#2BD0BF")), Color(UIColor(hex: "#38F2DF"))]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)

            // Chat List
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: 16) {
                        // Group messages by day
                        let groupedMessages = Dictionary(grouping: messages) { message -> String in
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMMM d, yyyy"
                            return dateFormatter.string(from: message.time)
                        }

                        // Sort groups by date
                        let sortedKeys = groupedMessages.keys.sorted { key1, key2 in
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMMM d, yyyy"
                            guard let date1 = dateFormatter.date(from: key1),
                                  let date2 = dateFormatter.date(from: key2) else { return false }
                            return date1 < date2
                        }

                        ForEach(sortedKeys, id: \.self) { dateKey in
                            // Add a date divider
                            HStack {
                                Spacer()
                                Text(formatDateKey(dateKey))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                Spacer()
                            }

                            // Display messages for the day
                            ForEach(groupedMessages[dateKey] ?? []) { message in
                                // Extract content after the prefix
                                let messageContent = message.text.components(separatedBy: "/").last ?? message.text
                                MessageBubble(message: message.copyWith(newText: messageContent))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())

            // Bottom section: either message input or "Ticket is already closed"
            VStack {
                if isTicketClosed {
                    ClosedTicketBanner()
                } else {
                    // Input bar for sending messages
                    HStack(spacing: 12) {
                        TextField("Type a message...", text: $messageText)
                            .padding(14)
                            .background(Color(UIColor(hex: "#ffffff")))
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .padding(.leading, 8)

                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(UIColor(hex: "#2BD0BF")), Color(UIColor(hex: "#38F2DF"))]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(UIColor(hex: "#F2F2F7")))
        }
        .onAppear {
            fetchMessages() // Fetch messages when the view appears
            checkTicketStatus() // Check if the ticket is already closed
        }
    }

    /// Helper function to format the date key
    private func formatDateKey(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"

        let calendar = Calendar.current
        if let date = dateFormatter.date(from: dateString) {
            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            }
        }
        return dateString
    }

    /// Fetch messages from Firestore
    func fetchMessages() {
        let firestore = Firestore.firestore()
        firestore.collection("MentorChats")
            .document(userPhoneNumber)
            .collection(chatId)
            .order(by: "time", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No messages found.")
                    return
                }
                messages = documents.compactMap { document -> MessageModel? in
                    let data = document.data()
                    return MessageModel(
                        id: document.documentID,
                        text: data["message"] as? String ?? "",
                        sender: data["sender"] as? String ?? "",
                        time: (data["time"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
            }
    }

    /// Check if the ticket is already closed
    func checkTicketStatus() {
        let firestore = Firestore.firestore()
        firestore.collection("MentorChats").document(userPhoneNumber).getDocument { document, error in
            if let error = error {
                print("Error checking ticket status: \(error.localizedDescription)")
                return
            }
            guard let data = document?.data(),
                  let allArray = data["all"] as? [[String: Any]] else {
                return
            }
            if let chatData = allArray.first(where: { $0["id"] as? String == chatId }),
               let completed = chatData["completed"] as? Bool {
                DispatchQueue.main.async {
                    self.isTicketClosed = completed
                }
            }
        }
    }

    /// Handle closing the ticket
    func closeTicket() {
        let firestore = Firestore.firestore()
        firestore.collection("MentorChats").document(userPhoneNumber).getDocument { document, error in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            guard let data = document?.data(),
                  let allArray = data["all"] as? [[String: Any]] else { return }

            if let index = allArray.firstIndex(where: { $0["id"] as? String == chatId }) {
                var updatedArray = allArray
                var updatedChat = updatedArray[index]
                updatedChat["completed"] = true
                updatedArray[index] = updatedChat

                firestore.collection("MentorChats").document(userPhoneNumber).updateData([
                    "all": updatedArray
                ]) { error in
                    if let error = error {
                        print("Error updating ticket: \(error.localizedDescription)")
                    } else {
                        print("Ticket closed successfully in MentorChats.")
                        DispatchQueue.main.async {
                            self.isTicketClosed = true
                        }
                    }
                }
            }
        }
    }

    /// Send a message to Firestore
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let firestore = Firestore.firestore()
        let newMessage: [String: Any] = [
            "message": messageText,
            "sender": "user",
            "time": Date()
        ]
        firestore.collection("MentorChats")
            .document(userPhoneNumber)
            .collection(chatId)
            .addDocument(data: newMessage) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                    return
                }
                print("Message sent successfully")
                messageText = ""
            }
    }
}

// MARK: - Closed Ticket Banner View
struct ClosedTicketBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)

            Text("Ticket is already closed.")
                .foregroundColor(.gray)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor(hex: "#F2F2F7")))
        .cornerRadius(10)
    }
}

// MARK: - Message Bubble View
struct MessageBubble: View {
    let message: MessageModel
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack {
            if message.sender == "user" {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding()
                        .background(Color(UIColor(hex: "#2BD0BF")))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)

                    Text(dateFormatter.string(from: message.time))
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)

                    Text(dateFormatter.string(from: message.time))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 0)
    }
}

// MARK: - MessageModel Extension for Copying
extension MessageModel {
    func copyWith(newText: String) -> MessageModel {
        return MessageModel(id: self.id, text: newText, sender: self.sender, time: self.time)
    }
}


// Message model
struct MessageModel: Identifiable {
    var id: String
    var text: String
    var sender: String
    var time: Date
}

// UIColor extension for hex colors
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
