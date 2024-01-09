import enum MonsterAnalyzerCore.Attack
import SwiftUI

struct MonsterListItem_TestA: View {
#if !os(macOS)
	@ScaledMetric(relativeTo: .caption)
	private var itemWidth: CGFloat = 12.0
#endif

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	var body: some View {
		if let weakness = viewModel.weaknesses?["default"] {
#if os(macOS)
			CompactWeaknessView(weakness: weakness, itemWidth: 10.0)
				.font(.caption.weight(.light))
				.padding(.leading, 4)
#else
			CompactWeaknessView(weakness: weakness, itemWidth: itemWidth)
				.font(.caption.weight(.light))
				.padding(.leading, 6)
#endif
		}

		if viewModel.isFavorited {
			Spacer()
			Image(systemName: "star.fill")
				.foregroundStyle(.yellow)
				.accessibilityLabel("Favorited")
				.transition(.opacity)
		}
	}
}

struct MonsterListItem_TestB: View {
#if !os(macOS)
	@ScaledMetric(relativeTo: .callout)
	private var itemWidth: CGFloat = 16.0
#endif

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	var body: some View {
		if let weakness = viewModel.weaknesses?["default"] {
			Spacer()
#if os(macOS)
			CompactWeaknessView(weakness: weakness, itemWidth: 12.0)
				.font(.callout.weight(.light))
				.padding(.trailing, 4)
#else
			CompactWeaknessView(weakness: weakness, itemWidth: itemWidth)
				.font(.callout.weight(.light))
				.padding(.trailing, 6)
#endif

			Image(systemName: "star.fill")
				.foregroundStyle(.yellow)
				.accessibilityLabel("Favorited")
				.opacity(viewModel.isFavorited ? 1 : 0)
				.transition(.opacity)
		} else if viewModel.isFavorited {
			Spacer()
			Image(systemName: "star.fill")
				.foregroundStyle(.yellow)
				.accessibilityLabel("Favorited")
				.transition(.opacity)
		}
	}
}

struct MonsterListItem: View {
	@Environment(\.settings)
	private var settings

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	var body: some View {
		HStack(spacing: 0) {
			Text(viewModel.name)
			switch settings?.test {
			case "B":
				MonsterListItem_TestB(viewModel: viewModel)
			default:
				MonsterListItem_TestA(viewModel: viewModel)
			}
		}
		.animation(.easeInOut(duration: 0.1), value: viewModel.isFavorited)
#if !os(watchOS)
		.contextMenu {
			FavoriteContextMenuButton(favorite: $viewModel.isFavorited)
		}
#endif
#if !os(macOS)
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			switch settings?.trailingSwipeAction {
			case Optional.none, .some(.none):
				EmptyView()
			case .favorite:
				FavoriteSwipeButton(favorite: $viewModel.isFavorited)
			}
		}
#endif
	}
}

#if DEBUG || targetEnvironment(simulator)
#Preview {
	let viewModel = GameItemViewModel(id: "mockgame:gulu_qoo")!
	return List {
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
	}
}
#endif
