
public final class Settings {
#if os(iOS)
	@UserDefault("showTitle", initial: true)
	public var showTitle: Bool
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
}
