import SwiftUI

struct ContentView: View {
    @State private var items: [String] = UserDefaults.standard.stringArray(forKey: "ItemOrder") ?? [
        "To-Do-Liste",
        "Notizbuch",
        "Kalender",
        "Quiz",
        "Wetter"
    ]

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(items, id: \.self) { item in
                        NavigationLink(destination: getView(for: item)) {
                            Text(item)
                                .font(.headline)
                                .padding(.vertical, 10)
                        }
                    }
                    .onMove(perform: moveItem)
                }
                .listStyle(InsetGroupedListStyle())
                .toolbar {
                    EditButton() // Ermöglicht das Bearbeiten der Reihenfolge
                }
            }
            .navigationTitle("Companion App")
        }
    }

    private func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        saveOrder()
    }

    private func saveOrder() {
        UserDefaults.standard.set(items, forKey: "ItemOrder")
    }

    private func getView(for item: String) -> AnyView {
        switch item {
        case "To-Do-Liste": return AnyView(ToDoListView())
        case "Notizbuch": return AnyView(NotizbuchView())
        case "Kalender": return AnyView(KalenderView())
        case "Quiz": return AnyView(QuizView())
        case "Wetter": return AnyView(WetterView())
        default: return AnyView(Text("Unbekannter View"))
        }
    }
}
