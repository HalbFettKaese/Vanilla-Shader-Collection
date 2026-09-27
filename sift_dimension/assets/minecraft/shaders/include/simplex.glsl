
// Copied simplex noise code
/* https://www.shadertoy.com/view/XsX3zB
 *
 * The MIT License
 * Copyright © 2013 Nikita Miropolskiy
 * 
 * ( license has been changed from CCA-NC-SA 3.0 to MIT
 *
 *   but thanks for attributing your source code when deriving from this sample 
 *   with a following link: https://www.shadertoy.com/view/XsX3zB )
 *
 * ~
 * ~ if you're looking for procedural noise implementation examples you might 
 * ~ also want to look at the following shaders:
 * ~ 
 * ~ Noise Lab shader by candycat: https://www.shadertoy.com/view/4sc3z2
 * ~
 * ~ Noise shaders by iq:
 * ~     Value    Noise 2D, Derivatives: https://www.shadertoy.com/view/4dXBRH
 * ~     Gradient Noise 2D, Derivatives: https://www.shadertoy.com/view/XdXBRH
 * ~     Value    Noise 3D, Derivatives: https://www.shadertoy.com/view/XsXfRH
 * ~     Gradient Noise 3D, Derivatives: https://www.shadertoy.com/view/4dffRH
 * ~     Value    Noise 2D             : https://www.shadertoy.com/view/lsf3WH
 * ~     Value    Noise 3D             : https://www.shadertoy.com/view/4sfGzS
 * ~     Gradient Noise 2D             : https://www.shadertoy.com/view/XdXGW8
 * ~     Gradient Noise 3D             : https://www.shadertoy.com/view/Xsl3Dl
 * ~     Simplex  Noise 2D             : https://www.shadertoy.com/view/Msf3WH
 * ~     Voronoise: https://www.shadertoy.com/view/Xd23Dh
 * ~ 
 *
 */
// Simplified by FabriceNeyret2
#define random3(c) fract( sin(dot(c,vec3(17, 59.4, 15))) * exp2(vec3(18,15,21)) ) -.5
     
float G3 =  .1666667;
float simplex3d(vec3 p) {
	 vec3 s = floor(p + dot(p, vec3(G3))*2.),
          x = p - s + dot(s, vec3(G3)),
          e = step( 0., x - x.yzx),
          i1 = e*(1. - e.zxy),
          i2 = 1. - e.zxy*(1.-e),
          x1 = x - i1 +    G3,
          x2 = x - i2 + 2.*G3,
          x3 = x - 1. + 3.*G3;
	 vec4 w = vec4( dot(x , x ),
                    dot(x1, x1),
                    dot(x2, x2),
                    dot(x3, x3) ),
          d = vec4( dot(random3(s     ), x ),
                    dot(random3(s + i1), x1),
                    dot(random3(s + i2), x2),
                    dot(random3(s + 1.), x3) );
	 w = max(.6 - w, 0.);
	 return dot(d*w*w*w*w, vec4(52));
}