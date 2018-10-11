struct SearchCellModel: FavoriteCellModelItem {

    let stop: Stop
    let isSearch = true
    let isSearchButton = false

    var name: String { return stop.name }
}

