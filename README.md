# Scratch card

A small iOS app that models a scratch card. The card starts out unscratched. Scratching it reveals a code, and the code can then be used to activate the card.

The goal wasn't the app itself but getting two async behaviours right:

- **Scratching** takes 2 seconds and gets cancelled if you leave the screen before it finishes.
- **Activation** calls `https://api.o2.sk/version` and keeps going even if you leave the screen. The card is activated when the returned `ios` version is greater than 6.1, otherwise you get an error alert.

## Running it

Open `ScratchCard.xcodeproj` in Xcode 26 or newer(not tested on prior versions), run the `ScratchCard` scheme. The app targets iOS 17, uses SwiftUI and has no third-party dependencies.

## State

All of the app's state lives in `ScratchCardStore`. The app creates one store at launch and hands it to every screen, so the main, scratch and activation screens always agree on what the card looks like, even for work that finishes after you've left a screen.

The store is only kept in memory, so it lasts for one app session. Nothing is saved to disk. Kill the app and open it again and you're back to a fresh, unscratched card, which is handy for trying things again: getting a new code, or leaving a screen at a different moment to see what happens.

## Why there are prints

Cancellation is hard to see in the UI, since the screen is already gone when it happens. So the app prints a few lines to the Xcode console to show what's going on.

Leave the scratch screen before the 2 seconds are up:

```
Scratch started
Scratch screen closed
Scratch cancelled
```

Leave the activation screen while the request is still running:

```
Activation started
Activation screen closed
Activation finished
```

The last line shows up after the screen is closed, which is the point. If the API responds too fast to catch it, slow the network down with Network Link Conditioner. In a real app these would go through `Logger`. Here they're just a demo aid.

## A couple of details

- Versions are compared as `String`, not by turning them into `Double`s. As a `Double`, `6.10` would be smaller than `6.9`.
- The code is stored inside the `scratched` and `activated` states, so a card can't end up activated without a code.
- Tests pass in a zero duration and a fake API, so they run instantly. They cover scratching, cancellation, the version check, failed requests, double taps and the request URL.
