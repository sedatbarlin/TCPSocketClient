//
//  ViewController.swift
//  TCPSocketClient
//
//  Created by Sedat on 24.10.2023.
//

import UIKit

final class HomeViewController: UIViewController {
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var portNoTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var messageHistoryTextView: UITextView!
    @IBOutlet weak var enterMessageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    
    private var socketConnector: SocketDataManager! //SocketDataManager dosyası içerisindeki fonksiyonlara erişmek için bir nesne
    
    override func viewDidLoad() { //Uygulama çalıştığında bir defa ekranda görüntülenecek olaylar
        super.viewDidLoad()
        socketConnector = SocketDataManager(with: self)
        resetUIWithConnection(status: false)
    }
    override func didReceiveMemoryWarning() { //Uygulama bir hafıza uyarısı aldığında view controller'a gönderilir.
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func connectButton(_ sender: Any) {
        if let ipAddr = ipAddressTextField.text, let portVal = portNoTextField.text{ //Bağlantı başarılı olduğunda
            let soc = DataSocket(ip: ipAddr, port: portVal)
            socketConnector.connectWith(socket: soc) //bağla
            let alert = UIAlertController(title: "Information!", message: "Connection Successful.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }else { //Bağlantı başarısızsa
            let alert = UIAlertController(title: "WARNING!", message: "Please make sure you enter the correct address.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            return
        }
    }
    
    @IBAction private func sendButton(_ sender: Any) { //Send butonuna basıldığında textField'a yazdırılacak mesaj
        guard let message = enterMessageTextField.text else {
            return
        }
        send(message: message)
        enterMessageTextField.text = ""
    }
    
    @IBAction func disconnectButton(_ sender: Any) { //Disconnect butonuna basıldığında yapılacak işlemler
        socketConnector.close()
        let alert = UIAlertController(title: "Information!", message: "Connection terminated successfully.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    private func send(message: String){ //Ekrana yazdırmak için kullanılan func
        socketConnector.send(message: message)
        update(message: "Me: \(message)")
    }
}
