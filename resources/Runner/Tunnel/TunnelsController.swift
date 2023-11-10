//
//  TunnelsController.swift
//  Runner
//
//  Created by Khánh Tô on 09/11/2023.
//

import Foundation
import WireGuardKit
import MobileCoreServices
import WireGuardKitGo
import WireGuardKitC

class TunnelsController: TunnelsManagerActivationDelegate
{
    var tunnelsManager: TunnelsManager?
    var onTunnelsManagerReady: ((TunnelsManager) -> Void)?
    
    func onInit() {
        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("errror is2=",error)
            case .success(let tunnelsManager):
                self.tunnelsManager = tunnelsManager
                self.setTunnelsManager(tunnelsManager: tunnelsManager)

                tunnelsManager.activationDelegate = self

                self.onTunnelsManagerReady?(tunnelsManager)
                self.onTunnelsManagerReady = nil
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationSetState(_:)), name: Notification.Name("wireguard_vpn_set_state"), object: nil)
    }
    
  @objc func handleNotificationSetState(_ notification: Notification) {
    // Handle the notification here
    print("Notification received! SetState")
      self.onToggleConnect();
      if let userInfo = notification.userInfo {
          // Extract information from userInfo if needed
          let state = userInfo["state"];
      }
  }
    
    func setTunnelsManager(tunnelsManager: TunnelsManager) {
        self.tunnelsManager = tunnelsManager
//        tunnelsManager.tunnelsListDelegate = self
    }
    
    
    func tunnelActivationAttemptFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationAttemptError) {
        
    }

    
    func tunnelActivationAttemptSucceeded(tunnel: TunnelContainer) {
        self.connected()
    }
    
    func tunnelActivationFailed(tunnel: TunnelContainer) {
        
    }
    
    func tunnelActivationSucceeded(tunnel: TunnelContainer) {
        self.connected()
    }
    
    
    func connected(){
        print("TunnelsController connected");
    }
    
    func connecting(){
        print("TunnelsController connecting");
    }
    
    func disconnect(){
        print("TunnelsController disconnect");
    }
    
    func fail(){
        print("TunnelsController fail");
    }
    
    
    let tunnelName = "MyWireguardVPN";
    let address = "10.7.0.2/24";
    let listenPort = 53133;
    let privateKey = "uOPEZ5Cwg04BQvLMvVeLzXBbmeNPcYuUCCDHh3mlzkY=";
    let dnsServers = ["8.8.8.8", "8.8.4.4"]

    let peerPresharedKey = "DEgh40KKg4l/YR0hH9Yfnoc8Li/EvYL1etTSuykn+hU=";
    let peerPublicKey = "OfA9O4UKvZoJef5Byufhv1rUsQwMf0bUIzoFkW5uRW8=";
    let peerAllowedIp1 = "0.0.0.0/0";
    let peerAllowedIp2 = "::/0";
    let peerEndpoint = "13.228.214.146:51820";
    func onToggleConnect() {
        if let tunnel = self.tunnelsManager!.tunnel(named: tunnelName) {
            if  tunnel.status == .active {
                self.tunnelsManager!.startDeactivation(of: tunnel)
                self.disconnect()
                return
            }
        }
       
        self.connecting()
    
        var interface = InterfaceConfiguration(privateKey: PrivateKey(base64Key: privateKey)!)
        interface.addresses = [IPAddressRange(from: String(format: address))!]
        interface.dns = dnsServers.map { DNSServer(from: $0)! }
        interface.listenPort = UInt16(listenPort)

        var peer = PeerConfiguration(publicKey: PublicKey(base64Key: peerPublicKey)!)
        peer.endpoint = Endpoint(from: peerEndpoint)
        peer.allowedIPs = [IPAddressRange(from: peerAllowedIp1)!,IPAddressRange(from: peerAllowedIp2)!]
        peer.persistentKeepAlive = 25
        peer.preSharedKey = PreSharedKey(base64Key: peerPresharedKey)

        // tunnelConfiguration = scannedTunnelConfiguration
        let tunnelConfiguration = TunnelConfiguration(name: tunnelName, interface: interface, peers: [peer])
        
        tunnelsManager?.add(tunnelConfiguration: tunnelConfiguration) { result in
            switch result {
            case .failure(let error):
                print("errror is=",error.message)
                if error.message == "alertTunnelAlreadyExistsWithThatNameTitle" {
                    let tunnel = self.tunnelsManager!.tunnel(named: self.tunnelName)
                    self.tunnelsManager!.startActivation(of: tunnel!)
                }
               // ErrorPresenter.showErrorAlert(error: error, from: qrScanViewController, onDismissal: completionHandler)
            case .success:
                print("added sucses")
                let tunnel = self.tunnelsManager!.tunnel(named: self.tunnelName)
                self.tunnelsManager!.startActivation(of: tunnel!)
               // completionHandler?()
                
            }
        }
    }
  
}
