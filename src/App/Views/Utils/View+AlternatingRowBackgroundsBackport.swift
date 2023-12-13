import SwiftUI

@available(iOS, unavailable)
@available(macOS 12.0, *)
@available(watchOS, unavailable)
extension View {
	@ViewBuilder
	public func alternatingRowBackgroundsBackport(enable: Bool) -> some View {
		if #available(macOS 14.0, *) {
			alternatingRowBackgrounds(enable ? .enabled : .disabled)
		} else {
			listStyle(.inset(alternatesRowBackgrounds: enable))
		}
	}
}
