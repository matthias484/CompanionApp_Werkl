//
//  QuizQuestion.swift
//  CompanionApp_Werkl
//
//  Created by Matthias Werkl on 10.01.25.
//


import SwiftUI

struct QuizQuestion: Identifiable {
    let id = UUID()
    var question: String
    var answers: [String]
    var correctAnswer: String
}

struct QuizView: View {
    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex: Int = 0
    @State private var userAnswer: String = ""
    @State private var showResult: Bool = false
    @State private var isLoading: Bool = true

    var body: some View {
        VStack {
            if isLoading {
                Text("Lade Quizfragen...")
                    .font(.title)
            } else if questions.isEmpty {
                Text("Keine Fragen gefunden. Bitte versuche es später erneut.")
                    .font(.title)
            } else {
                let currentQuestion = questions[currentIndex]

                Text(currentQuestion.question)
                    .font(.headline)
                    .padding()

                ForEach(currentQuestion.answers, id: \.self) { answer in
                    Button(action: {
                        userAnswer = answer
                        checkAnswer()
                    }) {
                        Text(answer)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
        }
        .onAppear(perform: loadQuestions)
        .alert(isPresented: $showResult) {
            Alert(
                title: Text(userAnswer == questions[currentIndex].correctAnswer ? "Richtig!" : "Falsch!"),
                message: Text("Die richtige Antwort war: \(questions[currentIndex].correctAnswer)"),
                dismissButton: .default(Text("Weiter")) {
                    nextQuestion()
                }
            )
        }
        .navigationTitle("Quiz")
    }

    private func loadQuestions() {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.questions = decodedResponse.results.map {
                            QuizQuestion(
                                question: $0.question,
                                answers: ($0.incorrect_answers + [$0.correct_answer]).shuffled(),
                                correctAnswer: $0.correct_answer
                            )
                        }
                        self.isLoading = false
                    }
                } catch {
                    print("Fehler beim Decodieren: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } else {
                print("Fehler: \(error?.localizedDescription ?? "Unbekannter Fehler")")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }

    private func checkAnswer() {
        showResult = true
    }

    private func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
}

struct TriviaResponse: Decodable {
    struct Question: Decodable {
        let question: String
        let correct_answer: String
        let incorrect_answers: [String]
    }
    let results: [Question]
}
