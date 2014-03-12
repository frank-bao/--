//
//  UIImage+scale.m
//  sjkh
//
//  Created by cssweb88 on 13-11-5.
//  Copyright (c) 2013年 北京中软万维上海分公司. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)


//按比例缩放图片
- (UIImage*)imageByScalingWithProportion:(CGFloat)proportion;
{
    return nil;
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageSliceWithArea:(CGRect)rect;
{
    float START_X = rect.origin.x;
	float START_Y = rect.origin.y;
	float WIDTH = rect.size.width;
	float HEIGHT = rect.size.height;
	
    CGSize subImageSize = CGSizeMake(WIDTH, HEIGHT);
    CGRect subImageRect = CGRectMake(START_X, START_Y, WIDTH, HEIGHT);
    CGImageRef imageRef = self.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    UIImage* subImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return subImage;
}


//图片方向
- (UIImage*)imageRevolveWithOrientation:(UIImageOrientation)orientation;
{
    UIImage *originalImage = [[UIImage alloc] initWithCGImage:self.CGImage scale:1.0 orientation:orientation];
    return originalImage;
}

//获取缓存目录 (Library/Caches) 下的文件 filename
- (NSString*)libraryCachePath:(NSString*)filename;
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"cssweb"];
    if (![fileManager fileExistsAtPath:documentsDirectory]) {
        if ([fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil]==NO) {
            NSLog(@"文件夹创建失败");
        }
    }
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    return path;
}

- (void)saveJPGEInCacheWithName:(NSString*)name;
{
    NSData *jpgImgData = UIImageJPEGRepresentation(self, 0.5);
    
    NSString *filepath =[self libraryCachePath:[NSString stringWithFormat:@"%@.jpg",name]];
    [jpgImgData writeToFile:filepath atomically:YES];
}

- (void)saveJPGEInCacheWithName:(NSString*)name scale:(CGFloat)scale;
{
    NSData *jpgImgData = UIImageJPEGRepresentation(self, scale);
    
    NSString *filepath =[self libraryCachePath:[NSString stringWithFormat:@"%@.jpg",name]];
    [jpgImgData writeToFile:filepath atomically:YES];
}


@end
