//
//  SwimOceanNode.m
//  WaterRoute
//
//  Created by Joe on 14-9-2.
//  Copyright 2014年 Joe. All rights reserved.
//

#import "SwimOceanNode.h"
#import "CCAnimation+Helper.h"

@implementation SwimOceanNode

-(instancetype)initWithImageNamed:(NSString *)imageName andTexture:(CCTexture *)texture
{
    if (self = [super initWithImageNamed:imageName])
    {
        _isStartShake = NO;
        self.shaderUniforms[@"Background"] = texture;
    }
    return self;
}

-(void)setIsStartShake:(BOOL)isStartShake{
    _isStartShake = isStartShake;
    if (_isStartShake) {
        self.shader = [[CCShader alloc] initWithVertexShaderSource:
                       CC_GLSL(
                               uniform vec2 causticsSize;
                               uniform sampler2D Background;
                               
                               void main(){
                                   vec4 vertex = cc_Position;
                                   vertex.y = vertex.y + sin(vertex.x + cc_Time[0]*2.0)*0.02;
                                   //                                   vertex.z = vertex.z +  sin(vertex.x*1000.0 + cc_Time[0]*2.0)*0.10;
                                   gl_Position = vertex;
                                   cc_FragTexCoord1 = cc_TexCoord1;
                                   cc_FragColor = cc_Color;
                                   //                                   cc_FragColor = cc_Color;
                               }
                               )
                                              fragmentShaderSource:
                       CC_GLSL(
                               
                               uniform sampler2D Background;
                               void main(){
                                   vec4 texColor = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   if ( texColor.a <= 0.2 ){
                                       
                                       discard;
                                       
                                   }
                                   
                                   float multiplier = 0.05 * texColor.a;
                                   
                                   float multiplierX = multiplier * sin(cc_Time[1])*0.1;
                                   float multiplierY = multiplier * sin(cc_Time[0])*0.5;
                                   
                                   //                                   float height = cc_FragTexCoord1.y;
                                   //                                   // 3
                                   //                                   float offset = pow(height, 2.5);
                                   //
                                   //                                   // 4 multiply by sin since it gives us nice bending
                                   //                                   offset *= (sin(cc_Time[0] * 0.5) * 0.2);
                                   //                                   float tag = -1.0;
                                   //                                   if (height <= 0.1)
                                   //                                       tag = 1.0;
                                   //                                   else if (height <= 0.2)
                                   //                                       tag = -1.0;
                                   //                                   else if (height <= 0.3)
                                   //                                       tag = 1.0;
                                   //                                   else if (height <= 0.4)
                                   //                                       tag = -1.0;
                                   //                                   else if (height >= 0.5)
                                   //                                       tag = 0.0;
                                   //                                   offset *= tag;
                                   
                                   
                                   vec4 backgroundColor = texture2D(Background, vec2(cc_FragTexCoord1.x + multiplierX,(cc_FragTexCoord1.y - 0.1 + multiplierY)));
                                   
                                   if (backgroundColor.a > 0.2)
                                   {
                                       texColor.r = backgroundColor.r;
                                       texColor.g = backgroundColor.g;
                                       texColor.b = backgroundColor.b;
                                       texColor.a = 0.9;
                                   }
                                   gl_FragColor = texColor/* * v_fragmentColor*/;
                               }
                               )];

    }
}


@end
