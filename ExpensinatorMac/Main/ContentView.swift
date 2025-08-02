//
//  ContentView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import SwiftUI

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case home = "Home"
    case receiptScanner = "Receipt Scanner"
}

struct ContentView: View {
    @StateObject var nav = NavigationManager()
    @State var isLoading = false // TODO: CHANGE TO TRUE
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var selectedSideBarItem: SideBarItem = .home
 
    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
                NavigationLink(
                    item.rawValue,
                    value: item
                )
            }
            
        } detail: {
            switch selectedSideBarItem {
            case .home:
                homePageView
            case .receiptScanner:
                ExpenseReceiptScannerView()
            }
        }
        .task {
            do {
                try await CategoryService.shared.getCategories()
                isLoading = false
            } catch {
                print("Error fetching categories: \(error.localizedDescription)")
            }
        }
        .preferredColorScheme(.light)
    }
    
    var homePageView: some View {
        VStack {
            if isLoading {
                Spinner()
            } else {
                switch nav.pageState {
                case .home:
                    HomePageView(nav: nav)
                case .addExpense:
                    AddExpenseView(nav: nav)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
