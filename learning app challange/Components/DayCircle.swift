import SwiftUI

/// Display data for one day cell, prepared by a ViewModel.
struct DayItem: Identifiable, Hashable {
    let date: Date
    let status: DayStatus?
    let isToday: Bool

    var id: Date { date }
}

/// A day number styled by how it was logged. Used by the week strip and the calendar.
struct DayCircle: View {
    let day: DayItem

    var body: some View {
        Text(day.date, format: .dateTime.day())
            .font(.title2.weight(isHighlightedToday ? .bold : .medium))
            .foregroundStyle(foreground)
            .frame(width: 44, height: 44)
            .background(background, in: .circle)
    }

    private var isHighlightedToday: Bool { day.isToday && day.status == nil }

    private var foreground: Color {
        switch day.status {
        case .learned: .learnOrange
        case .freezed: .freezeCyan
        case nil: isHighlightedToday ? .white : .primary
        }
    }

    private var background: Color {
        switch day.status {
        case .learned: .learnOrange.opacity(0.18)
        case .freezed: .freezeCyan.opacity(0.15)
        case nil: isHighlightedToday ? .learnOrange : .clear
        }
    }
}

#Preview {
    HStack {
        DayCircle(day: DayItem(date: .now, status: .learned, isToday: false))
        DayCircle(day: DayItem(date: .now, status: .freezed, isToday: false))
        DayCircle(day: DayItem(date: .now, status: nil, isToday: true))
        DayCircle(day: DayItem(date: .now, status: nil, isToday: false))
    }
}
