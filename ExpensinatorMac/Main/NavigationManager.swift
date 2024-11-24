//
//  NavigationManager.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import Foundation

class NavigationManager: ObservableObject {
    @Published var pageState = PageState.home
    
    enum PageState {
        case home
        case addExpense
    }
    
}
