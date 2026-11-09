import SwiftUI

/// Rounded glass card showing an icon, a day count and a caption ("4 days · Learned").
struct StatCard: View {
    let icon: String
    let tint: Color
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.title3.bold())
            Text(label)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .glassEffect(.regular.tint(.cardFill), in: .rect(cornerRadius: 34))
    }
}

extension StatCard {
    static func learned(_ count: Int, label: String = "Learned") -> StatCard {
        StatCard(icon: "flame.fill", tint: .learnOrange, count: count, label: label)
    }

    static func freezed(_ count: Int, label: String = "Freezed") -> StatCard {
        StatCard(icon: "snowflake", tint: .freezeCyan, count: count, label: label)
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCard.learned(4)
        StatCard.freezed(1)
    }
    .padding()
}
