//
//  HomePageView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import Foundation
import SwiftUI
import PythonKit

struct HomePageView: View {
    @ObservedObject var nav: NavigationManager
    @StateObject var viewModel = HomePageViewModel()
    @State private var showAddMenu = false
    @State private var showSideMenu = false
    @State private var totalAmount: PythonObject = 0
    
    var body: some View {
        VStack {
            VStack {
                moneySpent
            }
            .frame(maxWidth: .infinity)
            .background(CustomColor.green1)
            
            syncNow
            recentTransactions
            ExpensesList(expenses: viewModel.expenses, categories: CategoryService.shared.categories)
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                    Spinner()
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showSideMenu.toggle()
                } label: {
                    Image("three.lines.menu")
                        .font(.system(size: 20))
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didAddExpense)) { _ in
            Task {
                await viewModel.getExpenses()
            }
        }
    }
    
    @ViewBuilder
    var moneySpent: some View {
        Spacer()
            .frame(height: 40)
        
        Text("TOTAL SPENT")
            .font(.system(size: 16).bold())
            .foregroundColor(.white)
            .opacity(0.8)
        
        Text("$313.31")
            .font(.system(size: 50).bold())
            .foregroundColor(.white)
        
        Spacer()
            .frame(height: 40)
    }
    
    @ViewBuilder
    var syncNow: some View {
        HStack {
            Button {
                Task {
                    await viewModel.getExpenses()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.black.opacity(0.6))
                        .font(.system(size: 14))
                        .opacity(0.8)
                    
                    Text("See updated transactions")
                        .font(.system(size: 14).bold())
                        .foregroundColor(.black.opacity(0.6))   
                }
            }
            
            Text("|")
                .font(.system(size: 14).bold())
                .foregroundColor(.black.opacity(0.6))
                .opacity(0.8)
            
            Text("Sync Now")
                .font(.system(size: 14).bold())
                .foregroundColor(.black.opacity(0.6))
                .opacity(0.8)
                .underline()
        }
        .padding([.horizontal, .top])
    }
    
    @ViewBuilder
    var recentTransactions: some View {
        HStack {
            Text("Expenses")
                .font(.system(size: 26).bold())
                .foregroundColor(.black)
                .opacity(0.8)
            
            Spacer()
            
            Button {
                nav.pageState = .addExpense
            } label: {
                HStack {
                    Text("+ New Expense")
                        .foregroundStyle(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(CustomColor.green1)
                        }
                        .font(.system(size: 14).bold())
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding([.top, .horizontal])
    }
    
}



#Preview {
    HomePageView(nav: NavigationManager())
}
