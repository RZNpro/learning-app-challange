import SwiftUI

/// بطاقة زجاجية فيها أيقونة + عدد الأيام + وصف (مثل "4 days / Learned").
/// أستخدمها في Activity وفي التقويم.
struct StatCard: View {
    let icon: String    // اسم أيقونة SF Symbol
    let tint: Color     // لون الأيقونة
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            // لو يوم واحد أكتب "day"، ولو أكثر "days". تفصيلة صغيرة بس تفرق.
            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.title3.bold())
            Text(label)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        // 🔷 Liquid Glass: `.glassEffect(.regular)` = زجاج Apple الأصلي، بدون لون عشان يبان التأثير.
        // `in: .rect(cornerRadius: 34)` = شكل مستطيل بزوايا دائرية.
        .glassEffect(.regular, in: .rect(cornerRadius: 34))
    }
}

/// `extension` + `static func` = طرق مختصرة أسوي فيها البطاقتين الجاهزتين.
/// بدل ما أكتب الأيقونة واللون كل مرة، أكتب `StatCard.learned(4)` وخلاص.
/// `label` له قيمة افتراضية، فما أحتاج أكتبه إلا لو أبي نص ثاني.
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
