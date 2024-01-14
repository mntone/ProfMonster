
public final class Settings {
	@UserDefault("trgSwipe", initial: SwipeAction.none)
	public var trailingSwipeAction: SwipeAction

	@UserDefault("linkSub", initial: true)
	public var linkSubspecies: Bool

#if os(macOS)
	@UserDefault("favInSearch", initial: true)
	public var includesFavoriteGroupInSearchResult: Bool
#elseif os(iOS)
	@UserDefault("favInSearch", initial: false)
	public var includesFavoriteGroupInSearchResult: Bool
#endif

	@UserDefault("elemDisp", initial: .sign)
	public var elementDisplay: WeaknessDisplayMode

	@UserDefault("mrgPart", initial: true)
	public var mergeParts: Bool

	@UserDefault("sort", initial: .inGame(reversed: false))
	public var sort: Sort

#if DEBUG
	@UserDefault("delayReq", initial: false)
	public var delayNetworkRequest: Bool

	@UserDefault("intlInfo", initial: true)
	public var showInternalInformation: Bool
#else
	@UserDefault("intlInfo", initial: false)
	public var showInternalInformation: Bool
#endif

	@UserDefault("_t", initial: "A")
	public var test: String
}
