//
//  ImageSpeechView .swift
//  MiaMate.2
//
//  Created by Arianne Xaing on 14/03/2023.
//

import SwiftUI
import AVFoundation

struct ImageSpeechView: View {
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("No image to display")
            }
        }
        .onAppear(){
            sendImageToAPI(imageParams: ImageParameters.avatar)
            createTalk()
            getTalk()
            
        }
    }
    
    func sendImageToAPI(imageParams: ImageParameters) {
        // Replace this with code to fetch your local image
        if let data = UIImage(named: "Avatar")?.jpegData(compressionQuality: 1.0) {
            // Set the image to display
            self.image = UIImage(data: data)
            
            // Set up the API call to d-id
            let headers = [
                "accept": "application/json",
                "content-type": "multipart/form-data; boundary=---011000010111000001101001",
                "authorization": "Basic YXJpYW5uZXhpYW5nMTIxN0BnbWFpbC5jb20:cPOQz00e_VcKIMOGD3pap"
           ]
            let parameters = [
                [
                    "fileName": imageParams.fileName,
                    "contentType": imageParams.contentType,
                    "name": imageParams.name,
                    "value": imageParams.value
                ]
            ]
            
            let boundary = "---011000010111000001101001"
            
            // Create the request body
            var body = Data()
            for param in parameters {
                print("111111")
                let paramName = param["name"]!
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition:form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
                if let paramValue = param["value"] {
                    body.append("\(paramValue)\r\n".data(using: .utf8)!)
                }
            }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition:form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            body.append("Content-Type:image/png\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            // Create the request
            let request = NSMutableURLRequest(url: NSURL(string: "https://api.d-id.com/images")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            
            // Send the request
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                    print("222222222")
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let imageId = json["id"] as? String {
                            print("Image uploaded with ID: \(imageId)")
                        } else {
                            print("Unable to parse API response")
                        }
                        print("33333333")
                        print(httpResponse)
                    }
                }
            })
            
            dataTask.resume()
        }
    }
    
    func createTalk(){

         let headers = [
           "accept": "application/json",
           "content-type": "application/json",
           "authorization": "Basic YXJpYW5uZXhpYW5nMTIxN0BnbWFpbC5jb20:cPOQz00e_VcKIMOGD3pap"
         ]
         let parameters = [
            "script": [
              "type": "text",
              "provider": [
                "type": "microsoft",
                "voice_id": "Jenny"
              ],
              "ssml": "false",
              "input": "Hi! My name is Mia, a virtual health coach who has knowledge about Chronic Fatigue Syndrome. How are you today?"
            ],
            "config": [
              "fluent": "false",
              "pad_audio": "0.0"
            ],
            "source_url": "https://i.postimg.cc/FK9h1Dfs/Avatar.png"
          ] as [String : Any]

         let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        print("444444")

         let request = NSMutableURLRequest(url: NSURL(string: "https://api.d-id.com/talks")! as URL,
                                                 cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 10.0)
         request.httpMethod = "POST"
         request.allHTTPHeaderFields = headers
         request.httpBody = postData as Data?
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            print("!!!!!!")
            print("Response: \(response as Any)")
            if (error != nil) {
                print("Error: \(error as Any)")
            } else {
                if let responseData = data,
                   let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                    print("JSON response: \(json)")
                } else {
                    print("Error: Invalid JSON response")
                }
            }
        })

        dataTask.resume()

     }

    func getTalk(){
        
        let headers = [
          "accept": "application/json",
          "authorization": "Basic YXJpYW5uZXhpYW5nMTIxN0BnbWFpbC5jb20:cPOQz00e_VcKIMOGD3pap"
        ]
        print("555555")
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.d-id.com/talks/tlk_MJzAKQkGABY2iC5W32mik")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        print("6666")
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                 
                    if let audioUrlString = httpResponse.allHeaderFields["audio-url"] as? String,
                       let audioUrl = URL(string: audioUrlString) {
                        print("######")
                        // Call the playAudio() function with the audio URL
                        playAudio(url: audioUrl)
                    }
                }
            }
        })

        dataTask.resume()
    }
    
    func playAudio(url: URL) {
        let player = AVPlayer(url: url)
        player.play()
    }
}

struct ImageSpeechView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSpeechView()
    }
}
