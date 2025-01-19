import SwiftUI
import UserNotifications

struct Appointment: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var notify: Bool
}

struct KalenderView: View {
    @State private var appointments: [Appointment] = [] {
        didSet {
            saveAppointments()
        }
    }
    @State private var newAppointmentTitle: String = ""
    @State private var newAppointmentDate: Date = Date()
    @State private var notify: Bool = false
    @State private var showNewAppointmentView: Bool = false

    var body: some View {
        VStack {
            Text("Kalender")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(appointments.sorted(by: { $0.date < $1.date })) { appointment in
                    VStack(alignment: .leading) {
                        Text(appointment.title)
                            .font(.headline)
                        Text(appointment.date, style: .date)
                            .font(.subheadline)
                        Text(appointment.date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if appointment.notify {
                            Text("🔔 Benachrichtigung aktiviert")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete(perform: deleteAppointment)
            }

            Button(action: { showNewAppointmentView.toggle() }) {
                Text("Neuen Termin hinzufügen")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .sheet(isPresented: $showNewAppointmentView) {
            VStack(spacing: 20) {
                TextField("Titel", text: $newAppointmentTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Datum und Uhrzeit", selection: $newAppointmentDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Toggle("Benachrichtigung aktivieren", isOn: $notify)
                    .padding()

                Button(action: addAppointment) {
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
        .navigationTitle("Kalender")
        .onAppear {
            requestNotificationPermission()
            loadAppointments()
        }
    }

    // MARK: - Funktionen
    private func addAppointment() {
        guard !newAppointmentTitle.isEmpty else { return }
        let newAppointment = Appointment(id: UUID(), title: newAppointmentTitle, date: newAppointmentDate, notify: notify)
        appointments.append(newAppointment)
        if notify {
            scheduleNotification(for: newAppointment)
        }
        newAppointmentTitle = ""
        newAppointmentDate = Date()
        notify = false
        showNewAppointmentView = false
    }

    private func deleteAppointment(at offsets: IndexSet) {
        appointments.remove(atOffsets: offsets)
    }

    private func saveAppointments() {
        if let encoded = try? JSONEncoder().encode(appointments) {
            UserDefaults.standard.set(encoded, forKey: "Appointments")
        }
    }

    private func loadAppointments() {
        if let data = UserDefaults.standard.data(forKey: "Appointments"),
           let decoded = try? JSONDecoder().decode([Appointment].self, from: data) {
            appointments = decoded
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Fehler bei der Benachrichtigungsanfrage: \(error)")
            }
        }
    }

    private func scheduleNotification(for appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Erinnerung"
        content.body = appointment.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: appointment.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: appointment.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Fehler beim Planen der Benachrichtigung: \(error)")
            }
        }
    }
}
