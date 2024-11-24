//
//  NavigationManagerView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

//import SwiftUI
//
//enum SideBarItem: String, Identifiable, CaseIterable {
//    var id: String { rawValue }
//    
//    case home
//    case manage
//}
//
//struct NavigationManagerView: View {
//    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
//    @State var selectedSideBarItem: SideBarItem = .home
//    
//    var body: some View {
//        NavigationSplitView(columnVisibility: $sideBarVisibility) {
//            List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
//                NavigationLink(
//                    item.rawValue.localizedCapitalized,
//                    value: item
//                )
//            }
//        } detail: {
//            switch selectedSideBarItem {
//            case .home:
//                HomePageView()
//            case .manage:
//                ExpensesManagerView()
//            }
//        }
//    }
//}
//
//#Preview {
//    NavigationManagerView()
//}
