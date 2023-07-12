//
//  NetworkView.swift
//  WiFiScan
//
//  Created by Payam Torab on 6/9/23.
//

import SwiftUI
import CoreWLAN

struct NetworkView: View {
    let network: CWNetwork
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("SSID: \(network.ssid ?? "Unknown")")
            Text("BSSID: \(network.bssid ?? "Unknown")")
            Text("Channel: \(WiFiClient.channelInfo(network.wlanChannel) ?? "Unknown")")
            Text("Country Code: \(network.countryCode ?? "Unknown")")
            Text("RSSI: \(network.rssiValue) dBm")
            Text("Noise: \(network.noiseMeasurement) dBm")
            Text("IEs: \(WiFiClient.ieInfo(network.informationElementData) ?? "Unknown")")
        }
    }
}

struct NetworkView_Previews: PreviewProvider {
    static private var network = CWWiFiClient.shared().interface()?.cachedScanResults()?.first

    static var previews: some View {
        if let network {
            NetworkView(network: network)
        } else {
            EmptyView()
        }
    }
}
