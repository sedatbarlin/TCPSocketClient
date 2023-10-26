//
//  SocketDataManager.swift
//  TCPSocketClient
//
//  Created by Sedat on 24.10.2023.
//

import Foundation

class SocketDataManager: NSObject, StreamDelegate { //Stream: Bir akışı temsil eden soyut bir sınıf
    var readStream: Unmanaged<CFReadStream>? //CFReadStream, bir bayt akışını eşzamanlı veya eşzamansız olarak okumak için bir arayüz sağlar. Bir bellek bloğundan, bir dosyadan veya genel bir soketten bayt okuyan akışlar oluşturabilirsiniz.
    var writeStream: Unmanaged<CFWriteStream>? //CFWriteStream, bir bayt akışını eşzamanlı veya eşzamansız olarak yazmak için bir arayüz sağlar. Baytları bir bellek bloğuna, bir dosyaya veya genel bir yuvaya yazan akışlar oluşturabilirsiniz.
    var inputStream: InputStream? //InputStream, akış verilerine standart salt okunur erişim sağlayan NSStream'in somut alt sınıflarından oluşan bir sınıf kümesinin soyut bir üst sınıfıdır.
    var outputStream: OutputStream? //OutputStream, bir akışa veri yazmanıza olanak tanıyan NSStream'in somut bir alt sınıfıdır.
    
    weak var uiPresenter :PresenterProtocol! //PresenterProtocol içerisindeki fonksiyonlara erişmek için bir nesne
    
    init(with presenter:PresenterProtocol){
        self.uiPresenter = presenter
    }
    
    func connectWith(socket: DataSocket) { //Bağlantı kurulması
        //Belirli bir host'un TCP/IP bağlantı noktasına bağlı okunabilir ve yazılabilir akışlar oluşturur.
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           (socket.ipAddress! as CFString),
                                           UInt32(socket.port),
                                           &readStream,
                                           &writeStream)
        open() //bağlantı yolları açıldı
    }
    
    func disconnect(){ //Bağlantıyı kes
        close()
    }
    
    func open(){ //Akışı açmak için kullanılan func
        print("Opening streams.")
        //Bu yönetilmeyen referansın değerini yönetilen bir referans olarak alır ve dengesiz bir şekilde muhafaza edilmesini sağlar. takeRetainedValue()
        outputStream = writeStream?.takeRetainedValue()
        inputStream = readStream?.takeRetainedValue()
        //Varsayılan olarak bir Stream nesnesinin kendi temsilcisi(delegate) olması gerekir. Bu nedenle "nil" argümanına sahip bir delegate mesajı bu delegateyi geri yüklemeli. Temsilciyi açmak için self, kapatmak için nil.
        outputStream?.delegate = self
        inputStream?.delegate = self
        //Stream (akış) nesnesini belirtilen mod için belirtilen çalışma döngüsünde çalıştırmak için schedule kullanılır
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.open()
        inputStream?.open()
    }
    
    func close(){ //Akışı kapatmak için kullanılan func
        print("Closing streams.")
        uiPresenter?.resetUIWithConnection(status: false)
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        //Stream (akış) nesnesini belirtilen mod için belirtilen çalışma döngüsünden kaldırmak için remove kullanılır
        inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream = nil
        outputStream = nil
        inputStream?.close()
        outputStream?.close()
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) { //StreamEvent: Akış olayının türünü belirtmek için gönderilecek sabitleri açıklar
        print("stream event \(eventCode)")
        switch eventCode{
        case .openCompleted: //Akış başarıyla tamamlandı.
            uiPresenter?.resetUIWithConnection(status: true)
            print("Stream opened")
            break
        case .hasBytesAvailable: //Akışta okunacak baytlar var.
            if aStream == inputStream {
                var dataBuffer = Array<UInt8>(repeating: 0, count: 1024)
                var len: Int
                while (inputStream?.hasBytesAvailable)! {
                    len = (inputStream?.read(&dataBuffer, maxLength: 1024))!
                    if len > 0 {
                        let output = String(bytes: dataBuffer, encoding: .ascii)
                        if nil != output {
                            print("Server: \(output ?? "")")
                            messageReceived(message: output!)
                        }
                    }
                }
            }
            break
        case .hasSpaceAvailable: //Akış, yazmak için baytları kabul edebilir.
            print("Stream has space available now")
            break
        case .errorOccurred: //Akışta bir hata oluştu.
            print("\(aStream.streamError?.localizedDescription ?? "")")
            break
        case .endEncountered: //Akışın sonuna ulaşıldı.
            aStream.close() //Akıştan çıkıldı
            //Stream (akış) nesnesini belirtilen mod için belirtilen çalışma döngüsünden kaldırmak için remove kullanılır
            aStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            print("close stream")// Konsola yazdırılarak haberleşildi
            uiPresenter?.resetUIWithConnection(status: false)
            break
        default:
            print("Unknown event")
            break
        }
        
        func messageReceived(message: String){
            uiPresenter?.update(message: "Server: \(message)")
            print(message)
        }
    }
    func send(message: String){
        let response = "message:\(message)"
        let buff = [UInt8](message.utf8)
        if let _ = response.data(using: .ascii) {
            outputStream?.write(buff, maxLength: buff.count)
        }
    }
}

