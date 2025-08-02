//
//  ExpenseReceiptScannerView.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/24/24.
//

import SwiftUI
import AIReceiptScanner

// IMPORTANT: Add your OpenAI API key here or load from environment
let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "YOUR_OPENAI_API_KEY_HERE"

struct ExpenseReceiptScannerView: View {
    @State var scanStatus: ScanStatus = .idle
    @State var addReceiptToExpenseSheetItem: SuccessScanResult?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ReceiptPickerScannerView(apiKey: apiKey, scanStatus: $scanStatus)
            .sheet(item: $addReceiptToExpenseSheetItem) {
                AddReceiptToExpenseConfirmationView(vm: .init(scanResult: $0))
                    .frame(minWidth: horizontalSizeClass == .regular ? 960 : nil, minHeight: horizontalSizeClass == .regular ? 512 : nil)
                
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
