/* This file is part of the Pangolin Project.
 * http://github.com/stevenlovegrove/Pangolin
 *
 * Copyright (c) 2011 Steven Lovegrove
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#include <pangolin/platform.h>
#include <pangolin/gl/glinclude.h>
#include <pangolin/display/display.h>
#include <pangolin/display/display_internal.h>

#import <Cocoa/Cocoa.h>

#define OFFSETOF(TYPE, ELEMENT) ((size_t)&(((TYPE *)0)->ELEMENT))
static bool g_mousePressed[2] = { false, false };
static float g_mouseCoords[2] = {0,0};
static unsigned int g_windowWidth, g_windowHeight;
static unsigned int g_backingWidth, g_backingHeight;

namespace pangolin
{
extern __thread PangolinGl* context;
}

//------------------------------------------------------------------
// IMGUIExampleView
//------------------------------------------------------------------

@interface IMGUIExampleView : NSOpenGLView
{
}
@end

@implementation IMGUIExampleView

-(id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format
{
    NSLog(@"initWithFrame");
    self = [super initWithFrame:frameRect pixelFormat:format];
    return(self);
}

- (void)prepareOpenGL
{
    [super prepareOpenGL];

    NSLog(@"prepareOpenGL");

#ifndef DEBUG
    GLint swapInterval = 1;
    [[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
    if (swapInterval == 0)
    {
        NSLog(@"Error: Cannot set swap interval.");
    }
#endif
}

-(void)setViewportRect:(NSRect)bounds
{
    NSLog(@"setViewportRect");

    g_windowWidth = bounds.size.width;
    g_windowHeight = bounds.size.height;

    if (g_windowHeight == 0)
    {
        g_windowHeight = 1;
    }

    glViewport(0, 0, g_windowHeight, g_windowHeight);
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
    {
         NSRect backing = [self convertRectToBacking:bounds];
        g_backingWidth = backing.size.width;
        g_backingHeight= backing.size.height;
        if (g_backingHeight == 0)
        {
            g_backingHeight = g_windowHeight * 2;
        }
    }
    else
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
    {
        g_backingWidth = g_windowWidth;
        g_backingHeight= g_windowHeight;
    }
}

-(void)reshape
{
    NSLog(@"reshape");

    float scale;
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7
//    NSWindow* tlw = [self window];
    if ( [ _window respondsToSelector:@selector(backingScaleFactor) ] )
        scale = [_window backingScaleFactor];
    else
#endif
        scale = 1.0;

    pangolin::process::Resize(self.bounds.size.width * scale, self.bounds.size.height * scale);

    [self setViewportRect:self.bounds];
    [[self openGLContext] update];
//    [self drawView];
}

//-(void)drawRect:(NSRect)bounds
//{
//    [self drawView];
//}

#pragma mark -

-(BOOL)acceptsFirstResponder
{
    return(YES);
}

-(BOOL)becomeFirstResponder
{
    return(YES);
}

-(BOOL)resignFirstResponder
{
    return(YES);
}

// Flips coordinate system upside down on Y
-(BOOL)isFlipped
{
    return(YES);
}

#pragma mark Mouse and Key Events.

//static bool mapKeymap(int* keymap)
//{
//    if(*keymap == NSUpArrowFunctionKey)
//    else if(*keymap == NSDownArrowFunctionKey)
//    else if(*keymap == NSLeftArrowFunctionKey)
//    else if(*keymap == NSRightArrowFunctionKey)
//    else if(*keymap == NSHomeFunctionKey)
//    else if(*keymap == NSEndFunctionKey)
//    else if(*keymap == NSDeleteFunctionKey)
//    else if(*keymap == 25) // SHIFT + TAB
//    else
//        return true;
//    return false;
//}

-(void)keyUp:(NSEvent *)theEvent
{
//    NSString *str = [theEvent characters];
//    int len = (int)[str length];
//    for(int i = 0; i < len; i++)
//    {
//        int keymap = [str characterAtIndex:i];
//        mapKeymap(&keymap);
//    }
}

-(void)keyDown:(NSEvent *)theEvent
{
//    NSString *str = [theEvent characters];
//    int len = (int)[str length];
//    for(int i = 0; i < len; i++)
//    {
//        int keymap = [str characterAtIndex:i];
//        mapKeymap(&keymap);
//    }
}

- (void)flagsChanged:(NSEvent *)event
{
//    unsigned int flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
//    flags & NSShiftKeyMask;
//    flags & NSCommandKeyMask;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    int button = (int)[theEvent buttonNumber];
    g_mousePressed[button] = true;
}

-(void)mouseUp:(NSEvent *)theEvent
{
    int button = (int)[theEvent buttonNumber];
    g_mousePressed[button] = false;
}

- (void)scrollWheel:(NSEvent *)event
{
    double deltaX, deltaY;

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
    {
        deltaX = [event scrollingDeltaX];
        deltaY = [event scrollingDeltaY];

        if ([event hasPreciseScrollingDeltas])
        {
            deltaX *= 0.1;
            deltaY *= 0.1;
        }
    }
    else
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
    {
        deltaX = [event deltaX];
        deltaY = [event deltaY];
    }

    if (fabs(deltaX) > 0.0 || fabs(deltaY) > 0.0)
    {
    }
}

-(void)dealloc
{
    [super dealloc];
}

@end

static IMGUIExampleView *view = 0;

//------------------------------------------------------------------
// MyApplication
//------------------------------------------------------------------

@interface MyApplication : NSApplication
{
}

- (void)run_pre;
- (void)run_step;
- (void)terminate:(id)sender;

@end

@implementation MyApplication

- (void)run_pre
{
//    [self finishLaunching];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:NSApplicationWillFinishLaunchingNotification
        object:NSApp];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:NSApplicationDidFinishLaunchingNotification
        object:NSApp];
}

- (void)run_step
{
    NSEvent *event = [self
            nextEventMatchingMask:NSAnyEventMask
            untilDate:[NSDate distantFuture]
            inMode:NSDefaultRunLoopMode
            dequeue:YES];
    [self sendEvent:event];
    [self updateWindows];
}

- (void)terminate:(id)sender
{
    pangolin::Quit();
}

@end

//------------------------------------------------------------------
// IMGUIExampleAppDelegate
//------------------------------------------------------------------
@interface IMGUIExampleAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, readonly) NSWindow *window;

@end

@implementation IMGUIExampleAppDelegate

@synthesize window = _window;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (NSWindow*)window
{
    if (_window != nil)
        return(_window);
    
    NSRect viewRect = NSMakeRect(0.0,0.0,640.0,480.0);
    
    _window = [[NSWindow alloc] initWithContentRect:viewRect styleMask:NSTitledWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask|NSClosableWindowMask backing:NSBackingStoreBuffered defer:YES];
    [_window setTitle:@"IMGUI OSX Sample"];
    [_window setOpaque:YES];
    
    [_window makeKeyAndOrderFront:NSApp];

    return(_window);
}

- (void)setupMenu
{
    NSMenu *mainMenuBar;
    NSMenu *appMenu;
    NSMenuItem *menuItem;
    
    mainMenuBar = [[NSMenu alloc] init];
    
    appMenu = [[NSMenu alloc] initWithTitle:@"IMGUI OSX Sample"];
    menuItem = [appMenu addItemWithTitle:@"Quit IMGUI OSX Sample" action:@selector(terminate:) keyEquivalent:@"q"];
    [menuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    
    menuItem = [[NSMenuItem alloc] init];
    [menuItem setSubmenu:appMenu];
    
    [mainMenuBar addItem:menuItem];
    
    //[NSApp performSelector:@selector(setAppleMenu:) withObject:appMenu];
    [appMenu release];
    [NSApp setMainMenu:mainMenuBar];
}

- (void)dealloc
{
    [_window dealloc];
    [super dealloc];
    pangolin::Quit();
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupMenu];
    
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 32,
        0
    };
    
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    view = [[IMGUIExampleView alloc] initWithFrame:self.window.frame pixelFormat:format];
    [format release];
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        [view setWantsBestResolutionOpenGLSurface:YES];
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/

    [self.window setContentView:view];
    
    if ([view openGLContext] == nil)
    {
        NSLog(@"No OpenGL Context!");
    }
}

@end

namespace pangolin
{

void FinishFrame()
{
//    [[view openGLContext] update];
//    [view setNeedsDisplay:YES];

    RenderViews();
    PostRender();
    [[view openGLContext] flushBuffer];
    [NSApp run_step];
}

void CreateWindowAndBind(std::string window_title, int w, int h )
{
    // Create Pangolin GL Context
    BindToContext(window_title);
    PangolinCommonInit();
    context->is_double_buffered = true;

//    // These are important I think!
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    [pool release];

    NSApp = [MyApplication sharedApplication];

    IMGUIExampleAppDelegate *delegate = [[IMGUIExampleAppDelegate alloc] init];

    [[MyApplication sharedApplication] setDelegate:delegate];

    [NSApp run_pre];
    [NSApp run_step];

    glewInit();
}

void StartFullScreen() {
}

void StopFullScreen() {
}

void SetFullscreen(bool fullscreen)
{
    if( fullscreen != context->is_fullscreen )
    {
        if(fullscreen) {
            StartFullScreen();
        }else{
            StopFullScreen();
        }
        context->is_fullscreen = fullscreen;
    }
}
}
