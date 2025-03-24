//
//  ScanItemView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 20/03/2025.
//

import SwiftUI

struct ScanItemView: View {
    @State private var scannedCode: String = ""
    @State private var isShowingScanner = false
    @State private var item: Item? = nil
    @State private var errorMessage: String? = nil
    
    let db = DatabaseHandling()
    
    var body: some View {
        VStack {
            if let item = item {
                Text("Item name: \(item.product_name ?? "unkown")")
                    .font(.title2)
                    .padding()
                Text("Price: \(item.price ?? "unkown")")
                    .padding()
            } else {
                Text("Scanned Barcode: \(scannedCode)")
                    .font(.title2)
                    .padding()
            }
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: { isShowingScanner = true }) {
                Label("Scan Barcode", systemImage: "barcode.viewfinder")
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            BarcodeScannerView { barcode in
                scannedCode = barcode
                isShowingScanner = false
                db.fetchItemFromBarcode(by: barcode) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let fetchedItem):
                            self.item = fetchedItem
                            self.errorMessage = nil
                        case .failure:
                            self.item = nil
                            self.errorMessage = "Item not found"
                        }
                    }
                }
                
            }
        }
    }
}
