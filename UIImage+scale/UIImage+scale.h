//
//  UIImage+scale.h
//  sjkh
//
//  Created by cssweb88 on 13-11-5.
//  Copyright (c) 2013年 北京中软万维上海分公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (scale)

//缩放图片
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

//按比例缩放图片
- (UIImage*)imageByScalingWithProportion:(CGFloat)proportion;

//切割图片中某个区域
- (UIImage*)imageSliceWithArea:(CGRect)rect;

//图片方向
- (UIImage*)imageRevolveWithOrientation:(UIImageOrientation)orientation;

//保存图片到cache中
- (void)saveJPGEInCacheWithName:(NSString*)name;
- (void)saveJPGEInCacheWithName:(NSString*)name scale:(CGFloat)scale;
@end
