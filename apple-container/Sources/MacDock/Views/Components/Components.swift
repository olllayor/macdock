import SwiftUI

enum StatColor {
    case blue, cyan, green, purple

    var iconColor: Color {
        switch self {
        case .blue:   return MacDockColors.chartBlue
        case .cyan:   return MacDockColors.chartCyan
        case .green:  return MacDockColors.chartGreen
        case .purple: return MacDockColors.chartPurple
        }
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: StatColor

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(MacDockColors.mutedForeground)
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(MacDockColors.foreground)
            }
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color.iconColor)
                .padding(12)
                .background(color.iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(20)
        .background(MacDockColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(MacDockColors.border, lineWidth: 1)
        )
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color
    var action: (() -> Void) = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func headerCell() -> some View {
        self.font(.system(.subheadline, weight: .semibold))
            .foregroundStyle(MacDockColors.foreground)
    }
}
