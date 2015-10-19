如何获得当前视图的渲染帧率
---

相信开发iOS的同学们，都用过Instruments分析过自己的App吧。里面的Time Profile可以显示出当前FPS，配合Core Animation可以查看一些具体性能开销。

但是，如何不借助Instruments这个工具。我们如何获取帧率呢？看看 Google的答案吧：
[display-fps-on-ios-onscreen-without-instruments](http://stackoverflow.com/questions/15169342/display-fps-on-ios-onscreen-without-instruments)

然后，我们就找到了这样一个开源小工具：[RRFPSBar](https://github.com/RolandasRazma/RRFPSBar)

查看实现，我们知道了原来有CADisplayLink这么一个东西。网上的介绍有很多，我就放一下官方介绍吧：

[CADisplayLink Class Reference](https://developer.apple.com/library/ios/documentation/QuartzCore/Reference/CADisplayLink_ClassRef/index.html#//apple_ref/doc/uid/TP40009031-CH1-DontLinkElementID_1)


> A CADisplayLink object is a timer object that allows your application to synchronize its drawing to the refresh rate of the display.
>
> Your application creates a new display link, providing a target object and a selector to be called when the screen is updated. Next, your application adds the display link to a run loop.
>
> Once the display link is associated with a run loop, the selector on the target is called when the screen’s contents need to be updated. The target can read the display link’s timestamp property to retrieve the time that the previous frame was displayed. For example, an application that displays movies might use the timestamp to calculate which video frame will be displayed next. An application that performs its own animations might use the timestamp to determine where and how displayed objects appear in the upcoming frame. The duration property provides the amount of time between frames. You can use this value in your application to calculate the frame rate of the display, the approximate time that the next frame will be displayed, and to adjust the drawing behavior so that the next frame is prepared in time to be displayed.
>
> Your application can disable notifications by setting the paused property to YES. Also, if your application cannot provide frames in the time provided, you may want to choose a slower frame rate. An application with a slower but consistent frame rate appears smoother to the user than an application that skips frames. You can increase the time between frames (and decrease the apparent frame rate) by changing the frameInterval property.
>
> When your application finishes with a display link, it should call invalidate to remove it from all run loops and to disassociate it from the target.
>
> CADisplayLink should not be subclassed.



按照RRFPSBar的实现，重新造了一遍轮子：
![gif](https://github.com/778477/778477.github.io/raw/master/img/FPSBar.gif)