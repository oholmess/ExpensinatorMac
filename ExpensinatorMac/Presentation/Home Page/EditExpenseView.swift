//
//  EditExpenseView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/6/24.
//

import SwiftUI

struct EditExpenseView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @State var vm: HomePageViewModel
    
    @State var newExpenses: [Expense] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if vm.isLoading {
                    ZStack {
                        Color.black.opacity(0.1)
                        Spinner()
                    }
                } else {
                    List {
                        switch horizontalSizeClass {
                        case .regular: regularView
                        default: compactView
                            
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Confirmation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        Task {
                            await vm.saveEditedExpenses(oldExpenseIDs: vm.selectedExpenses.map {
                                $0.expenseId ?? 0 }, newExpenses: newExpenses)
                        }
                        if !vm.isLoading {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("Selected expenses: \(vm.selectedExpenses)")
            newExpenses = vm.selectedExpenses
        }
    }
    
    var regularView: some View {
        ForEach($newExpenses, id: \.id) { expense in
            HStack(spacing: 16) {
                HStack {
                    Text("Description:")
                        .frame(maxWidth: 76, alignment: .leading)
                    descriptionTextField(expense: expense)
                }
                
                HStack {
                    Text("Amount:")
                        .frame(maxWidth: 72, alignment: .leading)
                    amountTextField(expense: expense)
                }
                
                HStack {
                    Text("Category:")
                        .frame(maxWidth: 72, alignment: .leading)
                    Spacer()
                    categoryPicker(expense: expense)
                }
                
                Spacer()
                
                HStack {
                    DatePicker(selection: expense.date, displayedComponents: [.date]) {
                        Text("Date:")
                    }
                }
            }
        }
        .onDelete(perform: onDelete)
    }
    
    var compactView: some View {
        ForEach($newExpenses, id: \.id) { expense in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Description:")
                        .frame(maxWidth: 72, alignment: .leading)
                    Spacer()
                    descriptionTextField(expense: expense)
                }
                
                HStack {
                    Text("Amount:")
                        .frame(maxWidth: 72, alignment: .leading)
                    Spacer()
                    amountTextField(expense: expense)
                }
                
                HStack {
                    Text("Category:")
                        .frame(maxWidth: 72, alignment: .leading)
                    Spacer()
                    categoryPicker(expense: expense)
                }
            }
        }
        .onDelete(perform: onDelete)
    }
    
    func descriptionTextField(expense: Binding<Expense>) -> some View {
        TextField(text: expense.description, label: {
            Text("Description")
        })
        .lineLimit(2)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    
    func amountTextField(expense: Binding<Expense>) -> some View {
        TextField("Amount", value: expense.amount, formatter: vm.numberFormatter)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            #if !os(macOS)
            .keyboardType(.numbersAndPunctuation)
            #endif
    }
    
    func categoryPicker(expense: Binding<Expense>) -> some View {
        // Get an array of category names sorted alphabetically
        let categoryNames = categoryMapping.keys.sorted()
        
        return Picker("", selection: expense.categoryId) {
            ForEach(categoryNames, id: \.self) { categoryName in
                // Retrieve the categoryId from the mapping
                if let categoryId = categoryMapping[categoryName] {
                    // Use the categoryId as the tag
                    Text(categoryName).tag(categoryId)
                }
            }
        }
    }

    func onDelete(indexSet: IndexSet) {
        vm.expenses.remove(atOffsets: indexSet)
    }
}

#Preview {
    EditExpenseView(vm: HomePageViewModel())
}



//#Preview {
//    AddReceiptToExpenseConfirmationView()
//}
