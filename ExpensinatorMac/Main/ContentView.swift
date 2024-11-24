//
//  ContentView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var nav = NavigationManager()
    @State var isLoading = false // TODO: CHANGE TO TRUE
 
    var body: some View {
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
        .preferredColorScheme(.light)
        .task {
            do {
                try await CategoryService.shared.getCategories()
                isLoading = false
            } catch {
                print("Error fetching categories: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
