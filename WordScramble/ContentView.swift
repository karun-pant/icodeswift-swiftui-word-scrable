//
//  ContentView.swift
//  WordScramble
//
//  Created by Pant, Karun on 06/04/20.
//  Copyright © 2020 Pant, Karun. All rights reserved.
//

import SwiftUI

struct ErrorAlert {
    var title: String
    var message: String
    var isShowing: Bool
}

struct ContentView: View {
    @State private var allWords = [String]()
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State var errorAlert = ErrorAlert(title: "", message: "", isShowing: false)
    
    // TODO: save high score for every word in file.
    // show that high score else don't show.
    @State private var score: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Your Score is: \(score)")
                    .frame(maxWidth: CGFloat.greatestFiniteMagnitude)
                    .font(.title)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(score > 0 ? Color.blue : Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .navigationBarTitle(rootWord.capitalized)
            .navigationBarItems(trailing: Button(action: startGame) {
                Text("New Word")
            })
            .onAppear(perform: startGame)
            .alert(isPresented: $errorAlert.isShowing) {
                Alert(title: Text(errorAlert.title),
                      message: Text(errorAlert.message),
                      dismissButton: .default(Text("Ok")))
            }
        }
    }
    
    private func addNewWord() {
        let newWord = self.newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        self.newWord = ""
        guard !newWord.isEmpty else {
            return
        }
        guard isOriginal(word: newWord) else {
            showError(title: "Word already used.", message: "Be more original.")
            return
        }
        guard isPossible(word: newWord) else {
            showError(title: "Nope!!!", message: "You can't just make em up, you know.")
            return
        }
        guard isReal(word: newWord) else {
            showError(title: "Woah!!!", message: "That's not even a word.")
            return
        }
        usedWords.insert(newWord.capitalized, at: 0)
        score += newWord.count
    }
    
    private func isOriginal(word: String) -> Bool {
        guard word != rootWord.lowercased() else {
            return false
        }
        return !usedWords.contains(word)
    }
    
    private func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        guard tempWord.count > word.count else {
            return false
        }
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            }else {
                return false
            }
        }
        return true
    }
    
    private func isReal(word: String) -> Bool {
        guard word.count >= 2  else {
            return false
        }
        let range = NSRange(location: 0, length: word.utf16.count)
        let checker = UITextChecker()
        let misspelledRange = checker.rangeOfMisspelledWord(in: word,
                                      range: range,
                                      startingAt: 0,
                                      wrap: false,
                                      language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    private func startGame() {
        
        // reset
        score = 0
        usedWords.removeAll()
        
        // get all words from cache or file.
        guard !allWords.isEmpty else {
            loadFromFile()
            return
        }
        rootWord = allWords.randomElement() ?? "silkworm"
    }
    
    private func loadFromFile() {
        guard let url = Bundle.main.url(forResource: "start", withExtension: "txt"),
            let fileContent = try? String(contentsOf: url),
            !fileContent.isEmpty else {
            fatalError("start.txt Not found or it has nothing")
        }
        allWords = fileContent.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
    }
    
    private func showError(title: String ,message: String) {
        errorAlert.title = title
        errorAlert.message = message
        errorAlert.isShowing = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
