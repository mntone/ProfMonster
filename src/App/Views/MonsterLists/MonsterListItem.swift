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

struct _MonsterListItemStatic: View {
	let viewModel: GameItemViewModel

	@Environment(\.settings)
	private var settings

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
	}
}

struct MonsterListItem<Container: View>: View {
	@Environment(\.settings)
	private var settings

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	let container: (_MonsterListItemStatic) -> Container

	init(viewModel: GameItemViewModel) where Container == _MonsterListItemStatic {
		self.viewModel = viewModel
		self.container = { content in content }
	}

	init(viewModel: GameItemViewModel,
		 container: @escaping (_MonsterListItemStatic) -> Container) {
		self.viewModel = viewModel
		self.container = container
	}

	var body: some View {
		container(_MonsterListItemStatic(viewModel: viewModel))
#if !os(watchOS)
			.contextMenu {
				FavoriteContextMenuButton(favorite: $viewModel.isFavorited)

				if #available(iOS 16.0, macOS 13.0, *) {
					OpenWindowButton(id: viewModel.id)
				}
			}
#endif
			.block { content in
				switch settings?.trailingSwipeAction {
				case Optional.none, .some(.none):
					content
				case .favorite:
					content.swipeActions(edge: .trailing, allowsFullSwipe: false) {
						FavoriteSwipeButton(favorite: $viewModel.isFavorited)
					}
				}
			}
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
