import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension View {
	@ViewBuilder
	public func onChangeBackport<V>(of value: V, initial: Bool = false, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View where V : Equatable {
		if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
			onChange(of: value, initial: initial, action)
		} else if initial {
			onAppear { action(value, value) }.onChange(of: value) { newValue in action(value, newValue) }
		} else {
			onChange(of: value) { newValue in action(value, newValue) }
		}
	}

	@ViewBuilder
	public func onChangeBackport<V>(of value: V, initial: Bool = false, _ action: @escaping () -> Void) -> some View where V : Equatable {
		if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
			onChange(of: value, initial: initial, action)
		} else if initial {
			onAppear(perform: action).onChange(of: value) { _ in action() }
		} else {
			onChange(of: value) { _ in action() }
		}
	}
}
