[![Dub version](https://img.shields.io/dub/v/dlib-webp.svg)](https://code.dlang.org/packages/dlib-webp)
[![Build Status](https://travis-ci.org/georgy7/dlib-webp.svg?branch=master)](https://travis-ci.org/georgy7/dlib-webp)
[![Coverage Status](https://coveralls.io/repos/github/georgy7/dlib-webp/badge.svg?branch=master)](https://coveralls.io/github/georgy7/dlib-webp?branch=master)

## Testing

    dub test --debug=featureTest

## Usage

```d
import dlib.image;
import dlibwebp;

void main() {
  auto img = loadPNG("input.png");

  // Medium quality.
  img.saveWEBP("quality.webp");

  img.saveWEBP("q50.webp", 50);

  img.saveWEBP("hq.webp", WEBPQuality.HIGH);

  // But it is still YUV 4:2:0.
  img.saveWEBP("q100.webp", WEBPQuality.HIGHEST);

  // And it is not.
  img.saveWEBP("lossless.webp", WEBPQuality.LOSSLESS);

  // You may want to use the streaming API
  // just like savePNG, saveTGA, etc.
  // auto res = img.saveWEBP(outputStream, 50);

  // Also, you can save to arrays:
  // ubyte[] lossy = img.saveWEBPToArray();
  // ubyte[] lossy50 = img.saveWEBPToArray(50);
  // ubyte[] lossless = img.saveWEBPToArray(WEBPQuality.LOSSLESS);

  // And back.
  auto readBack = loadWEBP("lossless.webp");
  readBack.savePNG("lossless.png");

  // Also available:
  // loadWEBP(inputStream)
  // loadWEBP(ubyte[])
}
```

## License

Boost Software License, Version 1.0 http://www.boost.org/LICENSE_1_0.txt

Dependencies:

- **[libwebp](https://code.dlang.org/packages/libwebp)** BSD 3-clause
- **[dlib](https://github.com/gecko0307/dlib/)** Boost Software License, Version 1.0
- **[feature-test-d](https://github.com/dmonagle/feature-test-d)** (for testing) MIT
