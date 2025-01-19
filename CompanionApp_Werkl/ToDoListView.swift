import SwiftUI

struct ToDoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

struct ToDoListView: View {
    @State private var toDoItems: [ToDoItem] = [] {
        didSet {
            saveToDoItems()
        }
    }
    @State private var newTaskTitle: String = ""

    var body: some View {
        VStack {
            Text("To-Do-Liste")
                .font(.largeTitle)
                .padding()

            HStack {
                TextField("Neue Aufgabe", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: addTask) {
                    Text("Hinzufügen")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()

            List {
                ForEach(toDoItems) { item in
                    HStack {
                        Text(item.title)
                            .strikethrough(item.isCompleted, color: .black)
                            .foregroundColor(item.isCompleted ? .gray : .black)

                        Spacer()

                        Button(action: {
                            toggleCompletion(for: item)
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .gray)
                        }
                    }
                }
                .onDelete(perform: deleteTask)
            }
        }
        .padding()
        .navigationTitle("To-Do-Liste")
        .onAppear(perform: loadToDoItems)
    }

    // MARK: - Funktionen
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let newTask = ToDoItem(id: UUID(), title: newTaskTitle, isCompleted: false)
        toDoItems.append(newTask)
        newTaskTitle = ""
    }

    private func toggleCompletion(for item: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index].isCompleted.toggle()
        }
    }

    private func deleteTask(at offsets: IndexSet) {
        toDoItems.remove(atOffsets: offsets)
    }

    private func saveToDoItems() {
        if let encoded = try? JSONEncoder().encode(toDoItems) {
            UserDefaults.standard.set(encoded, forKey: "ToDoItems")
        }
    }

    private func loadToDoItems() {
        if let data = UserDefaults.standard.data(forKey: "ToDoItems"),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: data) {
            toDoItems = decoded
        }
    }
}
