import enum MonsterAnalyzerCore.Attack
import enum MonsterAnalyzerCore.Effectiveness
import struct MonsterAnalyzerCore.Weakness
import SwiftUI

struct CompactWeaknessView: View {
	let weakness: Weakness
	let itemWidth: CGFloat

	var body: some View {
		getElementView(weakness.fire, element: .fire)
		getElementView(weakness.water, element: .water)
		getElementView(weakness.thunder, element: .thunder)
		getElementView(weakness.ice, element: .ice)
		getElementView(weakness.dragon, element: .dragon)
	}

	@ViewBuilder
	private func getElementView(_ value: Effectiveness, element: Attack) -> some View {
		switch value {
		case .mostEffective:
			element.image
				.foregroundStyle(element.color)
				.accessibilityLabel(element.label(.long))
				.accessibilityValue("Most Effective")
		default:
			Never?.none
		}
	}
}
