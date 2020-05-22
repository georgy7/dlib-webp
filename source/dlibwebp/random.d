module dlibwebp.random;

import dlib.image;
import std.random;
import std.algorithm.comparison;
import std.conv;
import std.digest.sha;
import std.algorithm.searching;

public class RandomImages {
    public static SuperImage circles(PixelFormat format)(int w, int h) {
        return randomCircles!(format)(w, h);
    }
    public static SuperImage circles(int w, int h) {
        return RandomImages.circles!(PixelFormat.RGBA8)(w, h);
    }
}

private auto randHsv() {
    return hsv(uniform01() * 360f, uniform01(), uniform01());
}

/** A very naive implementation. */
private void fillCircle(SuperImage img, Color4f color, int x0, int y0, int r) {
    if (r > 0) {
        auto maxR = min(r, max(img.width(), img.height()));
        for (int i = 1; i <= maxR; i++) {
            img.drawCircle(color, x0, y0, i);
        }
    }
}
private void randomCircles(SuperImage img, Color4f color, int minCount, int maxCount) {
    int countOfElements = uniform(minCount, 1 + maxCount);
    int maxR = uniform(1, max(img.width(), img.height()) / 2);
    for (int i = 0; i < countOfElements; i++) {
        img.fillCircle(color, uniform(0, img.width()), uniform(0, img.height()), maxR);
        maxR = uniform(1, 1 + maxR);
    }
}
private SuperImage randomCircles(PixelFormat format)(int w, int h) {
    SuperImage img = new Image!(format)(w, h);
    img.fillColor(randHsv());
    img.randomCircles(randHsv(), 1, 10);
    img.randomCircles(randHsv(), 1, 10);
    return img;
}

unittest {
    string[] hashes = [];
    for (int i = 0; i < 10; i++) {
        string fn = "test" ~ to!string(i) ~ ".png";
        SuperImage image = RandomImages.circles(320, 240);

        // I suppose, this is a strong enough way to check uniqueness.
        auto hash = (new SHA512Digest()).digest(image.data()).toHexString();
        assert(!hashes.canFind(hash));
        hashes ~= hash;

        image.savePNG(fn);
    }
}

