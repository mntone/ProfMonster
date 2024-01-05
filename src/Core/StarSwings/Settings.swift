
public final class Settings {
#if os(iOS)
	@UserDefault("showTitle", initial: true)
	public var showTitle: Bool
#endif

#if !os(macOS)
	@UserDefault("trgSwipe", initial: SwipeAction.none)
	public var trailingSwipeAction: SwipeAction
#endif

#if os(macOS)
	@UserDefault("incFavInSearch", initial: true)
	public var includesFavoriteGroupInSearchResult: Bool
#elseif os(iOS)
	@UserDefault("incFavInSearch", initial: false)
	public var includesFavoriteGroupInSearchResult: Bool
#endif

	@UserDefault("elemDisp", initial: .sign)
	public var elementDisplay: WeaknessDisplayMode

	@UserDefault("mrgPart", initial: true)
	public var mergeParts: Bool

	@UserDefault("sort", initial: .inGame)
	public var sort: Sort

#if DEBUG
	@UserDefault("intlInfo", initial: true)
	public var showInternalInformation: Bool
#else
	@UserDefault("intlInfo", initial: false)
	public var showInternalInformation: Bool
#endif
}
