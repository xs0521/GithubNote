var Wt={value:()=>{}};function Jt(){for(var t=0,i=arguments.length,n={},e;t<i;++t){if(!(e=arguments[t]+"")||e in n||/[\s.]/.test(e))throw new Error("illegal type: "+e);n[e]=[]}return new O(n)}function O(t){this._=t}function Qt(t,i){return t.trim().split(/^|\s+/).map(function(n){var e="",s=n.indexOf(".");if(s>=0&&(e=n.slice(s+1),n=n.slice(0,s)),n&&!i.hasOwnProperty(n))throw new Error("unknown type: "+n);return{type:n,name:e}})}O.prototype=Jt.prototype={constructor:O,on:function(t,i){var n=this._,e=Qt(t+"",n),s,o=-1,r=e.length;if(arguments.length<2){for(;++o<r;)if((s=(t=e[o]).type)&&(s=Ut(n[s],t.name)))return s;return}if(i!=null&&typeof i!="function")throw new Error("invalid callback: "+i);for(;++o<r;)if(s=(t=e[o]).type)n[s]=ct(n[s],t.name,i);else if(i==null)for(s in n)n[s]=ct(n[s],t.name,null);return this},copy:function(){var t={},i=this._;for(var n in i)t[n]=i[n].slice();return new O(t)},call:function(t,i){if((s=arguments.length-2)>0)for(var n=new Array(s),e=0,s,o;e<s;++e)n[e]=arguments[e+2];if(!this._.hasOwnProperty(t))throw new Error("unknown type: "+t);for(o=this._[t],e=0,s=o.length;e<s;++e)o[e].value.apply(i,n)},apply:function(t,i,n){if(!this._.hasOwnProperty(t))throw new Error("unknown type: "+t);for(var e=this._[t],s=0,o=e.length;s<o;++s)e[s].value.apply(i,n)}};function Ut(t,i){for(var n=0,e=t.length,s;n<e;++n)if((s=t[n]).name===i)return s.value}function ct(t,i,n){for(var e=0,s=t.length;e<s;++e)if(t[e].name===i){t[e]=Wt,t=t.slice(0,e).concat(t.slice(e+1));break}return n!=null&&t.push({name:i,value:n}),t}function it(t,i,n){t.prototype=i.prototype=n,n.constructor=t}function Mt(t,i){var n=Object.create(t.prototype);for(var e in i)n[e]=i[e];return n}function R(){}var S=.7,I=1/S,N="\\s*([+-]?\\d+)\\s*",C="\\s*([+-]?(?:\\d*\\.)?\\d+(?:[eE][+-]?\\d+)?)\\s*",p="\\s*([+-]?(?:\\d*\\.)?\\d+(?:[eE][+-]?\\d+)?)%\\s*",Zt=/^#([0-9a-f]{3,8})$/,ti=new RegExp(`^rgb\\(${N},${N},${N}\\)$`),ii=new RegExp(`^rgb\\(${p},${p},${p}\\)$`),ni=new RegExp(`^rgba\\(${N},${N},${N},${C}\\)$`),ei=new RegExp(`^rgba\\(${p},${p},${p},${C}\\)$`),si=new RegExp(`^hsl\\(${C},${p},${p}\\)$`),oi=new RegExp(`^hsla\\(${C},${p},${p},${C}\\)$`),lt={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074};it(R,nt,{copy(t){return Object.assign(new this.constructor,this,t)},displayable(){return this.rgb().displayable()},hex:ft,formatHex:ft,formatHex8:ri,formatHsl:hi,formatRgb:ut,toString:ut});function ft(){return this.rgb().formatHex()}function ri(){return this.rgb().formatHex8()}function hi(){return Et(this).formatHsl()}function ut(){return this.rgb().formatRgb()}function nt(t){var i,n;return t=(t+"").trim().toLowerCase(),(i=Zt.exec(t))?(n=i[1].length,i=parseInt(i[1],16),n===6?xt(i):n===3?new u(i>>8&15|i>>4&240,i>>4&15|i&240,(i&15)<<4|i&15,1):n===8?q(i>>24&255,i>>16&255,i>>8&255,(i&255)/255):n===4?q(i>>12&15|i>>8&240,i>>8&15|i>>4&240,i>>4&15|i&240,((i&15)<<4|i&15)/255):null):(i=ti.exec(t))?new u(i[1],i[2],i[3],1):(i=ii.exec(t))?new u(i[1]*255/100,i[2]*255/100,i[3]*255/100,1):(i=ni.exec(t))?q(i[1],i[2],i[3],i[4]):(i=ei.exec(t))?q(i[1]*255/100,i[2]*255/100,i[3]*255/100,i[4]):(i=si.exec(t))?yt(i[1],i[2]/100,i[3]/100,1):(i=oi.exec(t))?yt(i[1],i[2]/100,i[3]/100,i[4]):lt.hasOwnProperty(t)?xt(lt[t]):t==="transparent"?new u(NaN,NaN,NaN,0):null}function xt(t){return new u(t>>16&255,t>>8&255,t&255,1)}function q(t,i,n,e){return e<=0&&(t=i=n=NaN),new u(t,i,n,e)}function ai(t){return t instanceof R||(t=nt(t)),t?(t=t.rgb(),new u(t.r,t.g,t.b,t.opacity)):new u}function A(t,i,n,e){return arguments.length===1?ai(t):new u(t,i,n,e??1)}function u(t,i,n,e){this.r=+t,this.g=+i,this.b=+n,this.opacity=+e}it(u,A,Mt(R,{brighter(t){return t=t==null?I:Math.pow(I,t),new u(this.r*t,this.g*t,this.b*t,this.opacity)},darker(t){return t=t==null?S:Math.pow(S,t),new u(this.r*t,this.g*t,this.b*t,this.opacity)},rgb(){return this},clamp(){return new u(m(this.r),m(this.g),m(this.b),B(this.opacity))},displayable(){return-.5<=this.r&&this.r<255.5&&-.5<=this.g&&this.g<255.5&&-.5<=this.b&&this.b<255.5&&0<=this.opacity&&this.opacity<=1},hex:pt,formatHex:pt,formatHex8:_i,formatRgb:dt,toString:dt}));function pt(){return`#${w(this.r)}${w(this.g)}${w(this.b)}`}function _i(){return`#${w(this.r)}${w(this.g)}${w(this.b)}${w((isNaN(this.opacity)?1:this.opacity)*255)}`}function dt(){const t=B(this.opacity);return`${t===1?"rgb(":"rgba("}${m(this.r)}, ${m(this.g)}, ${m(this.b)}${t===1?")":`, ${t})`}`}function B(t){return isNaN(t)?1:Math.max(0,Math.min(1,t))}function m(t){return Math.max(0,Math.min(255,Math.round(t)||0))}function w(t){return t=m(t),(t<16?"0":"")+t.toString(16)}function yt(t,i,n,e){return e<=0?t=i=n=NaN:n<=0||n>=1?t=i=NaN:i<=0&&(t=NaN),new x(t,i,n,e)}function Et(t){if(t instanceof x)return new x(t.h,t.s,t.l,t.opacity);if(t instanceof R||(t=nt(t)),!t)return new x;if(t instanceof x)return t;t=t.rgb();var i=t.r/255,n=t.g/255,e=t.b/255,s=Math.min(i,n,e),o=Math.max(i,n,e),r=NaN,h=o-s,c=(o+s)/2;return h?(i===o?r=(n-e)/h+(n<e)*6:n===o?r=(e-i)/h+2:r=(i-n)/h+4,h/=c<.5?o+s:2-o-s,r*=60):h=c>0&&c<1?0:r,new x(r,h,c,t.opacity)}function ci(t,i,n,e){return arguments.length===1?Et(t):new x(t,i,n,e??1)}function x(t,i,n,e){this.h=+t,this.s=+i,this.l=+n,this.opacity=+e}it(x,ci,Mt(R,{brighter(t){return t=t==null?I:Math.pow(I,t),new x(this.h,this.s,this.l*t,this.opacity)},darker(t){return t=t==null?S:Math.pow(S,t),new x(this.h,this.s,this.l*t,this.opacity)},rgb(){var t=this.h%360+(this.h<0)*360,i=isNaN(t)||isNaN(this.s)?0:this.s,n=this.l,e=n+(n<.5?n:1-n)*i,s=2*n-e;return new u(V(t>=240?t-240:t+120,s,e),V(t,s,e),V(t<120?t+240:t-120,s,e),this.opacity)},clamp(){return new x(bt(this.h),H(this.s),H(this.l),B(this.opacity))},displayable(){return(0<=this.s&&this.s<=1||isNaN(this.s))&&0<=this.l&&this.l<=1&&0<=this.opacity&&this.opacity<=1},formatHsl(){const t=B(this.opacity);return`${t===1?"hsl(":"hsla("}${bt(this.h)}, ${H(this.s)*100}%, ${H(this.l)*100}%${t===1?")":`, ${t})`}`}}));function bt(t){return t=(t||0)%360,t<0?t+360:t}function H(t){return Math.max(0,Math.min(1,t||0))}function V(t,i,n){return(t<60?i+(n-i)*t/60:t<180?n:t<240?i+(n-i)*(240-t)/60:i)*255}function St(t,i,n,e,s){var o=t*t,r=o*t;return((1-3*t+3*o-r)*i+(4-6*o+3*r)*n+(1+3*t+3*o-3*r)*e+r*s)/6}function li(t){var i=t.length-1;return function(n){var e=n<=0?n=0:n>=1?(n=1,i-1):Math.floor(n*i),s=t[e],o=t[e+1],r=e>0?t[e-1]:2*s-o,h=e<i-1?t[e+2]:2*o-s;return St((n-e/i)*i,r,s,o,h)}}function fi(t){var i=t.length;return function(n){var e=Math.floor(((n%=1)<0?++n:n)*i),s=t[(e+i-1)%i],o=t[e%i],r=t[(e+1)%i],h=t[(e+2)%i];return St((n-e/i)*i,s,o,r,h)}}const et=t=>()=>t;function Ct(t,i){return function(n){return t+n*i}}function ui(t,i,n){return t=Math.pow(t,n),i=Math.pow(i,n)-t,n=1/n,function(e){return Math.pow(t+e*i,n)}}function Ni(t,i){var n=i-t;return n?Ct(t,n>180||n<-180?n-360*Math.round(n/360):n):et(isNaN(t)?i:t)}function xi(t){return(t=+t)==1?Pt:function(i,n){return n-i?ui(i,n,t):et(isNaN(i)?n:i)}}function Pt(t,i){var n=i-t;return n?Ct(t,n):et(isNaN(t)?i:t)}const Ti=function t(i){var n=xi(i);function e(s,o){var r=n((s=A(s)).r,(o=A(o)).r),h=n(s.g,o.g),c=n(s.b,o.b),_=Pt(s.opacity,o.opacity);return function(a){return s.r=r(a),s.g=h(a),s.b=c(a),s.opacity=_(a),s+""}}return e.gamma=t,e}(1);function Rt(t){return function(i){var n=i.length,e=new Array(n),s=new Array(n),o=new Array(n),r,h;for(r=0;r<n;++r)h=A(i[r]),e[r]=h.r||0,s[r]=h.g||0,o[r]=h.b||0;return e=t(e),s=t(s),o=t(o),h.opacity=1,function(c){return h.r=e(c),h.g=s(c),h.b=o(c),h+""}}}var $i=Rt(li),Mi=Rt(fi);function g(t,i){return t=+t,i=+i,function(n){return t*(1-n)+i*n}}var Q=/[-+]?(?:\d+\.?\d*|\.?\d+)(?:[eE][-+]?\d+)?/g,W=new RegExp(Q.source,"g");function pi(t){return function(){return t}}function di(t){return function(i){return t(i)+""}}function Ei(t,i){var n=Q.lastIndex=W.lastIndex=0,e,s,o,r=-1,h=[],c=[];for(t=t+"",i=i+"";(e=Q.exec(t))&&(s=W.exec(i));)(o=s.index)>n&&(o=i.slice(n,o),h[r]?h[r]+=o:h[++r]=o),(e=e[0])===(s=s[0])?h[r]?h[r]+=s:h[++r]=s:(h[++r]=null,c.push({i:r,x:g(e,s)})),n=W.lastIndex;return n<i.length&&(o=i.slice(n),h[r]?h[r]+=o:h[++r]=o),h.length<2?c[0]?di(c[0].x):pi(i):(i=c.length,function(_){for(var a=0,l;a<i;++a)h[(l=c[a]).i]=l.x(_);return h.join("")})}var gt=180/Math.PI,U={translateX:0,translateY:0,rotate:0,skewX:0,scaleX:1,scaleY:1};function qt(t,i,n,e,s,o){var r,h,c;return(r=Math.sqrt(t*t+i*i))&&(t/=r,i/=r),(c=t*n+i*e)&&(n-=t*c,e-=i*c),(h=Math.sqrt(n*n+e*e))&&(n/=h,e/=h,c/=h),t*e<i*n&&(t=-t,i=-i,c=-c,r=-r),{translateX:s,translateY:o,rotate:Math.atan2(i,t)*gt,skewX:Math.atan(c)*gt,scaleX:r,scaleY:h}}var X;function yi(t){const i=new(typeof DOMMatrix=="function"?DOMMatrix:WebKitCSSMatrix)(t+"");return i.isIdentity?U:qt(i.a,i.b,i.c,i.d,i.e,i.f)}function bi(t){return t==null||(X||(X=document.createElementNS("http://www.w3.org/2000/svg","g")),X.setAttribute("transform",t),!(t=X.transform.baseVal.consolidate()))?U:(t=t.matrix,qt(t.a,t.b,t.c,t.d,t.e,t.f))}function Ht(t,i,n,e){function s(_){return _.length?_.pop()+" ":""}function o(_,a,l,f,d,k){if(_!==l||a!==f){var b=d.push("translate(",null,i,null,n);k.push({i:b-4,x:g(_,l)},{i:b-2,x:g(a,f)})}else(l||f)&&d.push("translate("+l+i+f+n)}function r(_,a,l,f){_!==a?(_-a>180?a+=360:a-_>180&&(_+=360),f.push({i:l.push(s(l)+"rotate(",null,e)-2,x:g(_,a)})):a&&l.push(s(l)+"rotate("+a+e)}function h(_,a,l,f){_!==a?f.push({i:l.push(s(l)+"skewX(",null,e)-2,x:g(_,a)}):a&&l.push(s(l)+"skewX("+a+e)}function c(_,a,l,f,d,k){if(_!==l||a!==f){var b=d.push(s(d)+"scale(",null,",",null,")");k.push({i:b-4,x:g(_,l)},{i:b-2,x:g(a,f)})}else(l!==1||f!==1)&&d.push(s(d)+"scale("+l+","+f+")")}return function(_,a){var l=[],f=[];return _=t(_),a=t(a),o(_.translateX,_.translateY,a.translateX,a.translateY,l,f),r(_.rotate,a.rotate,l,f),h(_.skewX,a.skewX,l,f),c(_.scaleX,_.scaleY,a.scaleX,a.scaleY,l,f),_=a=null,function(d){for(var k=-1,b=f.length,_t;++k<b;)l[(_t=f[k]).i]=_t.x(d);return l.join("")}}}var Si=Ht(yi,"px, ","px)","deg)"),Ci=Ht(bi,", ",")",")"),T=0,M=0,$=0,Xt=1e3,Y,E,j=0,v=0,F=0,P=typeof performance=="object"&&performance.now?performance:Date,Ot=typeof window=="object"&&window.requestAnimationFrame?window.requestAnimationFrame.bind(window):function(t){setTimeout(t,17)};function It(){return v||(Ot(gi),v=P.now()+F)}function gi(){v=0}function Z(){this._call=this._time=this._next=null}Z.prototype=wi.prototype={constructor:Z,restart:function(t,i,n){if(typeof t!="function")throw new TypeError("callback is not a function");n=(n==null?It():+n)+(i==null?0:+i),!this._next&&E!==this&&(E?E._next=this:Y=this,E=this),this._call=t,this._time=n,tt()},stop:function(){this._call&&(this._call=null,this._time=1/0,tt())}};function wi(t,i,n){var e=new Z;return e.restart(t,i,n),e}function mi(){It(),++T;for(var t=Y,i;t;)(i=v-t._time)>=0&&t._call.call(void 0,i),t=t._next;--T}function wt(){v=(j=P.now())+F,T=M=0;try{mi()}finally{T=0,ki(),v=0}}function vi(){var t=P.now(),i=t-j;i>Xt&&(F-=i,j=t)}function ki(){for(var t,i=Y,n,e=1/0;i;)i._call?(e>i._time&&(e=i._time),t=i,i=i._next):(n=i._next,i._next=null,i=t?t._next=n:Y=n);E=t,tt(e)}function tt(t){if(!T){M&&(M=clearTimeout(M));var i=t-v;i>24?(t<1/0&&(M=setTimeout(wt,t-P.now()-F)),$&&($=clearInterval($))):($||(j=P.now(),$=setInterval(vi,Xt)),T=1,Ot(wt))}}const Pi=Math.abs,Ri=Math.atan2,qi=Math.cos,Hi=Math.max,Xi=Math.min,Oi=Math.sin,Ii=Math.sqrt,mt=1e-12,st=Math.PI,vt=st/2,Ai=2*st;function Bi(t){return t>1?0:t<-1?st:Math.acos(t)}function Yi(t){return t>=1?vt:t<=-1?-vt:Math.asin(t)}function At(t){this._context=t}At.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._point=0},lineEnd:function(){(this._line||this._line!==0&&this._point===1)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1,this._line?this._context.lineTo(t,i):this._context.moveTo(t,i);break;case 1:this._point=2;default:this._context.lineTo(t,i);break}}};function ji(t){return new At(t)}function y(){}function z(t,i,n){t._context.bezierCurveTo((2*t._x0+t._x1)/3,(2*t._y0+t._y1)/3,(t._x0+2*t._x1)/3,(t._y0+2*t._y1)/3,(t._x0+4*t._x1+i)/6,(t._y0+4*t._y1+n)/6)}function G(t){this._context=t}G.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x0=this._x1=this._y0=this._y1=NaN,this._point=0},lineEnd:function(){switch(this._point){case 3:z(this,this._x1,this._y1);case 2:this._context.lineTo(this._x1,this._y1);break}(this._line||this._line!==0&&this._point===1)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1,this._line?this._context.lineTo(t,i):this._context.moveTo(t,i);break;case 1:this._point=2;break;case 2:this._point=3,this._context.lineTo((5*this._x0+this._x1)/6,(5*this._y0+this._y1)/6);default:z(this,t,i);break}this._x0=this._x1,this._x1=t,this._y0=this._y1,this._y1=i}};function zi(t){return new G(t)}function Bt(t){this._context=t}Bt.prototype={areaStart:y,areaEnd:y,lineStart:function(){this._x0=this._x1=this._x2=this._x3=this._x4=this._y0=this._y1=this._y2=this._y3=this._y4=NaN,this._point=0},lineEnd:function(){switch(this._point){case 1:{this._context.moveTo(this._x2,this._y2),this._context.closePath();break}case 2:{this._context.moveTo((this._x2+2*this._x3)/3,(this._y2+2*this._y3)/3),this._context.lineTo((this._x3+2*this._x2)/3,(this._y3+2*this._y2)/3),this._context.closePath();break}case 3:{this.point(this._x2,this._y2),this.point(this._x3,this._y3),this.point(this._x4,this._y4);break}}},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1,this._x2=t,this._y2=i;break;case 1:this._point=2,this._x3=t,this._y3=i;break;case 2:this._point=3,this._x4=t,this._y4=i,this._context.moveTo((this._x0+4*this._x1+t)/6,(this._y0+4*this._y1+i)/6);break;default:z(this,t,i);break}this._x0=this._x1,this._x1=t,this._y0=this._y1,this._y1=i}};function Li(t){return new Bt(t)}function Yt(t){this._context=t}Yt.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x0=this._x1=this._y0=this._y1=NaN,this._point=0},lineEnd:function(){(this._line||this._line!==0&&this._point===3)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1;break;case 1:this._point=2;break;case 2:this._point=3;var n=(this._x0+4*this._x1+t)/6,e=(this._y0+4*this._y1+i)/6;this._line?this._context.lineTo(n,e):this._context.moveTo(n,e);break;case 3:this._point=4;default:z(this,t,i);break}this._x0=this._x1,this._x1=t,this._y0=this._y1,this._y1=i}};function Di(t){return new Yt(t)}function jt(t,i){this._basis=new G(t),this._beta=i}jt.prototype={lineStart:function(){this._x=[],this._y=[],this._basis.lineStart()},lineEnd:function(){var t=this._x,i=this._y,n=t.length-1;if(n>0)for(var e=t[0],s=i[0],o=t[n]-e,r=i[n]-s,h=-1,c;++h<=n;)c=h/n,this._basis.point(this._beta*t[h]+(1-this._beta)*(e+c*o),this._beta*i[h]+(1-this._beta)*(s+c*r));this._x=this._y=null,this._basis.lineEnd()},point:function(t,i){this._x.push(+t),this._y.push(+i)}};const Fi=function t(i){function n(e){return i===1?new G(e):new jt(e,i)}return n.beta=function(e){return t(+e)},n}(.85);function L(t,i,n){t._context.bezierCurveTo(t._x1+t._k*(t._x2-t._x0),t._y1+t._k*(t._y2-t._y0),t._x2+t._k*(t._x1-i),t._y2+t._k*(t._y1-n),t._x2,t._y2)}function ot(t,i){this._context=t,this._k=(1-i)/6}ot.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x0=this._x1=this._x2=this._y0=this._y1=this._y2=NaN,this._point=0},lineEnd:function(){switch(this._point){case 2:this._context.lineTo(this._x2,this._y2);break;case 3:L(this,this._x1,this._y1);break}(this._line||this._line!==0&&this._point===1)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1,this._line?this._context.lineTo(t,i):this._context.moveTo(t,i);break;case 1:this._point=2,this._x1=t,this._y1=i;break;case 2:this._point=3;default:L(this,t,i);break}this._x0=this._x1,this._x1=this._x2,this._x2=t,this._y0=this._y1,this._y1=this._y2,this._y2=i}};const Gi=function t(i){function n(e){return new ot(e,i)}return n.tension=function(e){return t(+e)},n}(0);function rt(t,i){this._context=t,this._k=(1-i)/6}rt.prototype={areaStart:y,areaEnd:y,lineStart:function(){this._x0=this._x1=this._x2=this._x3=this._x4=this._x5=this._y0=this._y1=this._y2=this._y3=this._y4=this._y5=NaN,this._point=0},lineEnd:function(){switch(this._point){case 1:{this._context.moveTo(this._x3,this._y3),this._context.closePath();break}case 2:{this._context.lineTo(this._x3,this._y3),this._context.closePath();break}case 3:{this.point(this._x3,this._y3),this.point(this._x4,this._y4),this.point(this._x5,this._y5);break}}},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1,this._x3=t,this._y3=i;break;case 1:this._point=2,this._context.moveTo(this._x4=t,this._y4=i);break;case 2:this._point=3,this._x5=t,this._y5=i;break;default:L(this,t,i);break}this._x0=this._x1,this._x1=this._x2,this._x2=t,this._y0=this._y1,this._y1=this._y2,this._y2=i}};const Ki=function t(i){function n(e){return new rt(e,i)}return n.tension=function(e){return t(+e)},n}(0);function ht(t,i){this._context=t,this._k=(1-i)/6}ht.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x0=this._x1=this._x2=this._y0=this._y1=this._y2=NaN,this._point=0},lineEnd:function(){(this._line||this._line!==0&&this._point===3)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1;break;case 1:this._point=2;break;case 2:this._point=3,this._line?this._context.lineTo(this._x2,this._y2):this._context.moveTo(this._x2,this._y2);break;case 3:this._point=4;default:L(this,t,i);break}this._x0=this._x1,this._x1=this._x2,this._x2=t,this._y0=this._y1,this._y1=this._y2,this._y2=i}};const Vi=function t(i){function n(e){return new ht(e,i)}return n.tension=function(e){return t(+e)},n}(0);function at(t,i,n){var e=t._x1,s=t._y1,o=t._x2,r=t._y2;if(t._l01_a>mt){var h=2*t._l01_2a+3*t._l01_a*t._l12_a+t._l12_2a,c=3*t._l01_a*(t._l01_a+t._l12_a);e=(e*h-t._x0*t._l12_2a+t._x2*t._l01_2a)/c,s=(s*h-t._y0*t._l12_2a+t._y2*t._l01_2a)/c}if(t._l23_a>mt){var _=2*t._l23_2a+3*t._l23_a*t._l12_a+t._l12_2a,a=3*t._l23_a*(t._l23_a+t._l12_a);o=(o*_+t._x1*t._l23_2a-i*t._l12_2a)/a,r=(r*_+t._y1*t._l23_2a-n*t._l12_2a)/a}t._context.bezierCurveTo(e,s,o,r,t._x2,t._y2)}function zt(t,i){this._context=t,this._alpha=i}zt.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x0=this._x1=this._x2=this._y0=this._y1=this._y2=NaN,this._l01_a=this._l12_a=this._l23_a=this._l01_2a=this._l12_2a=this._l23_2a=this._point=0},lineEnd:function(){switch(this._point){case 2:this._context.lineTo(this._x2,this._y2);break;case 3:this.point(this._x2,this._y2);break}(this._line||this._line!==0&&this._point===1)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){if(t=+t,i=+i,this._point){var n=this._x2-t,e=this._y2-i;this._l23_a=Math.sqrt(this._l23_2a=Math.pow(n*n+e*e,this._alpha))}switch(this._point){case 0:this._point=1,this._line?this._context.lineTo(t,i):this._context.moveTo(t,i);break;case 1:this._point=2;break;case 2:this._point=3;default:at(this,t,i);break}this._l01_a=this._l12_a,this._l12_a=this._l23_a,this._l01_2a=this._l12_2a,this._l12_2a=this._l23_2a,this._x0=this._x1,this._x1=this._x2,this._x2=t,this._y0=this._y1,this._y1=this._y2,this._y2=i}};const Wi=function t(i){function n(e){return i?new zt(e,i):new ot(e,0)}return n.alpha=function(e){return t(+e)},n}(.5);function Lt(t,i){this._context=t,this._alpha=i}Lt.prototype={areaStart:y,areaEnd:y,lineStart:function(){this._x0=this._x1=this._x2=this._x3=this._x4=this._x5=this._y0=this._y1=this._y2=this._y3=this._y4=this._y5=NaN,this._l01_a=this._l12_a=this._l23_a=this._l01_2a=this._l12_2a=this._l23_2a=this._point=0},lineEnd:function(){switch(this._point){case 1:{this._context.moveTo(this._x3,this._y3),this._context.closePath();break}case 2:{this._context.lineTo(this._x3,this._y3),this._context.closePath();break}case 3:{this.point(this._x3,this._y3),this.point(this._x4,this._y4),this.point(this._x5,this._y5);break}}},point:function(t,i){if(t=+t,i=+i,this._point){var n=this._x2-t,e=this._y2-i;this._l23_a=Math.sqrt(this._l23_2a=Math.pow(n*n+e*e,this._alpha))}switch(this._point){case 0:this._point=1,this._x3=t,this._y3=i;break;case 1:this._point=2,this._context.moveTo(this._x4=t,this._y4=i);break;case 2:this._point=3,this._x5=t,this._y5=i;break;default:at(this,t,i);break}this._l01_a=this._l12_a,this._l12_a=this._l23_a,this._l01_2a=this._l12_2a,this._l12_2a=this._l23_2a,this._x0=this._x1,this._x1=this._x2,this._x2=t,this._y0=this._y1,this._y1=this._y2,this._y2=i}};const Ji=function t(i){function n(e){return i?new Lt(e,i):new rt(e,0)}return n.alpha=function(e){return t(+e)},n}(.5);function Dt(t,i){this._context=t,this._alpha=i}Dt.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x0=this._x1=this._x2=this._y0=this._y1=this._y2=NaN,this._l01_a=this._l12_a=this._l23_a=this._l01_2a=this._l12_2a=this._l23_2a=this._point=0},lineEnd:function(){(this._line||this._line!==0&&this._point===3)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){if(t=+t,i=+i,this._point){var n=this._x2-t,e=this._y2-i;this._l23_a=Math.sqrt(this._l23_2a=Math.pow(n*n+e*e,this._alpha))}switch(this._point){case 0:this._point=1;break;case 1:this._point=2;break;case 2:this._point=3,this._line?this._context.lineTo(this._x2,this._y2):this._context.moveTo(this._x2,this._y2);break;case 3:this._point=4;default:at(this,t,i);break}this._l01_a=this._l12_a,this._l12_a=this._l23_a,this._l01_2a=this._l12_2a,this._l12_2a=this._l23_2a,this._x0=this._x1,this._x1=this._x2,this._x2=t,this._y0=this._y1,this._y1=this._y2,this._y2=i}};const Qi=function t(i){function n(e){return i?new Dt(e,i):new ht(e,0)}return n.alpha=function(e){return t(+e)},n}(.5);function Ft(t){this._context=t}Ft.prototype={areaStart:y,areaEnd:y,lineStart:function(){this._point=0},lineEnd:function(){this._point&&this._context.closePath()},point:function(t,i){t=+t,i=+i,this._point?this._context.lineTo(t,i):(this._point=1,this._context.moveTo(t,i))}};function Ui(t){return new Ft(t)}function kt(t){return t<0?-1:1}function Nt(t,i,n){var e=t._x1-t._x0,s=i-t._x1,o=(t._y1-t._y0)/(e||s<0&&-0),r=(n-t._y1)/(s||e<0&&-0),h=(o*s+r*e)/(e+s);return(kt(o)+kt(r))*Math.min(Math.abs(o),Math.abs(r),.5*Math.abs(h))||0}function Tt(t,i){var n=t._x1-t._x0;return n?(3*(t._y1-t._y0)/n-i)/2:i}function J(t,i,n){var e=t._x0,s=t._y0,o=t._x1,r=t._y1,h=(o-e)/3;t._context.bezierCurveTo(e+h,s+h*i,o-h,r-h*n,o,r)}function D(t){this._context=t}D.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x0=this._x1=this._y0=this._y1=this._t0=NaN,this._point=0},lineEnd:function(){switch(this._point){case 2:this._context.lineTo(this._x1,this._y1);break;case 3:J(this,this._t0,Tt(this,this._t0));break}(this._line||this._line!==0&&this._point===1)&&this._context.closePath(),this._line=1-this._line},point:function(t,i){var n=NaN;if(t=+t,i=+i,!(t===this._x1&&i===this._y1)){switch(this._point){case 0:this._point=1,this._line?this._context.lineTo(t,i):this._context.moveTo(t,i);break;case 1:this._point=2;break;case 2:this._point=3,J(this,Tt(this,n=Nt(this,t,i)),n);break;default:J(this,this._t0,n=Nt(this,t,i));break}this._x0=this._x1,this._x1=t,this._y0=this._y1,this._y1=i,this._t0=n}}};function Gt(t){this._context=new Kt(t)}(Gt.prototype=Object.create(D.prototype)).point=function(t,i){D.prototype.point.call(this,i,t)};function Kt(t){this._context=t}Kt.prototype={moveTo:function(t,i){this._context.moveTo(i,t)},closePath:function(){this._context.closePath()},lineTo:function(t,i){this._context.lineTo(i,t)},bezierCurveTo:function(t,i,n,e,s,o){this._context.bezierCurveTo(i,t,e,n,o,s)}};function Zi(t){return new D(t)}function tn(t){return new Gt(t)}function Vt(t){this._context=t}Vt.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x=[],this._y=[]},lineEnd:function(){var t=this._x,i=this._y,n=t.length;if(n)if(this._line?this._context.lineTo(t[0],i[0]):this._context.moveTo(t[0],i[0]),n===2)this._context.lineTo(t[1],i[1]);else for(var e=$t(t),s=$t(i),o=0,r=1;r<n;++o,++r)this._context.bezierCurveTo(e[0][o],s[0][o],e[1][o],s[1][o],t[r],i[r]);(this._line||this._line!==0&&n===1)&&this._context.closePath(),this._line=1-this._line,this._x=this._y=null},point:function(t,i){this._x.push(+t),this._y.push(+i)}};function $t(t){var i,n=t.length-1,e,s=new Array(n),o=new Array(n),r=new Array(n);for(s[0]=0,o[0]=2,r[0]=t[0]+2*t[1],i=1;i<n-1;++i)s[i]=1,o[i]=4,r[i]=4*t[i]+2*t[i+1];for(s[n-1]=2,o[n-1]=7,r[n-1]=8*t[n-1]+t[n],i=1;i<n;++i)e=s[i]/o[i-1],o[i]-=e,r[i]-=e*r[i-1];for(s[n-1]=r[n-1]/o[n-1],i=n-2;i>=0;--i)s[i]=(r[i]-s[i+1])/o[i];for(o[n-1]=(t[n]+s[n-1])/2,i=0;i<n-1;++i)o[i]=2*t[i+1]-s[i+1];return[s,o]}function nn(t){return new Vt(t)}function K(t,i){this._context=t,this._t=i}K.prototype={areaStart:function(){this._line=0},areaEnd:function(){this._line=NaN},lineStart:function(){this._x=this._y=NaN,this._point=0},lineEnd:function(){0<this._t&&this._t<1&&this._point===2&&this._context.lineTo(this._x,this._y),(this._line||this._line!==0&&this._point===1)&&this._context.closePath(),this._line>=0&&(this._t=1-this._t,this._line=1-this._line)},point:function(t,i){switch(t=+t,i=+i,this._point){case 0:this._point=1,this._line?this._context.lineTo(t,i):this._context.moveTo(t,i);break;case 1:this._point=2;default:{if(this._t<=0)this._context.lineTo(this._x,i),this._context.lineTo(t,i);else{var n=this._x*(1-this._t)+t*this._t;this._context.lineTo(n,this._y),this._context.lineTo(n,i)}break}}this._x=t,this._y=i}};function en(t){return new K(t,.5)}function sn(t){return new K(t,0)}function on(t){return new K(t,1)}export{Ri as $,sn as A,ai as B,it as C,Mt as D,R as E,I as F,S as G,Ni as H,ci as I,Pt as J,li as K,fi as L,$i as M,Mi as N,Ai as O,Ii as P,st as Q,u as R,A as S,Z as T,et as U,qi as V,Oi as W,vt as X,mt as Y,Xi as Z,Pi as _,Ti as a,Yi as a0,Bi as a1,Hi as a2,Ei as b,nt as c,Jt as d,Ci as e,Si as f,zi as g,Li as h,g as i,Di as j,Fi as k,Ki as l,Vi as m,It as n,Gi as o,Ji as p,Qi as q,Wi as r,ji as s,wi as t,Ui as u,Zi as v,tn as w,nn as x,en as y,on as z};