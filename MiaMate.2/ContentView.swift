import SwiftUI
import OpenAISwift
import AVFoundation
import AVKit



struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}


struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
   // for the prompt
   @State var text = ""
   
   // for sending to and receiving messages from the API
   @State var messages = [ChatMessage]()
   
   // for the speaker
   @State var isSpeakingEnabled = false
   let synthesizer = AVSpeechSynthesizer()
   
   // systemMessage
   let initPrompt = ChatMessage(role: .system, content: "You are a friend to the user and are trying to be as relatable as the user as possible, so you are trying to find out what the user's interests and personality through talking to the user. You have the exact same interests, sense of humor, and personality as the user during the conversation. You mimic the user'S way of talking. You are a person who is a virtual health coach person named Mia. You are not an AI language model. You provide the user with emotional support by trying to be understandable and relatable. You do not spam the user with questions nor with suggestions to change their lifestyle.")
   
   // intro prompt
   let prompt = ChatMessage(role: .assistant, content: "Hi! My name is Mia, a virtual health coach who has knowledge about Chronic Fatigue Syndrome. How are you today?")
       

    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                
                HStack() {
                    Spacer()
                    VStack {
                        Text("MiaMate")
                            .font(.title)
                            .foregroundColor(Color(hue: 0.712, saturation: 0.608, brightness: 0.537))
                            .bold()
                        
                        Image("AvatarMia")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .frame(minWidth: 150, maxWidth: 270, minHeight:150, maxHeight: 270)
                        
                        // ImageSpeechView()
                        // speaker
                        Button(action: {
                            self.isSpeakingEnabled.toggle()
                        }, label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title)
                                .foregroundColor(isSpeakingEnabled ? .blue : .gray)
                        })
                    }
                    Spacer()
                }
                
                ScrollViewReader { scrollview in
                    ScrollView(.vertical) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                            HStack {
                                if message.role != .system {
                                    Text(message.content)
                                        .bold(message.role == .user)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                                }
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ViewHeightKey.self,
                                    value: geometry.size.height
                                )
                            }
                        )
                        
                        .onPreferenceChange(ViewHeightKey.self) { height in
                            if height > 0 {
                                withAnimation {
                                    scrollview.scrollTo(messages.count - 1, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .padding(.all, 20.0)
                    .frame(minHeight: 200 , maxHeight: 270.0)
                    
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(hue: 0.0, saturation: 0.007, brightness: 0.941)))
                    .overlay(
                       Spacer()
                    )
                    
                }.padding(.top, 20.0)
                
                Spacer()
                    
                
                VStack {
                    
                    HStack {
                        TextField("Start chatting...", text: $text)
                            .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 5))
                        
                        Button(action: {
                            Task.detached {
                                await send()
                            }
                        }, label: {
                            Image(systemName: "paperplane.fill")
                                .padding(.trailing, 20.0)
                        })
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20).fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.982))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                }
            }
            .padding(20.0)
            .task {
                viewModel.initialize()
                
                // add prompt message when app launches
                messages.append(initPrompt)
                messages.append(prompt)
                
            }
            .gesture(DragGesture().onChanged { _ in
                // Dismiss the keyboard when the user drags down the view
            UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
            })
        }
    }

    func send() async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: text)

        messages.append(userMessage)

        await viewModel.send(chat: messages) { response in
            let miaMessage = ChatMessage(role: .assistant, content: response)

            DispatchQueue.main.async {
                self.messages.append(miaMessage)
                
                if self.isSpeakingEnabled{
                    self.speak(text: miaMessage.content)
                }
            }
        }

        text = ""
    }
    
    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        for voice in voices {
            print(voice.name)
            print(voice.identifier)
        }
        
        speechUtterance.rate = 0.45

        // Speak the utterance
        synthesizer.speak(speechUtterance)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

