import UIKit

class TabBarViewController: UITabBarController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard let tabBarItems = tabBar.items else {
            tabBar.isHidden = true
            return
        }

        tabBar.left = 10
        tabBar.width = self.view.width - 20

        if isiPhoneX {
            tabBar.height = 63
            tabBar.top = self.view.height - tabBar.height
        } else {
            tabBar.height = 54
            tabBar.top = self.view.height - tabBar.height
        }

        if isiPhoneX { tabBar.roundedCorners([.bottomLeft, .bottomRight], radius: 35) }

        for i in 0 ..< tabBarItems.count {
            let tabBarItem = tabBarItems[i]

            switch tabBarItem.tag {
            case 1:
                tabBarItem.image = #imageLiteral(resourceName: "icon_list").withRenderingMode(.alwaysOriginal)
                tabBarItem.selectedImage = #imageLiteral(resourceName: "icon_list_highlighted").withRenderingMode(.alwaysOriginal)
            case 2:
                tabBarItem.image = #imageLiteral(resourceName: "icon_heart").withRenderingMode(.alwaysOriginal)
                tabBarItem.selectedImage = #imageLiteral(resourceName: "icon_heart_highlighted").withRenderingMode(.alwaysOriginal)
            case 3:
                tabBarItem.image = #imageLiteral(resourceName: "icon_bell").withRenderingMode(.alwaysOriginal)
                tabBarItem.selectedImage = #imageLiteral(resourceName: "icon_bell_highlighted").withRenderingMode(.alwaysOriginal)
            default:
                break
            }

            if isiPhoneX {
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 12)
                tabBarItem.imageInsets = UIEdgeInsets.init(top: 8, left: 0, bottom: -8, right: 0)
            } else {
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
                tabBarItem.imageInsets = UIEdgeInsets.init(top: -2, left: 0, bottom: 2, right: 0)
            }

            tabBarItem.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.blue5
            ], for: .normal)
            tabBarItem.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.blue6
            ], for: .selected)
        }
    }
}
