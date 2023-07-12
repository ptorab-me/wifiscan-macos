//
//  ConnectionView.swift
//  WiFiScan
//
//  Created by Payam Torab on 6/10/23.
//

import SwiftUI
import CoreWLAN

struct ConnectionView: View {
    @ObservedObject var client: WiFiClient
    
    var connectionIcon: String {
        guard let _if = client.wifiClient.interface() else { return "exclamationmark.circle" }
        return _if.powerOn() ? (_if.interfaceMode() != .none ? "wifi" : "wifi.exclamationmark") : "wifi.slash"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Wi-Fi connection", systemImage: connectionIcon)
                    .foregroundColor(.accentColor)
            }
            Text(client.connectionInfo)
                .foregroundColor(.gray)
            Divider()
            ScrollViewReader { scroller in
                ScrollView {
                    Text(client.connectionDetail)
                }
            }
        }
        .padding(8)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static private var client = WiFiClient()
    
    static var previews: some View {
        ConnectionView(client: client)
    }
}
