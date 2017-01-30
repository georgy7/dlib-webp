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
}

SuperImage loadWEBP(InputStream istrm) {
    return null;
}

Compound!(bool, string) saveWEBP(SuperImage img, int quality, OutputStream output) {
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
    output.writeArray(outputPointer[0 .. outputSize]);
    return compound(true, "");
}


private void saveIt(SuperImage input, string filename) {
    OutputStream outputStream = openForOutput(filename);
    Compound!(bool, string) res = saveWEBP(cast(SuperImage)input, 85, outputStream);
    outputStream.close();
    assert(res[0]);
}

unittest {

    SuperImage input = RandomImages.circles(1920, 1080);
    string filename = "test1.webp";
    saveIt(input, filename);

    auto input2 = convert!(Image!(PixelFormat.L8))(RandomImages.circles(1920, 1080));
    saveIt(input2, "test2.webp");

    auto input3 = convert!(Image!(PixelFormat.RGBA16))(RandomImages.circles(1920, 1080));
    saveIt(input3, "test3.webp");

    SuperImage red = new Image!(PixelFormat.RGBA8)(500, 400);
    foreach(int x; 0..red.width) {
        foreach(int y; 0..red.height) {
            red[x, y] = Color4f(1f, 0f,0f,0.8f);
        }
    }
    saveIt(red, "red.webp");
}
