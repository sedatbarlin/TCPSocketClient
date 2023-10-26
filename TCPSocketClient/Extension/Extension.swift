//
//  Extension.swift
//  TCPSocketClient
//
//  Created by Sedat on 24.10.2023.
//

import Foundation
import UIKit

extension HomeViewController: PresenterProtocol{ //Inherite
    //MARK: Interface Update
    //Uygulama ilk açıldığında ekranda aktif/devre dışı edilecek noktalar
    func resetUIWithConnection(status: Bool){
        ipAddressTextField.isEnabled = !status    //veri girileceği için aktif
        portNoTextField.isEnabled = !status       //veri girileceği için aktif
        enterMessageTextField.isEnabled = status  //henüz server ile bağlantı kurulmadığı için inaktif
        connectButton.isEnabled = !status         //veri girileceği için aktif
        sendButton.isEnabled = status             //henüz server ile bağlantı kurulmadığı için inaktif
        disconnectButton.isEnabled = status       //henüz server ile bağlantı kurulmadığı için inaktif
        
        if(status){ //Eğer bağlantı başarılı bir şekilde kurulduysa
            updateStatusViewWith(status: "Connected")
            statusView.backgroundColor = .green
            sendButton.tintColor = .green
        }else{ //Eğer bağlantı başarılı bir şekilde kurulmadıysa
            updateStatusViewWith(status: "Disconnected")
            statusView.backgroundColor = .red
        }
    }
    func updateStatusViewWith(status: String){ //Bağlantı başarılı veya başarısız ise uygun başlığı güncelle
        statusLabel.text = status
    }
    
    func update(message: String){ //gelen ve giden mesajların nasıl yazdırılacağı
        if let text = messageHistoryTextView.text{
            let newText = """
            \(text)
            \(message)
            """
            messageHistoryTextView.text = newText
        }else{
            let newText = """
            \(message)
            """
            messageHistoryTextView.text = newText
        }
        let myRange=NSMakeRange(messageHistoryTextView.text.count-1, 0);
        messageHistoryTextView.scrollRangeToVisible(myRange)
    }
}
