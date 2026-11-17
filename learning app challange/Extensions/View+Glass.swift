import SwiftUI

// مجلد Extensions = إضافات على أنواع Apple الجاهزة (هنا على View).

extension View {
    /// 🔷 Liquid Glass: اختار شكل الزر الزجاجي حسب حالته.
    /// - لو الزر متاح: `.glassProminent` = زجاج ملوّن بارز (برتقالي أو سماوي).
    /// - لو الزر خلص أو مو متاح: `.glass` = زجاج عادي رمادي، بس يبقى زجاج.
    ///
    /// ليش سويتها؟ لأن `.disabled` يحوّل الزجاج لشكل رمادي مسطح ويروح التأثير.
    ///
    /// `@ViewBuilder` = يخليني أستخدم `if/else` وأرجّع View مختلف في كل حالة.
    @ViewBuilder
    func glassButtonStyle(isProminent: Bool) -> some View {
        if isProminent {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.glass)
        }
    }
}
