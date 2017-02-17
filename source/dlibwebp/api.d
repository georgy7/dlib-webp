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



/++
 + Throws: WEBPLoadException.
 +/
void saveWEBP(SuperImage img, int quality, string filename) {
    return impl.saveWEBP(img, quality, filename);
}

/++
 + Throws: WEBPLoadException.
 +/
void saveLosslessWEBP(SuperImage img, string filename) {
    return impl.saveLosslessWEBP(img, filename);
}

/++
 + Returns: `false` and an error message on failure.
 +/
Compound!(bool, string) saveWEBP(SuperImage img, int quality, OutputStream output) {
    return impl.saveWEBP(img, quality, output);
}

/++
 + Returns: `false` and an error message on failure.
 +/
Compound!(bool, string) saveLosslessWEBP(SuperImage img, OutputStream output) {
    return impl.saveLosslessWEBP(img, output);
}


/++
 + Throws: WEBPLoadException.
 +/
ubyte[] saveWEBPToArray(SuperImage img, int quality) {
    return impl.saveWEBPToArray(img, quality);
}

/++
 + Throws: WEBPLoadException.
 +/
ubyte[] saveLosslessWEBPToArray(SuperImage img) {
    return impl.saveLosslessWEBPToArray(img);
}


