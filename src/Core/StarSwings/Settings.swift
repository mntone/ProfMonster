import SwiftUI

public final class Settings {
	@UserDefault("elemDisp", initial: .sign)
	public var elementDisplay: WeaknessDisplayMode
}
