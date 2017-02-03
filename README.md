[![Dub version](https://img.shields.io/dub/v/dlib-webp.svg)](https://code.dlang.org/packages/dlib-webp)
[![Build Status](https://travis-ci.org/georgy7/dlib-webp.svg?branch=master)](https://travis-ci.org/georgy7/dlib-webp)

## Testing

    dub test --debug=featureTest

## Usage

```d
import dlib.image;
import dlibwebp;

void main() {
  auto img = loadPNG("input.png");
  
  // 0 is the worst quality, 100 is the best.
  // But it is still YUV 4:2:0.
  img.saveWEBP(50, "quality50.webp");
  
  // And it is not.
  img.saveLosslessWEBP("lossless.webp");
  
  // You may want to use the streaming API
  // just like savePNG, saveTGA, etc.
  // auto res = img.saveWEBP(50, outputStream);
  
  // Also, you can save to arrays:
  // ubyte[] lossy = img.saveWEBPToArray(50);
  // ubyte[] lossless = img.saveLosslessWEBPToArray();
  
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

- **libwebp** BSD 3-clause
- **dlib** Boost Software License, Version 1.0
- **feature-test-d** (for testing) MIT
- **random-dlib-image** (for testing) Boost Software License, Version 1.0
