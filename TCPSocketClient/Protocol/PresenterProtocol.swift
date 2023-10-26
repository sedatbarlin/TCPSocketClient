//
//  PresenterProtocol.swift
//  TCPSocketClient
//
//  Created by Sedat on 24.10.2023.
//

import Foundation

//MARK: Anasayfada yapılacak güncellemelere ait fonksiyonlar
protocol PresenterProtocol: AnyObject{
    func resetUIWithConnection(status: Bool)
    func updateStatusViewWith(status: String)
    func update(message: String)
}
