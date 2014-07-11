#include "gr.h"

#include "auto_ref.h"

namespace gr {

//
CGContextRef NewContext(int w, int h) {
  return NewContext(NULL, w, h);
}

//
CGContextRef NewContext(uint8_t* data, int w, int h) {
  AutoRef<CGColorSpaceRef> colorSpace = CGColorSpaceCreateDeviceRGB();
  return CGBitmapContextCreate(
      data,
      w,
      h,
      8,
      w * 4,
      colorSpace,
      kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
}

//
CGRect BoundsOf(CGContextRef ctx) {
  return CGRectMake(
      0,
      0,
      CGBitmapContextGetWidth(ctx),
      CGBitmapContextGetHeight(ctx));
}

//
Status ExportAsPng(CGImageRef img, std::string& filename) {
  AutoRef<CFStringRef> fn = CFStringCreateWithCStringNoCopy(
      NULL,
      filename.c_str(),
      kCFStringEncodingUTF8,
      kCFAllocatorNull);
  if (!fn) {
    return ERR("cannot create string");
  }

  AutoRef<CFURLRef> url = CFURLCreateWithFileSystemPath(
      NULL,
      fn,
      kCFURLPOSIXPathStyle,
      false);
  if (!url) {
    return ERR("cannot create url");
  }

  AutoRef<CGImageDestinationRef> dst = CGImageDestinationCreateWithURL(
      url,
      kUTTypePNG,
      1,
      0);
  if (!dst) {
    return ERR("cannot create image destination");
  }

  CGImageDestinationAddImage(dst, img, 0);
  return NoErr();
}

//
Status ExportAsPng(CGContextRef ctx, std::string& filename) {
  AutoRef<CGImageRef> img = CGBitmapContextCreateImage(ctx);
  if (!img) {
    return ERR("cannot create image");
  }

  return ExportAsPng(img, filename);
}

Status LoadFromUrl(CGImageRef* img, std::string& url) {
  *img = NULL;

  AutoRef<CFStringRef> cfUrlStr = CFStringCreateWithCStringNoCopy(
      NULL,
      url.c_str(),
      kCFStringEncodingUTF8,
      kCFAllocatorNull);
  if (!cfUrlStr) {
    return ERR("cannot create string");
  }

  AutoRef<CFURLRef> cfUrl = CFURLCreateWithString(
      NULL,
      cfUrlStr,
      NULL);
  if (!cfUrl) {
    return ERR("cannot create url");
  }

  AutoRef<CGDataProviderRef> cfIp = CGDataProviderCreateWithURL(cfUrl);
  if (!cfIp) {
    return ERR("cannot create data provider");
  }

  *img = CGImageCreateWithJPEGDataProvider(
      cfIp,
      NULL,
      false,
      kCGRenderingIntentDefault);
  if (!img) {
    return ERR("cannot decode image");
  }

  return NoErr();
}

//
void DrawCoveringImage(CGContextRef ctx, CGImageRef img) {
  float sw = CGImageGetWidth(img);
  float sh = CGImageGetHeight(img);

  float dw = CGBitmapContextGetWidth(ctx);
  float dh = CGBitmapContextGetHeight(ctx);

  float sr = sw / sh;
  float dr = dw / dh;

  if (sr / dr > 1.0) {
    // fit height
    float csw = dh*sr;
    CGContextDrawImage(
      ctx,
      CGRectMake(dw/2 - csw/2, 0, csw, dh),
      img);
  } else {
    // fit width
    float csh = dw/sr;
    CGContextDrawImage(
      ctx,
      CGRectMake(0, dh/2 - csh/2, dw, csh),
      img);
  }
}

}