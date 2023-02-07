import Foundation
protocol Store {
    func sell(count: Int)
}
class FoodStore: Store {
    func sell(count: Int) {
        print("食品商店卖了\(count)食物")
    }
}
class ClothStore: Store {
    func sell(count: Int) {
        print("服装商店卖了\(count)服装")
    }
}
class Customer {
    func buy(store: Store, count: Int) {
        print("购物--")
        store.sell(count: count)
    }
}
let customer = Customer()
customer.buy(store: FoodStore(), count: 4)
customer.buy(store: ClothStore(), count: 2)
