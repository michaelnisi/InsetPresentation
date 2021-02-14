# InsetPresentation

The InsetPresentation Swift package provides modal presentation, blatantly snatched from [Daniel Gauthier](https://danielgauthier.me/2020/02/24/indie5-1.html).

```
+---------------------+
|                     |
|  +---------------+  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  |               |  |
|  +---------------+  |
|                     |
+---------------------+
```

## Example

Example call site might look like this.

```swift
let insets = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)

self?.present(vc, interactiveDismissalType: .vertical, insets: insets) {
  completion?()
}
```

## Install

📦 Add `https://github.com/michaelnisi/InsetPresentation` to your package manifest.

## License

[MIT License](https://github.com/michaelnisi/InsetPresentation/blob/master/LICENSE)
