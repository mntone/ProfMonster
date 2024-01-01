import SwiftUI

extension ShapeStyle {
	// WARNING: This function has no quinary.
	static func hierarchical(_ level: Int) -> HierarchicalShapeStyle {
		switch level {
		case 1:
			HierarchicalShapeStyle.secondary
		case 2:
			HierarchicalShapeStyle.tertiary
		case 3...:
			HierarchicalShapeStyle.quaternary
		default:
			HierarchicalShapeStyle.primary
		}
	}
}
