module dlibwebp.spec;

import dlibwebp.api;
import dlib.image;
import std.exception;
import exceptions;

/**
 * Run the tests like this:
 * dub test --debug=featureTest
 *
 */
debug (featureTest) {
    import feature_test;
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

        import dlibwebp.random;

        feature("Filesystem errors.", (f) {
            f.scenario("Invalid filename lossless.", {
                auto invalidFileName = "tttest";
                for (int i = 0; i < 10000; i++) {
                    invalidFileName ~= "_";
                }
                invalidFileName ~= "test:*?.webp";

                // Invalid for the most of file systems.
                // https://en.wikipedia.org/wiki/Comparison_of_file_systems#Limits

                bool thrownIoException = false;
                try {
                    colorTestLossless!(PixelFormat.RGBA8)(
                        invalidFileName,
                        Color4f(1f, 0f, 0f, 1f)
                    );
                } catch (IOException e) {
                    thrownIoException = true;
                }
                thrownIoException.shouldBeTrue();
            });
        });

        feature("Filesystem i/o RGBA8. Lossless.", (f) {
            f.scenario("Red 1.0", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "ll_RGBA8_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "ll_RGBA8_red_0_5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "ll_RGBA8_red_0_01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "ll_RGBA8_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "ll_RGBA8_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Blue 1.0. Opacity 0.8.", {
                colorTestLossless!(PixelFormat.RGBA8)(
                    "ll_RGBA8_blue_alpha_0_8.webp",
                    Color4f(0f, 0f, 1f, 0.8f)
                );
            });
            f.scenario("Random.", {
                const fn = "ll_RGBA8_random.webp";

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
                    "ll_RGBA16_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "ll_RGBA16_red_0_5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "ll_RGBA16_red_0_01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "ll_RGBA16_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "ll_RGBA16_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Blue 1.0. Opacity 0.8.", {
                colorTestLossless!(PixelFormat.RGBA16)(
                    "ll_RGBA16_blue_alpha_0_8.webp",
                    Color4f(0f, 0f, 1f, 0.8f)
                );
            });
            f.scenario("Random.", {
                const fn = "ll_RGBA16_random.webp";

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
                    "ll_RGB8_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "ll_RGB8_red_0_5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "ll_RGB8_red_0_01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "ll_RGB8_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGB8)(
                    "ll_RGB8_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Random.", {
                const fn = "ll_RGB8_random.webp";
                SuperImage source = RandomImages.circles!(PixelFormat.RGB8)(500, 400);
                source.saveLosslessWEBP(fn);
                SuperImage result = loadWEBP(fn);
                assertTheSame8bitWithAlpha(source, result);
            });
        });


        feature("Filesystem i/o RGB-16. Lossless.", (f) {
            f.scenario("Red 1.0", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "ll_RGB16_red.webp",
                    Color4f(1f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.5", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "ll_RGB16_red_0_5.webp",
                    Color4f(0.5f, 0f, 0f, 1f)
                );
            });
            f.scenario("Red 0.01", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "ll_RGB16_red_0_01.webp",
                    Color4f(0.01f, 0f, 0f, 1f)
                );
            });
            f.scenario("Green 1.0", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "ll_RGB16_green.webp",
                    Color4f(0f, 1f, 0f, 1f)
                );
            });
            f.scenario("Blue 1.0", {
                colorTestLossless!(PixelFormat.RGB16)(
                    "ll_RGB16_blue.webp",
                    Color4f(0f, 0f, 1f, 1f)
                );
            });
            f.scenario("Random.", {
                const fn = "ll_RGB16_random.webp";
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
    import dlibwebp.random;

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
