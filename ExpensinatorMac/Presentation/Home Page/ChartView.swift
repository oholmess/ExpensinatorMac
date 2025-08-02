//
//  SpendingGraph.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/6/24.
//

import SwiftUI



struct ChartView: View {
    var expenses: [Expense]
    
    private let maxY: Double
    private let minY: Double
    private let lineColor: Color
    private let startingDate: Date
    private let endingDate: Date
    @State private var percentage: CGFloat = 0
    @State private var showCircle = false
    @State private var circleScale: CGFloat = 1.0
    // We'll store the position of the last data point.
    @State private var lastXPosition: CGFloat = 0
    @State private var lastYPosition: CGFloat = 0
    private let horizontalPadding: CGFloat = 20
    
    init(expenses: [Expense]) {
        self.expenses = expenses
        maxY = expenses.map { Double(truncating: $0.amount as NSNumber) }.max() ?? 0
        minY = expenses.map { Double(truncating: $0.amount as NSNumber) }.min() ?? 0
        lineColor = .white
        
        endingDate = Date(chartDate: expenses.map { $0.date }.max()?.description ?? "")
        startingDate = endingDate.addingTimeInterval(-60 * 60 * 24 * 7)
    }
    
    var body: some View {
        VStack {
            ZStack {
                chartView
                if showCircle {
                    circleAtEnd
                }
            }
            .frame(height: 150)
            
            chartDateLabels
        }
        .font(.caption)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 2)) {
                    percentage = 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation() {
                    showCircle = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    circleScale = 1.3
                }
            }
        }
    }
}

extension ChartView {
    

    
    private var chartView: some View {
        GeometryReader { geometry in
            // We'll calculate the path here and also track the last point
            Path { path in
                guard !expenses.isEmpty else { return }
                
                // Adjusted calculation to leave spacing on the sides
                // For N points, we distribute them evenly within (width - 2*horizontalPadding)
                // The first point starts at horizontalPadding, and the last point ends before the right edge.
                let count = expenses.count
                let width = geometry.size.width - (2 * horizontalPadding)
                let yAxis = maxY - minY
                
                for (index, expense) in expenses.enumerated() {
                    let xPosition = horizontalPadding + (width / CGFloat(count - 1)) * CGFloat(index)
                    let expenseValue = Double(truncating: expense.amount as NSNumber)
                    let yPosition = (1 - CGFloat((expenseValue - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    
                    // Track last point
                    if index == count - 1 {
                        // Store this in the state variables
                        DispatchQueue.main.async {
                            lastXPosition = xPosition
                            lastYPosition = yPosition
                        }
                    }
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .shadow(color: .white.opacity(0.8), radius: 8, x: 0, y: 10)
            .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 16)
            .shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 22)
        }
    }
    
    private var circleAtEnd: some View {
        GeometryReader { _ in
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .position(x: lastXPosition, y: lastYPosition)
                
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 10, height: 10)
                    .scaleEffect(circleScale)
                    .position(x: lastXPosition, y: lastYPosition)
                    .shadow(radius: 14)
                    .opacity(0.4)
            }
        }
    }
    
    private var chartDateLabels: some View {
        HStack {
            Text(startingDate.asShortDateString())
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(endingDate.asShortDateString())
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 8)
    }
}


#Preview {
    ChartView(expenses: generateExpenses())
}


private func generateExpenses() -> [Expense] {
    var expenses = [Expense]()
    let today = Date()
    for i in 0..<7 {
        let expense = Expense(expenseId: Int.random(in: 1...10000),
                              userId: 1,
                              amount: Decimal(Double.random(in: 10...100)),
                              categoryId: Int.random(in: 1...3),
                              description: "Expense \(i)",
                              receiptUrl: nil,
                              date: Calendar.current.date(byAdding: .day, value: -i, to: today)!)
        expenses.append(expense)
    }
    return expenses
}
