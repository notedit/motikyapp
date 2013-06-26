//
//  MOViewPreviewView.h
//  Motiky
//
//  Created by notedit on 5/13/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CVOpenGLESTextureCache.h>

@interface MOViewPreviewView : UIView
{
	int renderBufferWidth;
	int renderBufferHeight;
    
	CVOpenGLESTextureCacheRef videoTextureCache;
    
	EAGLContext* oglContext;
	GLuint frameBufferHandle;
	GLuint colorBufferHandle;
    GLuint passThroughProgram;
}

- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer;

@end
