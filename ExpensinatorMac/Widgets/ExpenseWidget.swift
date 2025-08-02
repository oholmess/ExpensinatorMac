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
    @Binding var selectedExpenses: [Expense]
    @State private var sortOrder = [KeyPathComparator(\Expense.date, order: .reverse)]
    
    var body: some View {
        if expenses.isEmpty {
            noExpenses
        } else {
            List(expenses.sorted(using: sortOrder)) { expense in
                // Create a binding for isSelected that checks the presence of `expense` in `selectedExpenses`
                let isSelected = Binding<Bool>(
                    get: { selectedExpenses.contains(expense) },
                    set: { newValue in
                        if newValue {
                            // Add the expense if not already selected
                            if !selectedExpenses.contains(expense) {
                                selectedExpenses.append(expense)
                            }
                        } else {
                            // Remove the expense if now unchecked
                            selectedExpenses.removeAll { $0 == expense }
                        }
                    }
                )
                
                ExpenseRow(
                    expense: expense,
                    categoryName: categoryName(for: expense.categoryId),
                    isSelected: isSelected
                )
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
        @Binding var isSelected: Bool  // New binding for selection state
        
        var body: some View {
            HStack {
                // A checkbox or toggle
                Toggle(isOn: $isSelected) {
                    EmptyView()
                }
                .labelsHidden()
                .toggleStyle(CheckboxToggleStyle())
                .padding(.leading, 8)
                
                VStack(alignment: .leading) {
                    Text(truncateString(expense.description))
                        .font(.system(size: 20).bold())
                        .foregroundColor(CustomColor.EerieBlack)
                    
                    Text(expense.date, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundColor(CustomColor.EerieBlack.opacity(0.6))
                        .padding(.trailing)
                }
                .padding(.leading)
                
                Spacer()
                
                categoryBadge(for: categoryName)
                    .padding(.leading, 10)
                
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
                .font(.system(size: 14).bold())
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
    
    ExpensesList(expenses: sampleExpenses, categories: sampleCategories, selectedExpenses: .constant([]))
        .preferredColorScheme(.light)
}
