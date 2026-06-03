import Foundation

protocol CountdownTimerDelegate: AnyObject {
    // Called every second with the number of seconds still on the clock
    func countdownTimer(_ timer: CountdownTimer, didTick secondsRemaining: Int)
    // Called once when the clock reaches zero
    func countdownTimerDidExpire(_ timer: CountdownTimer)
}

class CountdownTimer {

    private let totalSeconds: Int
    private(set) var secondsRemaining: Int

    weak var delegate: CountdownTimerDelegate?
    private var internalTimer: Timer?

    init(delegate: CountdownTimerDelegate, duration: Int = 5) {
        self.delegate       = delegate
        self.totalSeconds   = duration
        self.secondsRemaining = duration
    }


    // New countdown
    func begin() {
        cancel()
        secondsRemaining = totalSeconds
        delegate?.countdownTimer(self, didTick: secondsRemaining)
        scheduleRepeatingTick()
    }

    // Stop the clock and clean up
    func cancel() {
        internalTimer?.invalidate()
        internalTimer = nil
    }

    func continueFromPause() {
        cancel()
        delegate?.countdownTimer(self, didTick: secondsRemaining)
        scheduleRepeatingTick()
    }


    private func scheduleRepeatingTick() {
        internalTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] t in
            self?.tick(t)
        }
    }

    private func tick(_ t: Timer) {
        secondsRemaining -= 1
        delegate?.countdownTimer(self, didTick: secondsRemaining)

        if secondsRemaining <= 0 {
            t.invalidate()
            delegate?.countdownTimerDidExpire(self)
        }
    }
}
