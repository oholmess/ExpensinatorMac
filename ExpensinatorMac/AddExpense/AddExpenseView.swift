//
//  AddExpenseView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var nav: NavigationManager
    @StateObject var viewModel = AddExpenseViewModel()
    var isButtonDisabled: Bool {
        viewModel.description.isEmpty || viewModel.merchat.isEmpty || viewModel.amount.isEmpty || viewModel.selectedCategory == nil
    }
    @State private var selectedImageURL: URL?
    
    var body: some View {
        VStack {
            newExpenseTitle
            Divider().padding([.horizontal, .bottom])
            newExpenseForm
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                    Spinner()
                }
            }
        }
        .showSuccessOverlay(successTitle: "Success!", successSubtitle: "Your expense was added.", show: $viewModel.showSuccessAlert, dismissAction: { nav.pageState = .home })
    }
    
    var newExpenseTitle: some View {
        HStack {
            Text("Expenses")
                .font(.system(size: 26).bold())
                .foregroundColor(.black)
                .opacity(0.8)
            
            Spacer()
            
            Button {
                nav.pageState = .home
            } label: {
                HStack {
                    Image(systemName: "xmark")
                        .padding()
                        .font(.system(size: 14).bold())
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding([.top, .horizontal])
    }
    
    var newExpenseForm: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.system(size: 16).bold())
                        .foregroundColor(.black)
                        .opacity(0.8)
                    Spacer()
                    Text("Category")
                        .font(.system(size: 16).bold())
                        .foregroundColor(.black)
                        .opacity(0.8)
                    Spacer()
                    Text("Total")
                        .font(.system(size: 16).bold())
                        .foregroundColor(.black)
                        .opacity(0.8)
                    Spacer()
                    Text("Date")
                        .font(.system(size: 16).bold())
                        .foregroundColor(.black)
                        .opacity(0.8)
                    Spacer()
                    Text("Merchant")
                        .font(.system(size: 16).bold())
                        .foregroundColor(.black)
                        .opacity(0.8)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 2)
                
                VStack(alignment: .leading) {
                    TextField("", text: $viewModel.description)
                        .font(.system(size: 20))
                        .padding(.leading, 18)
                        .frame(maxHeight: 35)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Spacer()
                    
                    Picker("", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.categoryId) { category in
                            Text(category.name).tag(category)
                        }
                    }
                    
                    Spacer()
                    
                    TextField("", text: $viewModel.amount)
                        .font(.system(size: 20))
                        .padding(.leading, 18)
                        .frame(maxHeight: 35)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Spacer()
                    
                    DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    Spacer()
                    
                    TextField("", text: $viewModel.merchat)
                        .font(.system(size: 20))
                        .padding(.leading, 18)
                        .frame(maxHeight: 35)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Spacer()
                }
                
                
                if let imageURL = selectedImageURL {
                    VStack(alignment: .trailing) {
                        Button {
                            selectedImageURL = nil
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .font(.system(size: 14).bold())
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(.red))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing)
                        
                        Button {
                            selectImage()
                        } label: {
                            Image(nsImage: NSImage(contentsOf: imageURL)!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.trailing)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                } else {
                    Button {
                        selectImage()
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .frame(maxWidth: .infinity)
                            .overlay {
                                VStack {
                                    Image(systemName: "plus")
                                        .font(.system(size: 26).bold())
                                        .foregroundColor(.black)
                                    
                                    Text("Upload a receipt")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black.opacity(0.7))
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing)
                }
               
            }
            .frame(minHeight: 260, idealHeight: 300, maxHeight: 350)
            
            Spacer()
            
            Button {
                if let imageURL = selectedImageURL {
                    viewModel.addAndUploadReceipt(imageURL: imageURL)
                } else {
                    viewModel.addExpense()
                }
            } label: {
                Text("Save Expense")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 8).fill(CustomColor.green1))
                    .fixedSize()
                    .opacity(isButtonDisabled ? 0.6 : 1)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .disabled(isButtonDisabled)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(CustomColor.BittersweetShimmer)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
    
    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png", "jpg", "jpeg"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            selectedImageURL = url
        }
    }
}

#Preview {
    AddExpenseView(nav: NavigationManager())
}
