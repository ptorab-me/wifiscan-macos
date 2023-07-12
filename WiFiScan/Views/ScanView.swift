//
//  ScanView.swift
//  WiFiScan
//
//  Created by Payam Torab on 6/10/23.
//

import SwiftUI

struct ScanView: View {
    @ObservedObject var client: WiFiClient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Wi-Fi scan | Scan interval: \(client.scanInterval) sec", systemImage: "magnifyingglass")
                    .foregroundColor(.accentColor)
                Spacer()
                Toggle("Cached scan results", isOn: $client.cachedScan)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .foregroundColor(.accentColor)
            }
            Text(client.scanInfo)
                .foregroundColor(.gray)
            Divider()
            ScrollViewReader { scroller in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        // scan results in decreasing order of rssi
                        ForEach(client.networks.sorted(by: {$0.rssiValue > $1.rssiValue}), id: \.self) { network in
                            NetworkView(network: network)
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}

struct ScanView_Previews: PreviewProvider {
    static private var client = WiFiClient()
    
    static var previews: some View {
        ScanView(client: client)
    }
}
