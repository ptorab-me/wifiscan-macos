//
//  WiFiClient.swift
//  WiFiScan
//
//  Created by Payam Torab on 6/8/23.
//

import Foundation
import CoreWLAN
import CoreLocation

class WiFiClient: ObservableObject {
    let wifiClient = CWWiFiClient.shared()
    let locationManager = CLLocationManager()  // for BSSID and IEs
    
    // --- wifi connection ---
    let updateInterval: Int = 1
    @Published var connectionDetail: String = ""
    var connectionInfo: String {  // no wrappers for computed properties
        guard let _if = wifiClient.interface() else { return "No interface" }
        return "Interface: \(_if.interfaceName!), " +
        (_if.powerOn() ? "enabled, \(_if.interfaceMode() != .none ? "connected": "disconnected")" : "disabled")
    }
    
    // --- wifi scan ---
    let scanInterval: Int = 15
    @Published var cachedScan: Bool = false
    @Published var scanInProgress: Bool = false
    @Published var networks: Set<CWNetwork> = []
    var scanInfo: String {  // computed properties take (and need) no wrappers
        scanInProgress ? "Scanning ..." :
        String("\(networks.count) networks on " +
               "2.4 GHz (\(networksOn(.band2GHz))), " +
               "5 GHz (\(networksOn(.band5GHz))), " +
               "6 GHz (\(networksOn(.band6GHz)))")
    }
    
    func networksOn(_ band: CWChannelBand) -> Int {
        networks.filter({ $0.wlanChannel?.channelBand == band }).count
    }
    
    init() {
        Timer.scheduledTimer(
            withTimeInterval: TimeInterval(updateInterval), repeats: true) { _ in
                self.connectionUpdate() }.fire()
        Timer.scheduledTimer(
            withTimeInterval: TimeInterval(scanInterval), repeats: true) { _ in
                self.scanUpdate() }.fire()
        
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    // helper function to display channel information
    static func channelInfo(_ channel: CWChannel?) -> String? {
        guard let channel else { return nil }
        
        var channelNumber: Int {
            channel.channelNumber
        }
        var channelBand: String {
            switch channel.channelBand {
            case .band2GHz: return "2.4 GHz"
            case .band5GHz: return   "5 GHz"
            case .band6GHz: return   "6 GHz"
            default:        return   "? GHz"
            }
        }
        var channelWidth: String {
            switch channel.channelWidth {
            case  .width20MHz: return  "20 MHz"
            case  .width40MHz: return  "40 MHz"
            case  .width80MHz: return  "80 MHz"
            case .width160MHz: return "160 MHz"
            default:           return   "? MHz"
            }
        }
        return "\(channelNumber) (\(channelBand), \(channelWidth))"
    }
    
    // helper function to display information elements
    static func ieInfo(_ ies: Data?) -> String? {
        guard let ies else { return nil }
        
        var str: String = ""
        ies.forEach({ c in str += String(format:"%02x ", c) })
        return str
    }
    
    func connectionUpdate() {
        guard let ifc = wifiClient.interface() else { print("No interface!"); return }
        var str: String = ""
        
        var security: String {
            switch ifc.security() {
            case .wpaPersonal:          return "WPA Personal"
            case .wpaPersonalMixed:     return "WPA/WPA2 Personal"
            case .wpa2Personal:         return "WPA2 Personal"
            case .wpa3Transition:       return "WPA2/WPA3 Personal"
            case .wpa3Personal:         return "WPA3 Personal"
            case .wpaEnterprise:        return "WPA Enterprise"
            case .wpaEnterpriseMixed:   return "WPA/WPA2 Enterprise"
            case .wpa2Enterprise:       return "WPA2 Enterprise"
            case .wpa3Enterprise:       return "WPA3 Enterprise"
            default:                    return "Other"
            }
        }
        
        var phyMode : String {
            switch ifc.activePHYMode() {
            case .mode11a:  return "802.11a"
            case .mode11b:  return "802.11b"
            case .mode11g:  return "802.11g"
            case .mode11n:  return "802.11n"
            case .mode11ac: return "802.11ac"
            case .mode11ax: return "802.11ax"
            default:        return "802.11??"
            }
        }
        
        str += "SSID: \(ifc.ssid() ?? "Unknown")\n"
        str += "BSSID: \(ifc.bssid() ?? "Unknown")\n"
        str += "Security: \(security)\n"
        str += "Channel: \(WiFiClient.channelInfo(ifc.wlanChannel()) ?? "Unknown")\n"
        str += "Country Code: \(ifc.countryCode() ?? "Unknown")\n"
        str += "RSSI: \(ifc.rssiValue()) dBm\n"
        str += "Noise: \(ifc.noiseMeasurement()) dBm\n"
        str += "Tx Rate: \(ifc.transmitRate()) Mbps\n"
        str += "Tx Power: \(ifc.transmitPower()) mW\n"
        str += "PHY Mode: \(phyMode)\n"
        str += "HW Address: \(ifc.hardwareAddress() ?? "Unknown")"
        
        connectionDetail = str
    }
    
    func scanUpdate() {
        guard let ifc = wifiClient.interface() else { print("No interface!"); return }
        
        if !scanInProgress {
            scanInProgress = true
            Task {
                let networks: Set<CWNetwork> // later assignment ok
                do {
                    networks = cachedScan ? ifc.cachedScanResults() ?? [] :
                    try ifc.scanForNetworks(withSSID: nil, includeHidden: true)
                } catch {
                    print(error.localizedDescription)
                    networks = []
                }
                DispatchQueue.main.async {
                    self.networks = networks
                    self.scanInProgress = false
                }
            }
        }
    }
}
