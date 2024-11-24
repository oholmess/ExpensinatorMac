//
//  ExpenseReceiptScannerView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/24/24.
//

import SwiftUI
import AIReceiptScanner

let apikey = "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"

struct ExpenseReceiptScannerView: View {
    @State var scanStatus: ScanStatus = .idle
    @State var addReceiptToExpenseSheetItem: SuccessScanResult?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ReceiptPickerScannerView(apiKey: apikey, scanStatus: $scanStatus)
            .sheet(item: $addReceiptToExpenseSheetItem) { item in
                Text("Todo: Confirmation View")
                
            }
            .navigationTitle("AI Receipt Scanner")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if let scanResult = scanStatus.scanResult {
                        Button {
                            addReceiptToExpenseSheetItem = scanResult
                        } label: {
                            #if os(macOS)
                            HStack {
                                Image(systemName: "plus")
                                    .symbolRenderingMode(.monochrome)
                                    .tint(.accentColor)
                                Text("Add to Expenses")
                            }
                            #else
                             Text("Add to Expeneses")
                            #endif
                        }
                    }
                }
            }
    }
}

#Preview {
    ExpenseReceiptScannerView()
}
