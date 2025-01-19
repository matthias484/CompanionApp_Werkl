import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
}

struct NotizbuchView: View {
    @State private var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    @State private var newNoteTitle: String = ""
    @State private var newNoteContent: String = ""
    @State private var showNewNoteView: Bool = false

    var body: some View {
        VStack {
            Text("Notizbuch")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(notes) { note in
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.content)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteNote)
            }

            Button(action: { showNewNoteView.toggle() }) {
                Text("Neue Notiz hinzufügen")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .sheet(isPresented: $showNewNoteView) {
            VStack(spacing: 20) {
                TextField("Titel", text: $newNoteTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextEditor(text: $newNoteContent)
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                    .padding()

                Button(action: addNote) {
                    Text("Speichern")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Notizbuch")
        .onAppear(perform: loadNotes)
    }

    // MARK: - Funktionen
    private func addNote() {
        guard !newNoteTitle.isEmpty, !newNoteContent.isEmpty else { return }
        let newNote = Note(id: UUID(), title: newNoteTitle, content: newNoteContent)
        notes.append(newNote)
        newNoteTitle = ""
        newNoteContent = ""
        showNewNoteView = false
    }

    private func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }

    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "Notes")
        }
    }

    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "Notes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
}
