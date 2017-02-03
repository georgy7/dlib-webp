module dlibwebp;

private {
    import dlib.image;
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
    return loadWEBP(fileContent.data);
}

SuperImage loadWEBP(in ubyte[] webp) {
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

/*
private void saveIt(SuperImage input, string filename) {
    OutputStream outputStream = openForOutput(filename);
    Compound!(bool, string) res = saveWEBP(cast(SuperImage)input, 85, outputStream);
    outputStream.close();
    assert(res[0]);
}
*/



/**
 * Run the tests like this:
 * dub test --debug=featureTest
 *
 */
debug (featureTest) {
    import feature_test;
    import randomdlibimage;
    import std.math;

    private SuperImage createImageWithColour(PixelFormat format)(int w, int h, Color4f c) {
        SuperImage img = new Image!(format)(w, h);
        foreach(int x; 0..img.width) {
            foreach(int y; 0..img.height) {
                img[x, y] = c;
            }
        }
        return img;
    }
    private void colorTestLossless(PixelFormat format)(in string fn, Color4f c) {
        {
            SuperImage redNonTransparent = createImageWithColour!(format)(500, 400, c);
            redNonTransparent.saveLosslessWEBP(fn);
        }
        SuperImage result = loadWEBP(fn);
        foreach(int x; 0..result.width) {
            foreach(int y; 0..result.height) {
                // WebP supports maximum 8-bit per channel.
                Color4 expected = c.convert(8);
                Color4 actual = result[x, y].convert(8);
                expected.r.shouldEqual(actual.r);
                expected.g.shouldEqual(actual.g);
                expected.b.shouldEqual(actual.b);
                expected.a.shouldEqual(actual.a);
            }
        }
    }

    private void assertTheSame8bitWithAlpha(SuperImage source, SuperImage result) {
        foreach(int x; 0..result.width) {
            foreach(int y; 0..result.height) {
                Color4 expected = source[x, y].convert(8);
                Color4 actual = result[x, y].convert(8);
                expected.r.shouldEqual(actual.r);
                expected.g.shouldEqual(actual.g);
                expected.b.shouldEqual(actual.b);
                expected.a.shouldEqual(actual.a);
            }
        }
    }

    unittest {

        feature("Filesystem i/o RGBA8. Lossless.", (f) {
            f.scenario("Red 1.0", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "lossless_RGBA8_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "lossless_RGBA8_red_0.5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "lossless_RGBA8_red_0.01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "lossless_RGBA8_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "lossless_RGBA8_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Blue 1.0. Opacity 0.8.", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "lossless_RGBA8_blue_alpha_0.8.webp",
                    Color4f(0f, 0f, 1f, 0.8f)
                );
            });
            f.scenario("Random.", {
                const fn = "lossless_RGBA8_random.webp";

                SuperImage img = RandomImages.circles!(PixelFormat.RGBA8)(500, 400);
                // Alpha pixel.
                img[0, 0] = Color4f(
                    img[0, 0].r,
                    img[0, 0].g,
                    img[0, 0].b,
                    0.8f);
                img.saveLosslessWEBP(fn);

                SuperImage result = loadWEBP(fn);
                abs(result[0, 0].a - 0.8f).shouldBeLessThan(0.02f); // Alpha pixel!
                abs(result[1, 0].a - 1.0f).shouldBeLessThan(0.01f);
                assertTheSame8bitWithAlpha(img, result);
            });
        });


        feature("Filesystem i/o RGBA16. Lossless.", (f) {
            f.scenario("Red 1.0", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "lossless_RGBA16_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "lossless_RGBA16_red_0.5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "lossless_RGBA16_red_0.01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "lossless_RGBA16_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "lossless_RGBA16_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Blue 1.0. Opacity 0.8.", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "lossless_RGBA16_blue_alpha_0.8.webp",
                    Color4f(0f, 0f, 1f, 0.8f)
                );
            });
            f.scenario("Random.", {
                const fn = "lossless_RGBA16_random.webp";

                SuperImage img = RandomImages.circles!(PixelFormat.RGBA16)(500, 400);
                // Alpha pixel.
                img[0, 0] = Color4f(
                    img[0, 0].r,
                    img[0, 0].g,
                    img[0, 0].b,
                    0.8f);
                img.saveLosslessWEBP(fn);

                SuperImage result = loadWEBP(fn);
                abs(result[0, 0].a - 0.8f).shouldBeLessThan(0.02f); // Alpha pixel!
                abs(result[1, 0].a - 1.0f).shouldBeLessThan(0.01f);
                assertTheSame8bitWithAlpha(img, result);
            });
        });

        feature("Filesystem i/o RGB-8. Lossless.", (f) {
            f.scenario("Red 1.0", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "lossless_RGB8_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "lossless_RGB8_red_0.5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "lossless_RGB8_red_0.01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "lossless_RGB8_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "lossless_RGB8_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Random.", {
                const fn = "lossless_RGB8_random.webp";
                SuperImage source = RandomImages.circles!(PixelFormat.RGB8)(500, 400);
                source.saveLosslessWEBP(fn);
                SuperImage result = loadWEBP(fn);
                assertTheSame8bitWithAlpha(source, result);
            });
        });


        feature("Filesystem i/o RGB-16. Lossless.", (f) {
            f.scenario("Red 1.0", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "lossless_RGB16_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "lossless_RGB16_red_0.5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "lossless_RGB16_red_0.01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "lossless_RGB16_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "lossless_RGB16_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Random.", {
                const fn = "lossless_RGB16_random.webp";
                SuperImage source = RandomImages.circles!(PixelFormat.RGB16)(500, 400);
                source.saveLosslessWEBP(fn);
                SuperImage result = loadWEBP(fn);
                // WebP supports only 8 bits per channel anyway.
                // And alpha channel will equal 1, just like in the source image.
                assertTheSame8bitWithAlpha(source, result);
            });
        });
    }
}


/*
unittest {
    import randomdlibimage;

    SuperImage input = RandomImages.circles(500, 400);
    string filename = "test_simple.webp";
    saveIt(input, filename);

    auto inputL8 = convert!(Image!(PixelFormat.L8))(RandomImages.circles(500, 400));
    saveIt(inputL8, "test_L8.webp");

    auto inputLA8 = convert!(Image!(PixelFormat.LA8))(RandomImages.circles(500, 400));
    saveIt(inputLA8, "test_LA8.webp");

    auto inputRgba16 = convert!(Image!(PixelFormat.RGBA16))(RandomImages.circles(1920, 1080));
    saveIt(inputRgba16, "test_RGBA16.webp");
}

*/