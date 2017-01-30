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

// TODO Alpha channel
Compound!(bool, string) saveWEBP(SuperImage img, OutputStream output) {
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
            100,
            &outputPointer);
    GC.addRange(outputPointer, outputSize);
    output.writeArray(outputPointer[0 .. outputSize]);
    return compound(true, "");
}


private void saveIt(SuperImage input, string filename) {
    OutputStream outputStream = openForOutput(filename);
    Compound!(bool, string) res = saveWEBP(cast(SuperImage)input, outputStream);
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
}
