struct FavoriteStopSectionCellModel {

    let favorite: Favorite

    var title: String { return favorite.name }
    var stops: [Stop] { return favorite.stops }
}

extension FavoriteStopSectionCellModel: Equatable {

    static func ==(lhs: FavoriteStopSectionCellModel, rhs: FavoriteStopSectionCellModel) -> Bool {
        return lhs.title == rhs.title
    }
}
