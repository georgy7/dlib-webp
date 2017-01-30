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
}
```
