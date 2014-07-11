#ifndef GR_H_
#define GR_H_

#include <Cocoa/Cocoa.h>

#include "status.h"

namespace gr {

CGContextRef NewContext(int w, int h);

CGContextRef NewContext(uint8_t* data, int w, int h);

CGRect BoundsOf(CGContextRef ctx);

Status ExportAsPng(CGImageRef img, std::string& filename);

Status ExportAsPng(CGContextRef ctx, std::string& filename);

Status LoadFromUrl(CGImageRef* img, std::string& url);

void DrawCoveringImage(CGContextRef ctx, CGImageRef img);

void DrawRoundedRect(
    CGContextRef ctx,
    CGPathDrawingMode mode,
    CGRect rect,
    float rad);

}

#endif // GR_H_