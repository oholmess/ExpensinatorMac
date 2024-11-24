//
//  ExpenseWidget.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import SwiftUI
struct ExpensesList: View {
    let expenses: [Expense]
    let categories: [Category]
    @State private var sortOrder = [KeyPathComparator(\Expense.createdAt, order: .reverse)]
    
    var body: some View {
        if expenses.isEmpty {
            noExpenses
        } else {
            List(expenses.sorted(using: sortOrder)) { expense in
                ExpenseRow(expense: expense, categoryName: categoryName(for: expense.categoryId))
            }
            .listStyle(PlainListStyle())
        }
    }
    
    @ViewBuilder
    var noExpenses: some View {
        VStack(spacing: 6) {
            Image("sleeping.robot")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()
                .padding(.top)
            
            Text("No expenses to see here")
                .font(.system(size: 20))
                .foregroundColor(CustomColor.EerieBlack)
            
            Text("When you add expenses, they will appear here. You can add expenses on the **manage** page.")
                .font(.system(size: 14))
                .foregroundColor(CustomColor.EerieBlack.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    private func categoryName(for categoryId: Int) -> String {
        categories.first(where: { $0.categoryId == categoryId })?.name ?? "Unknown"
    }
    
    struct ExpenseRow: View {
        let expense: Expense
        let categoryName: String
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(truncateString(self.expense.description)) // Use the resolved category name here
                        .font(.system(size: 20).bold())
                        .foregroundColor(CustomColor.EerieBlack)
                                    
                    categoryBadge(for: categoryName)
                    
                    Text(expense.date, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundColor(CustomColor.EerieBlack.opacity(0.6))
                        .padding(.trailing)
                    
                    
                }
                .padding(.leading)
                
                Spacer()
                
                Text("- \(expense.amount)€")
                    .font(.system(size: 14).bold())
                    .foregroundColor(CustomColor.red)
                    .padding(.trailing, 4)
            }
            .padding(.vertical, 4)
        }
        
        @ViewBuilder
        func categoryBadge(for categoryName: String) -> some View {
            Text(categoryName)
                .font(Font.custom("SF Pro Display", size: 14).weight(.bold))
                .foregroundColor(Color(red: 0.42, green: 0.6, blue: 0.31))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.42, green: 0.6, blue: 0.31).opacity(0.1))
                .cornerRadius(4)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 1)
        }
        
        func truncateString(_ string: String) -> String {
            if string.count > 30 {
                return String(string.prefix(30)) + "..."
            } else {
                return string
            }
        }
    }
}

#Preview {
    let sampleCategories = [
        Category(categoryId: 1, name: "Food"),
        Category(categoryId: 2, name: "Transportation"),
        Category(categoryId: 3, name: "Shopping")
    ]
    
    let sampleExpenses = [
        Expense(expenseId: 1, userId: 1, amount: 25.50, categoryId: 1, description: "Grocery shopping", date: Date()),
        Expense(expenseId: 2, userId: 1, amount: 15.00, categoryId: 2, description: "Taxi fare", date: Date())
    ]
    
    return ExpensesList(expenses: sampleExpenses, categories: sampleCategories)
        .preferredColorScheme(.light)
}
