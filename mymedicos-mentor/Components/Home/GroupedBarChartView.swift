import UIKit
import Charts

class CubicLineChartView: UIView {
    
    private let lineChartView = LineChartView()
    private let filterSegmentedControl = UISegmentedControl(items: ["7 Days", "30 Days", "3 Months"])
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    
    private var currentStartDate: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupFilterSegmentedControl()
        setupLineChartView()
        setupNavigationButtons()
        setChartData(for: "7 Days") // Default to "7 Days"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupFilterSegmentedControl()
        setupLineChartView()
        setupNavigationButtons()
        setChartData(for: "7 Days") // Default to "7 Days"
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 10
    }
    
    private func setupFilterSegmentedControl() {
        filterSegmentedControl.selectedSegmentIndex = 0 // Default to "7 Days"
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSegmentedControl.backgroundColor = .systemGray5
        filterSegmentedControl.selectedSegmentTintColor = .systemBlue
        filterSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        filterSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        addSubview(filterSegmentedControl)
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterSegmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupLineChartView() {
        lineChartView.chartDescription.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.horizontalAlignment = .center
        lineChartView.legend.verticalAlignment = .top
        lineChartView.legend.orientation = .horizontal
        lineChartView.legend.drawInside = false
        lineChartView.extraTopOffset = 10
        
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.labelRotationAngle = -45
        xAxis.granularity = 1
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .semibold)
        xAxis.labelTextColor = .darkGray
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelTextColor = .darkGray
        
        addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 16),
            lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50) // Adjusted for button space
        ])
    }
    
    private func setupNavigationButtons() {
        previousButton.setTitle("← Previous", for: .normal)
        previousButton.addTarget(self, action: #selector(showPreviousData), for: .touchUpInside)
        
        nextButton.setTitle("Next →", for: .normal)
        nextButton.addTarget(self, action: #selector(showNextData), for: .touchUpInside)
        nextButton.isEnabled = false // Disable by default
        
        addSubview(previousButton)
        addSubview(nextButton)
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            previousButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            nextButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
    
    @objc private func filterChanged() {
        let selectedFilter = filterSegmentedControl.titleForSegment(at: filterSegmentedControl.selectedSegmentIndex)
        currentStartDate = Date() // Reset start date to today when changing filter
        setChartData(for: selectedFilter ?? "7 Days")
        nextButton.isEnabled = false // Disable 'Next' button on reset
    }
    
    @objc private func showPreviousData() {
        shiftCurrentDate(by: -1)
        nextButton.isEnabled = true // Enable 'Next' button if going back
    }
    
    @objc private func showNextData() {
        shiftCurrentDate(by: 1)
    }
    
    private func shiftCurrentDate(by offset: Int) {
        guard let selectedFilter = filterSegmentedControl.titleForSegment(at: filterSegmentedControl.selectedSegmentIndex) else { return }
        
        let calendar = Calendar.current
        let unit: Calendar.Component
        
        switch selectedFilter {
        case "7 Days":
            unit = .day
        case "30 Days":
            unit = .day
        case "3 Months":
            unit = .month
        default:
            return
        }
        
        currentStartDate = calendar.date(byAdding: unit, value: offset * (selectedFilter == "7 Days" ? 7 : (selectedFilter == "30 Days" ? 30 : 3)), to: currentStartDate ?? Date())
        
        // Update chart data
        setChartData(for: selectedFilter)
        
        // Disable 'Next' button if at today's date
        let isTodayInRange = calendar.isDateInToday(currentStartDate ?? Date())
        nextButton.isEnabled = !isTodayInRange
    }
    
    private func setChartData(for filter: String) {
        var dates: [String] = []
        var vanaspatiPrices: [Double]
        var palmOilPrices: [Double]
        var soybeanOilPrices: [Double]
        var sunflowerOilPrices: [Double]
        
        let calendar = Calendar.current
        let today = currentStartDate ?? Date()
        
        // Generate dates based on filter and currentStartDate
        // Set today's index
        var todayIndex: Int?
        
        switch filter {
        case "7 Days":
            for i in -6...0 {
                if let date = calendar.date(byAdding: .day, value: i, to: today) {
                    dates.append(dateString(from: date))
                    if calendar.isDate(date, inSameDayAs: Date()) {
                        todayIndex = dates.count - 1
                    }
                }
            }
            vanaspatiPrices = (1...7).map { _ in Double.random(in: 60...150) }
            palmOilPrices = (1...7).map { _ in Double.random(in: 50...140) }
            soybeanOilPrices = (1...7).map { _ in Double.random(in: 70...160) }
            sunflowerOilPrices = (1...7).map { _ in Double.random(in: 65...155) }
            
        case "30 Days":
            for i in stride(from: -29, through: 0, by: 1) {
                if let date = calendar.date(byAdding: .day, value: i, to: today) {
                    dates.append(dateString(from: date))
                    if calendar.isDate(date, inSameDayAs: Date()) {
                        todayIndex = dates.count - 1
                    }
                }
            }
            vanaspatiPrices = [120, 130, 125, 140, 115, 120, 135]
            palmOilPrices = [110, 115, 120, 130, 125, 110, 120]
            soybeanOilPrices = [140, 145, 150, 155, 160, 150, 155]
            sunflowerOilPrices = [135, 140, 145, 150, 130, 140, 145]
            
        case "3 Months":
            for i in stride(from: -2, through: 0, by: 1) {
                if let date = calendar.date(byAdding: .month, value: i, to: today) {
                    dates.append(dateString(from: date))
                    if calendar.isDate(date, inSameDayAs: Date()) {
                        todayIndex = dates.count - 1
                    }
                }
            }
            vanaspatiPrices = [400, 420, 410]
            palmOilPrices = [380, 390, 400]
            soybeanOilPrices = [420, 430, 440]
            sunflowerOilPrices = [410, 415, 425]
            
        default:
            dates = []
            vanaspatiPrices = []
            palmOilPrices = []
            soybeanOilPrices = []
            sunflowerOilPrices = []
        }
        
        let vanaspatiEntries = vanaspatiPrices.enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        let palmOilEntries = palmOilPrices.enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        let soybeanOilEntries = soybeanOilPrices.enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        let sunflowerOilEntries = sunflowerOilPrices.enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        
        let vanaspatiDataSet = LineChartDataSet(entries: vanaspatiEntries, label: "Vanaspati")
        styleDataSet(dataSet: vanaspatiDataSet, color: UIColor.systemRed, highlightIndex: todayIndex)
        
        let palmOilDataSet = LineChartDataSet(entries: palmOilEntries, label: "Palm Oil")
        styleDataSet(dataSet: palmOilDataSet, color: UIColor.systemBlue, highlightIndex: todayIndex)
        
        let soybeanOilDataSet = LineChartDataSet(entries: soybeanOilEntries, label: "Soybean Oil")
        styleDataSet(dataSet: soybeanOilDataSet, color: UIColor.systemYellow, highlightIndex: todayIndex)
        
        let sunflowerOilDataSet = LineChartDataSet(entries: sunflowerOilEntries, label: "Sunflower Oil")
        styleDataSet(dataSet: sunflowerOilDataSet, color: UIColor.systemTeal, highlightIndex: todayIndex)
        
        let data = LineChartData(dataSets: [vanaspatiDataSet, palmOilDataSet, soybeanOilDataSet, sunflowerOilDataSet])
        lineChartView.data = data
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        lineChartView.xAxis.setLabelCount(dates.count, force: false)
        lineChartView.notifyDataSetChanged()
    }
    
    private func styleDataSet(dataSet: LineChartDataSet, color: UIColor, highlightIndex: Int?) {
        dataSet.colors = [color]
        dataSet.circleColors = Array(repeating: color, count: dataSet.entryCount)
        dataSet.circleHoleColor = color
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier
        dataSet.drawFilledEnabled = true
        dataSet.fillAlpha = 0.3
        dataSet.fillColor = color.withAlphaComponent(0.3)
        
        if let index = highlightIndex, index < dataSet.circleColors.count {
            dataSet.circleColors[index] = .systemGreen
            dataSet.circleHoleColor = .systemGreen
            dataSet.highlightEnabled = true
            dataSet.highlightColor = .systemGreen
            lineChartView.highlightValue(x: Double(index), dataSetIndex: dataSetIndex(for: dataSet))
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func dataSetIndex(for dataSet: LineChartDataSet) -> Int {
        return lineChartView.data?.dataSets.firstIndex(where: { $0 as! NSObject == dataSet }) ?? 0
    }
}
