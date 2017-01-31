module dlibwebp;

private {
    import dlib.image;
    import randomdlibimage;
    import webp.encode;
    import webp.decode;
    import dlib.core.compound;
    import dlib.core.stream;
    import dlib.filesystem.local;
    import core.memory : GC;
    import std.array;
}

class WEBPLoadException: ImageLoadException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

SuperImage loadWEBP(string filename) {
    InputStream input = openForInput(filename);
    auto img = loadWEBP(input);
    input.close();
    return img;
}

SuperImage loadWEBP(InputStream input) {
    auto fileContent = appender!(ubyte[])();
    ubyte[0x1000] buffer;
    while (input.readable) {
        size_t count = input.readBytes(buffer.ptr, buffer.length);
        if (count == 0) {
            break;
        }
        for (int i = 0; i < count; i++) {
            fileContent.put(buffer[i]);
        }
    }
    return loadWEBPFromArray(fileContent.data);
}

SuperImage loadWEBPFromArray(in ubyte[] webp) {
    int width;
    int height;
    ubyte* argbPointer = WebPDecodeRGBA(webp.ptr, webp.length, &width, &height);
    GC.addRange(argbPointer, (width * height * 4));
    ubyte[] argbArray = argbPointer[0 .. (width * height * 4)];

    SuperImage rgbaImage = defaultImageFactory.createImage(width, height, 4, 8);
    foreach(i, v; argbArray) {
        rgbaImage.data[i] = v;
    }
    return rgbaImage;
}


void saveWEBP(SuperImage img, int quality, string filename) {
    OutputStream output = openForOutput(filename);
    Compound!(bool, string) res = saveWEBP(img, quality, output);
    output.close();

    if (!res[0]) {
        throw new WEBPLoadException(res[1]);
    }
}
void saveLosslessWEBP(SuperImage img, string filename) {
    OutputStream output = openForOutput(filename);
    Compound!(bool, string) res = saveLosslessWEBP(img, output);
    output.close();

    if (!res[0]) {
        throw new WEBPLoadException(res[1]);
    }
}

Compound!(bool, string) saveWEBP(SuperImage img, int quality, OutputStream output) {
    ubyte[] result = saveWEBPToArray(img, quality);
    output.writeArray(result);
    return compound(true, "");
}
Compound!(bool, string) saveLosslessWEBP(SuperImage img, OutputStream output) {
    ubyte[] result = saveLosslessWEBPToArray(img);
    output.writeArray(result);
    return compound(true, "");
}

ubyte[] saveWEBPToArray(SuperImage img, int quality) {
    if (PixelFormat.L8 == img.pixelFormat ||
            PixelFormat.RGB8 == img.pixelFormat ||
            PixelFormat.L16 == img.pixelFormat ||
            PixelFormat.RGB16 == img.pixelFormat) {
        return saveLossy(img, quality);
    } else {
        return saveLossyWithAlpha(img, quality);
    }
}
ubyte[] saveLosslessWEBPToArray(SuperImage img) {
    if (PixelFormat.L8 == img.pixelFormat ||
            PixelFormat.RGB8 == img.pixelFormat ||
            PixelFormat.L16 == img.pixelFormat ||
            PixelFormat.RGB16 == img.pixelFormat) {
        return saveLossless(img);
    } else {
        return saveLosslessWithAlpha(img);
    }
}


private ubyte[] saveLossyWithAlpha(SuperImage img, int quality) {
    SuperImage inputImage = img;
    if (PixelFormat.RGBA8 != img.pixelFormat) {
        inputImage = convert!(Image!(PixelFormat.RGBA8))(img);
    }
    ubyte* outputPointer;
    size_t outputSize = WebPEncodeRGBA(
            inputImage.data.ptr,
            img.width(),
            img.height(),
            img.width() * 4,
            quality,
            &outputPointer);
    GC.addRange(outputPointer, outputSize);
    return outputPointer[0 .. outputSize];
}
private ubyte[] saveLossy(SuperImage img, int quality) {
    SuperImage inputImage = img;
    if (PixelFormat.RGB8 != img.pixelFormat) {
        inputImage = convert!(Image!(PixelFormat.RGB8))(img);
    }
    ubyte* outputPointer;
    size_t outputSize = WebPEncodeRGB(
            inputImage.data.ptr,
            img.width(),
            img.height(),
            img.width() * 3,
            quality,
            &outputPointer);
    GC.addRange(outputPointer, outputSize);
    return outputPointer[0 .. outputSize];
}

private ubyte[] saveLosslessWithAlpha(SuperImage img) {
    SuperImage inputImage = img;
    if (PixelFormat.RGBA8 != img.pixelFormat) {
        inputImage = convert!(Image!(PixelFormat.RGBA8))(img);
    }
    ubyte* outputPointer;
    size_t outputSize = WebPEncodeLosslessRGBA(
            inputImage.data.ptr,
            img.width(),
            img.height(),
            img.width() * 4,
            &outputPointer);
    GC.addRange(outputPointer, outputSize);
    return outputPointer[0 .. outputSize];
}
private ubyte[] saveLossless(SuperImage img) {
    SuperImage inputImage = img;
    if (PixelFormat.RGB8 != img.pixelFormat) {
        inputImage = convert!(Image!(PixelFormat.RGB8))(img);
    }
    ubyte* outputPointer;
    size_t outputSize = WebPEncodeLosslessRGB(
            inputImage.data.ptr,
            img.width(),
            img.height(),
            img.width() * 3,
            &outputPointer);
    GC.addRange(outputPointer, outputSize);
    return outputPointer[0 .. outputSize];
}


private void saveIt(SuperImage input, string filename) {
    OutputStream outputStream = openForOutput(filename);
    Compound!(bool, string) res = saveWEBP(cast(SuperImage)input, 85, outputStream);
    outputStream.close();
    assert(res[0]);
}

unittest {
    SuperImage input = RandomImages.circles(500, 400);
    string filename = "test_simple.webp";
    saveIt(input, filename);

    auto inputL8 = convert!(Image!(PixelFormat.L8))(RandomImages.circles(500, 400));
    saveIt(inputL8, "test_L8.webp");

    auto inputLA8 = convert!(Image!(PixelFormat.LA8))(RandomImages.circles(500, 400));
    saveIt(inputLA8, "test_LA8.webp");

    auto inputRgba16 = convert!(Image!(PixelFormat.RGBA16))(RandomImages.circles(1920, 1080));
    saveIt(inputRgba16, "test_RGBA16.webp");

    SuperImage red = new Image!(PixelFormat.RGBA8)(500, 400);
    foreach(int x; 0..red.width) {
        foreach(int y; 0..red.height) {
            red[x, y] = Color4f(1f, 0f,0f,0.8f);
        }
    }
    saveIt(red, "red_RGBA8.webp");
}

unittest {
    auto img = RandomImages.circles(500, 400);
    saveWEBP(img, 100, "test_to_file.webp");
    saveLosslessWEBP(img, "test_to_file_lossless.webp");
    auto readedBack = loadWEBP("test_to_file_lossless.webp");
    readedBack.savePNG("test_to_file.png");
}
