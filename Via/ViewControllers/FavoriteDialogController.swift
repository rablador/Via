import UIKit

class FavoriteDialogController: UIAlertController {

    private var favorite: Favorite?
    private var completion: ValueCallback<Favorite>?

    convenience init(favorite: Favorite? = nil, completion: ValueCallback<Favorite>? = nil) {
        let title = favorite.isNil ? "Lägg till favorit" : "Ändra favorit"
        self.init(title: title, message: "\nVälj ett namn:\n", preferredStyle: .alert)

        self.favorite = favorite
        self.completion = completion

        setup()
    }

    private func setup() {
        addTextField { [unowned self] textField in
            textField.text = self.favorite?.name ?? ""
            textField.autocapitalizationType = .sentences
            textField.keyboardAppearance = .dark

            textField.addTarget(self, action: #selector(self.dialogTextChanged(sender:)), for: .editingChanged)
        }

        addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned self] _ in
            let name = self.textFields?.first?.text ?? ""

            var favorite: Favorite

            if self.favorite.isNil {
                favorite = Favorite(name: name, stops: [Stop]())
                favorite.save()
            } else {
                favorite = self.favorite!
                favorite.name = name
                favorite.save()
            }

            self.completion?(favorite)
        }))

        actions.first?.isEnabled = favorite.isNil ? false : true

        addAction(UIAlertAction(title: "Avbryt", style: .cancel))
    }

    @objc private func dialogTextChanged(sender: UITextField) {
        let name = sender.text ?? ""

        if name.isEmpty {
            actions.first?.isEnabled = false
            message = "\nNamn får inte vara tomt.\n"
        } else {
            let existingNames = StopDataHandler.shared.favorites.map { $0.name }.filter { $0 != self.favorite?.name }

            if existingNames.contains(name) {
                actions.first?.isEnabled = false
                message = "\nFavorit existerar redan.\n"
            } else {
                actions.first?.isEnabled = true
                message = "\n\n"
            }
        }
    }
}
