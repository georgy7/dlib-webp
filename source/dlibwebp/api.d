module dlibwebp.api;

import impl = dlibwebp.impl;

import dlib.image;
import dlib.core.compound;
import dlib.core.stream;



class WEBPLoadException: ImageLoadException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}


/++
 + Throws: WEBPLoadException.
 +/
SuperImage loadWEBP(string filename) {
    return impl.loadWEBP(filename);
}

/++
 + Throws: WEBPLoadException.
 +/
SuperImage loadWEBP(InputStream input) {
    return impl.loadWEBP(input);
}

/++
 + Throws: WEBPLoadException.
 +/
SuperImage loadWEBP(in ubyte[] webp) {
    return impl.loadWEBP(webp);
}


enum WEBPQuality : int
{
    LOSSLESS = -1,
    LOWEST = 0,
    LOW = 50,
    MEDIUM = 75,
    HIGH = 80,
    HIGHEST = 100
}


/++
 + Throws: WEBPLoadException.
 +/
void saveWEBP(SuperImage img, string filename, int quality = WEBPQuality.MEDIUM)
{
    assert(quality >= WEBPQuality.LOSSLESS);
    assert(quality <= WEBPQuality.HIGHEST);

    if (WEBPQuality.LOSSLESS == quality)
    {
        return impl.saveLosslessWEBP(img, filename);
    }
    else
    {
        return impl.saveWEBP(img, quality, filename);
    }
}

deprecated("Use img.saveWEBP(filename, quality) instead.")
void saveWEBP(SuperImage img, int quality, string filename)
{
    return img.saveWEBP(filename, quality);
}

deprecated("Use img.saveWEBP(filename, WEBPQuality.LOSSLESS) instead.")
void saveLosslessWEBP(SuperImage img, string filename)
{
    return img.saveWEBP(filename, WEBPQuality.LOSSLESS);
}

/++
 + Returns: `false` and an error message on failure.
 +/
Compound!(bool, string) saveWEBP(SuperImage img, OutputStream output, int quality = WEBPQuality.MEDIUM)
{
    assert(quality >= WEBPQuality.LOSSLESS);
    assert(quality <= WEBPQuality.HIGHEST);

    if (WEBPQuality.LOSSLESS == quality)
    {
        return impl.saveLosslessWEBP(img, output);
    }
    else
    {
        return impl.saveWEBP(img, quality, output);
    }
}

deprecated("Use img.saveWEBP(output, quality) instead.")
Compound!(bool, string) saveWEBP(SuperImage img, int quality, OutputStream output)
{
    return img.saveWEBP(output, quality);
}

deprecated("Use img.saveWEBP(output, WEBPQuality.LOSSLESS) instead.")
Compound!(bool, string) saveLosslessWEBP(SuperImage img, OutputStream output)
{
    return img.saveWEBP(output, WEBPQuality.LOSSLESS);
}

/++
 + Throws: WEBPLoadException.
 +/
ubyte[] saveWEBPToArray(SuperImage img, int quality = WEBPQuality.MEDIUM)
{
    assert(quality >= WEBPQuality.LOSSLESS);
    assert(quality <= WEBPQuality.HIGHEST);

    if (WEBPQuality.LOSSLESS == quality)
    {
        return impl.saveLosslessWEBPToArray(img);
    }
    else
    {
        return impl.saveWEBPToArray(img, quality);
    }
}

deprecated("Use img.saveWEBPToArray(WEBPQuality.LOSSLESS) instead.")
ubyte[] saveLosslessWEBPToArray(SuperImage img) {
    return img.saveWEBPToArray(WEBPQuality.LOSSLESS);
}


