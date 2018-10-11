struct FavoriteCellModel: FavoriteCellModelItem {

    let favorite: Favorite
    let isSearch = false
    let isSearchButton: Bool

    var name: String { return favorite.name }
}
