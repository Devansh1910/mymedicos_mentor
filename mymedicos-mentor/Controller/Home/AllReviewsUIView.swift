import UIKit
import FirebaseFirestore

class AllReviewsUIView: UIViewController {
    var reviews: [[String: Any]] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "All Reviews"

        // Register a custom UITableViewCell
        tableView.dataSource = self
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension AllReviewsUIView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        let review = reviews[indexPath.row]
        let studentName = review["studentname"] as? String ?? "Anonymous"
        let studentReview = review["studentreview"] as? String ?? "No review available"
        let rating = review["rating"] as? Int ?? 0
        let timestamp = review["date"] as? Timestamp
        let date = timestamp?.dateValue() ?? Date()

        // Configure the custom cell
        cell.configure(name: studentName, review: studentReview, rating: rating, date: date)
        return cell
    }
}
