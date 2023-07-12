//
//  ContentView.swift
//  WiFiScan
//
//  Created by Payam Torab on 6/8/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var client = WiFiClient()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 4){
                ConnectionView(client: client)
                    .frame(maxWidth: geometry.size.width * 1/3)
                Divider()
                ScanView(client: client)
            }
            .padding(.top, 4)
            .font(.system(size: 16.0))
        .background(.background)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
