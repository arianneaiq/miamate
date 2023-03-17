//
//  ViewModel.swift
//  MiaMate.2
//
//  Created by Arianne Xaing on 14/03/2023.
//

import Foundation
import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    
    private var openAI: OpenAISwift?
        

    
    // initialization
    func initialize() {
        openAI = OpenAISwift(authToken: "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")

    }
    
    // function to send request to the API
    //  - argument: string
    //  - return: successful response or error msg in string
    
    func send(chat: [ChatMessage], completion: @escaping (String) -> Void ) async {
        
        // method uses the text-davinci-003 model
        openAI?.sendChat(with: chat, model: .chat(.chatgpt), maxTokens: 500, temperature: 0.7, completionHandler: { result in
            switch result {
                case .success(let success):
                let output = success.choices.first?.message.content ?? ""
                    completion(output)
                case .failure(let failure):
                    print(failure.localizedDescription)
            }
        })
    }
}
