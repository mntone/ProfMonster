import enum MonsterAnalyzerCore.Attack
import enum MonsterAnalyzerCore.SwipeAction
import SwiftUI

#if os(iOS)

struct MonsterListItemContent: View {
	@ScaledMetric(relativeTo: .footnote)
	private var favoriteIconWidth: CGFloat = 13.0

	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0

	@ScaledMetric(relativeTo: .caption)
	private var itemWidth: CGFloat = 12.0

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	var body: some View {
		HStack(spacing: 6.0) {
			Image(systemName: "star.fill")
				.foregroundStyle(.yellow)
				.imageScale(.small)
				.frame(width: favoriteIconWidth)
				.opacity(viewModel.isFavorited ? 1.0 : 0.0)
				.accessibilityLabel("Favorited")
				.transition(.opacity)

			Text(viewModel.name)

			Spacer(minLength: 8.0)

			if let weakness = viewModel.weaknesses?["default"] {
				CompactWeaknessView(weakness: weakness, itemWidth: itemWidth)
					.font(.footnote.weight(.light))
			}
		}
		.animation(.easeInOut(duration: 0.1), value: viewModel.isFavorited)
		.padding(EdgeInsets(top: verticalPadding,
							leading: 0.0,
							bottom: verticalPadding,
							trailing: 0.0))
		.block { content in
			if #available(iOS 16.0, *) {
				content.alignmentGuide(.listRowSeparatorLeading) { _ in
					verticalPadding + favoriteIconWidth - 4.0
				}
			} else {
				content
			}
		}
	}
}

#else

struct MonsterListItemContent: View {
#if !os(macOS)
	@ScaledMetric(relativeTo: .caption)
	private var itemWidth: CGFloat = 12.0
#endif

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	var body: some View {
		HStack(spacing: 0) {
			Text(viewModel.name)

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
				Spacer(minLength: 8.0)
				Image(systemName: "star.fill")
					.foregroundStyle(.yellow)
					.accessibilityLabel("Favorited")
					.transition(.opacity)
			}
		}
		.animation(.easeInOut(duration: 0.1), value: viewModel.isFavorited)
	}
}

#endif

struct MonsterListItem<Container: View>: View {
	@AppStorage(settings: \.trailingSwipeAction)
	private var trailingSwipeAction: SwipeAction

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	let container: (MonsterListItemContent) -> Container

	init(viewModel: GameItemViewModel) where Container == MonsterListItemContent {
		self.viewModel = viewModel
		self.container = { content in content }
	}

	init(viewModel: GameItemViewModel,
		 container: @escaping (MonsterListItemContent) -> Container) {
		self.viewModel = viewModel
		self.container = container
	}

	var body: some View {
		container(MonsterListItemContent(viewModel: viewModel))
#if !os(watchOS)
			.contextMenu {
				FavoriteContextMenuButton(favorite: $viewModel.isFavorited)

				if #available(iOS 16.0, macOS 13.0, *) {
					OpenWindowButton(id: viewModel.id)
				}
			}
#endif
			.block { content in
				switch trailingSwipeAction {
				case .none:
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
