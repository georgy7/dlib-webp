module dlibwebp.impl;

import api = dlibwebp.api;

import dlib.image;
import webp.encode;
import webp.decode;
import dlib.core.compound;
import dlib.core.stream;
import dlib.filesystem.local;
import core.stdc.stdlib : free;
import std.array;



package SuperImage loadWEBP(string filename) {
    InputStream input = openForInput(filename);
    auto img = loadWEBP(input);
    input.close();
    return img;
}

package SuperImage loadWEBP(InputStream input) {
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

package SuperImage loadWEBP(in ubyte[] webp) {
    int width;
    int height;
    ubyte* argbPointer = WebPDecodeRGBA(webp.ptr, webp.length, &width, &height);
    ubyte[] argbArray = argbPointer[0 .. (width * height * 4)];

    SuperImage rgbaImage = defaultImageFactory.createImage(width, height, 4, 8);
    foreach(i, v; argbArray) {
        rgbaImage.data[i] = v;
    }
    free(argbPointer);
    return rgbaImage;
}


package void saveWEBP(SuperImage img, int quality, string filename) {
    OutputStream output = openForOutput(filename);
    Compound!(bool, string) res = saveWEBP(img, quality, output);
    output.close();

    if (!res[0]) {
        throw new api.WEBPLoadException(res[1]);
    }
}
package void saveLosslessWEBP(SuperImage img, string filename) {
    OutputStream output = openForOutput(filename);
    Compound!(bool, string) res = saveLosslessWEBP(img, output);
    output.close();

    if (!res[0]) {
        throw new api.WEBPLoadException(res[1]);
    }
}

package Compound!(bool, string) saveWEBP(SuperImage img, int quality, OutputStream output) {
    ubyte[] result;
    try {
        result = saveWEBPToArray(img, quality);
    } catch (api.WEBPLoadException e) {
        if (e.msg.empty) {
            return compound(false, "Exception occurred during to saving to the array.");
        } else {
            return compound(false, e.msg);
        }
    }
    if (result.length < 1) {
        return compound(false, "Empty result.");
    }
    if (!output.writeArray(result)) {
        return compound(false, "Could not write the result to the output stream.");
    }
    return compound(true, "");
}
package Compound!(bool, string) saveLosslessWEBP(SuperImage img, OutputStream output) {
    ubyte[] result;
    try {
        result = saveLosslessWEBPToArray(img);
    } catch (api.WEBPLoadException e) {
        if (e.msg.empty) {
            return compound(false, "Exception occurred during to saving to the array.");
        } else {
            return compound(false, e.msg);
        }
    }
    if (result.length < 1) {
        return compound(false, "Empty result.");
    }
    if (!output.writeArray(result)) {
        return compound(false, "Could not write the result to the output stream.");
    }
    return compound(true, "");
}

package ubyte[] saveWEBPToArray(SuperImage img, int quality) {
    if (PixelFormat.L8 == img.pixelFormat ||
            PixelFormat.RGB8 == img.pixelFormat ||
            PixelFormat.L16 == img.pixelFormat ||
            PixelFormat.RGB16 == img.pixelFormat) {
        return saveLossy(img, quality);
    } else {
        return saveLossyWithAlpha(img, quality);
    }
}
package ubyte[] saveLosslessWEBPToArray(SuperImage img) {
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
    ubyte[] result = outputPointer[0 .. outputSize];
    free(outputPointer);
    return result;
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
    ubyte[] result = outputPointer[0 .. outputSize];
    free(outputPointer);
    return result;
}

private ubyte[] saveLosslessWithAlpha(SuperImage img) {
    SuperImage inputImage = img;
    if (PixelFormat.RGBA8 != img.pixelFormat) {
        inputImage = convert!(Image!(PixelFormat.RGBA8))(img);
    }
    ubyte* outputPointer;
    size_t outputSize = WebPEncodeLosslessRGBA(
            inputImage.data.ptr,
            inputImage.width(),
            inputImage.height(),
            inputImage.width() * 4,
            &outputPointer);
    ubyte[] result = outputPointer[0 .. outputSize];
    free(outputPointer);
    return result;
}
private ubyte[] saveLossless(SuperImage img) {
    SuperImage inputImage = img;
    if (PixelFormat.RGB8 != img.pixelFormat) {
        inputImage = convert!(Image!(PixelFormat.RGB8))(img);
    }
    ubyte* outputPointer;
    size_t outputSize = WebPEncodeLosslessRGB(
            inputImage.data.ptr,
            inputImage.width(),
            inputImage.height(),
            inputImage.width() * 3,
            &outputPointer);
    ubyte[] result = outputPointer[0 .. outputSize];
    free(outputPointer);
    return result;
}
