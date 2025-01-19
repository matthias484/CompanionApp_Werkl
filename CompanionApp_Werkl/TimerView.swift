import SwiftUI

struct TimerView: View {
    @State private var remainingTime: TimeInterval = UserDefaults.standard.double(forKey: "RemainingTime")
    @State private var isRunning: Bool = UserDefaults.standard.bool(forKey: "IsRunning")
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Text("Timer")
                .font(.largeTitle)
                .padding()

            Text("\(formatTime(remainingTime))")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .padding()

            HStack(spacing: 20) {
                Button(action: startTimer) {
                    Text("Start")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: stopTimer) {
                    Text("Stop")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadTimerState)
        .onDisappear(perform: saveTimerState)
    }

    private func startTimer() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
                saveTimerState()
            } else {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        saveTimerState()
    }

    private func saveTimerState() {
        UserDefaults.standard.set(remainingTime, forKey: "RemainingTime")
        UserDefaults.standard.set(isRunning, forKey: "IsRunning")
    }

    private func loadTimerState() {
        remainingTime = UserDefaults.standard.double(forKey: "RemainingTime")
        isRunning = UserDefaults.standard.bool(forKey: "IsRunning")

        if isRunning {
            startTimer()
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
