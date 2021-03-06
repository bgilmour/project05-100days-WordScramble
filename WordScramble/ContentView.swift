//
//  ContentView.swift
//  WordScramble
//
//  Created by Bruce Gilmour on 2021-06-30.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationView {
            VStack {
                displayTextEntry

                displayWordList

                displayGameScore
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading: displayNewWordButton)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                displayAlert
            }
        }
    }

    var displayNewWordButton: some View {
        Button(action: startGame) {
            Text("New word")
        }
    }

    var displayTextEntry: some View {
        TextField("Enter your word", text: $newWord, onCommit: addNewWord)
            .autocapitalization(.none)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }

    var displayWordList: some View {
        List(usedWords, id: \.self) { word in
            HStack {
                Image(systemName: "\(word.count).circle")
                Text(word)
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text("\(word), \(word.count) letters"))
        }
    }

    var displayGameScore: some View {
        Text(gameScore)
            .font(.title)
            .foregroundColor(.blue)
    }

    var gameScore: String {
        let wordCount = usedWords.count
        let letterCount = usedWords.map {$0.count}.reduce(0, +)
        return "Words: \(wordCount) Letters: \(letterCount)"
    }

    var displayAlert: Alert {
        Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
    }

    func startGame() {
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = []
                return
            }
        }

        fatalError("Could not load start.txt from bundle")
    }

    func addNewWord() {
        // normalise and clean the new word
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }

        guard isLongAndDifferent(word: answer) else {
            wordError(title: "Too short or the same", message: "Enter a word longer than 3 letters that isn't the displayed word")
            return
        }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can only use the letters in the chosen word.")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "That's not even a real word!")
            return
        }

        usedWords.insert(answer, at: 0)
        newWord = ""
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }

    func isLongAndDifferent(word: String) -> Bool {
        word.count >= 3 && word != rootWord
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
