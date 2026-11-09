import SwiftUI

/// A day number styled by how it was logged. Used by the week strip and the calendar.
struct DayCircle: View {
    let date: Date
    let status: DayStatus?
    var isToday = false

    var body: some View {
        Text(date, format: .dateTime.day())
            .font(.title2.weight(isHighlightedToday ? .bold : .medium))
            .foregroundStyle(foreground)
            .frame(width: 44, height: 44)
            .background(background, in: .circle)
    }

    private var isHighlightedToday: Bool { isToday && status == nil }

    private var foreground: Color {
        switch status {
        case .learned: .learnOrange
        case .freezed: .freezeCyan
        case nil: isHighlightedToday ? .white : .primary
        }
    }

    private var background: Color {
        switch status {
        case .learned: .learnOrange.opacity(0.18)
        case .freezed: .freezeCyan.opacity(0.15)
        case nil: isHighlightedToday ? .learnOrange : .clear
        }
    }
}

#Preview {
    HStack {
        DayCircle(date: .now, status: .learned)
        DayCircle(date: .now, status: .freezed)
        DayCircle(date: .now, status: nil, isToday: true)
        DayCircle(date: .now, status: nil)
    }
}
