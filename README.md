<a href="https://code.dlang.org/packages/dlib-webp" title="Go to dlib-webp"><img src="https://img.shields.io/dub/v/dlib-webp.svg" alt="Dub version"></a>

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
  auto readedBack = loadWEBP("lossless.webp");
  readedBack.savePNG("lossless.png");
  
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
- **random-dlib-image** (for testing) Boost Software License, Version 1.0
