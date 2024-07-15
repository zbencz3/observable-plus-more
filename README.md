# Observation in UIKit plus more

Just having some fun with the [Observation](https://developer.apple.com/documentation/observation) framework and its usage in UIKit to drive a UIViewController through a model using the new observations tools. 
This project is exploring the concepts introduced in the PointFree [Modern UIKit: Tree-based Navigation](https://www.pointfree.co/episodes/ep286-modern-uikit-tree-based-navigation) episode (backported to iOS 13 or so)
The UIKit views are deliberately using older techniques, just to show off how can an older codebase adopt this way of doing things. I am sure things can be improved there, but wasn't the focus.

The key parts are:
- the `observe` blocks that react to various properties of the model and either update the UI or present screens if needed.
- the enum based navigation where you have an optional destination enum which clearly defines the possible screens we can go to.
- view as the function of state setup where you can jump to any screen at app start by specifying the destination, e.g. the following if
the destination is specified would take you directly to the trading screen when passed in for the `BitcoinTabViewController`:
```
        let bitcoinTabViewModel = BitcoinTabViewModel(
            service: service,
            destination: .trade(
                direction: .buy,
                sourceCurrency: .usd,
                destinationCurrency: .btc
            )
        )
```
- testing the model.

Pretty cool!
Of course this can be done with ReactiveSwift or any similar framework, but the interesting part here is of course the fact that it's done with the Observation framework, which is not normally associated with UIKit, but with SwiftUI. So seeing the SwiftUI type of setup work with UIKit is such a treat!
