//
//  AddReceiptToExpenseConfirmationView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/5/24.
//

import SwiftUI

struct AddReceiptToExpenseConfirmationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @State var vm: AddReceiptToExpenseConfirmationViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    HStack {
                        DatePicker(selection: $vm.date, displayedComponents: [.date]) {
                            Text("Date:")
                        }
                        
                        Spacer()
                        
                    }
                    
                    switch horizontalSizeClass {
                    case .regular: regularView
                        default: compactView
                        
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Confirmation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        vm.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button("Reset Changes", role: .destructive) {
                        self.vm.resetChanges()
                    }
                    .tint(.red)
                    .disabled(!vm.isEdited)
                }

            }
        }
        .onChange(of: vm.expenses) { _, newValue in
            print("Expenses changed to \(newValue)")
        }
    }
    
    var regularView: some View {
        ForEach($vm.expenses, id: \.id) { expense in
            HStack(spacing: 16) {
                HStack {
                    Text("Description:")
                    descriptionTextField(expense: expense)
                }
                
                HStack {
                    Text("Amount:")
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
    
    var compactView: some View {
        ForEach($vm.expenses, id: \.id) { expense in
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
            .keyBoardType(.numbersAndPunctuation)
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

//#Preview {
//    AddReceiptToExpenseConfirmationView()
//}
