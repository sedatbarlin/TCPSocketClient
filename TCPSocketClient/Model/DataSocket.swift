//
//  DataSocket.swift
//  TCPSocketClient
//
//  Created by Sedat on 24.10.2023.
//

import Foundation

//MARK: IP adresi ve Port Numarası alma
struct DataSocket {
    let ipAddress: String!
    let port: Int!
    
    init(ip: String, port: String){
        self.ipAddress = ip
        self.port = Int(port)
    }
}
