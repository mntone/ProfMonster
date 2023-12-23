import Foundation

public protocol Entity: Identifiable, ObservableObject {
	var app: App? { get }
}
