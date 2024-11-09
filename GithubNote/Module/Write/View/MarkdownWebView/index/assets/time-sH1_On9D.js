import{C as de,D as Ze,R as Pe,E as Re,B as Yn,J as K,H as xn}from"./step-BPifGoz3.js";import{r as Hn,s as Se,C as Wn,h as Ln}from"./linear-BEEXOqrH.js";import{i as Nn}from"./init-Dmth1JHB.js";function ur(e,n){let t;if(n===void 0)for(const r of e)r!=null&&(t<r||t===void 0&&r>=r)&&(t=r);else{let r=-1;for(let i of e)(i=n(i,++r,e))!=null&&(t<i||t===void 0&&i>=i)&&(t=i)}return t}function or(e,n){let t;if(n===void 0)for(const r of e)r!=null&&(t>r||t===void 0&&r>=r)&&(t=r);else{let r=-1;for(let i of e)(i=n(i,++r,e))!=null&&(t>i||t===void 0&&i>=i)&&(t=i)}return t}const kn=Math.PI/180,In=180/Math.PI,ee=18,ze=.96422,qe=1,Qe=.82521,Ve=4/29,Q=6/29,_e=3*Q*Q,On=Q*Q*Q;function Je(e){if(e instanceof x)return new x(e.l,e.a,e.b,e.opacity);if(e instanceof L)return Xe(e);e instanceof Pe||(e=Yn(e));var n=fe(e.r),t=fe(e.g),r=fe(e.b),i=ce((.2225045*n+.7168786*t+.0606169*r)/qe),o,c;return n===t&&t===r?o=c=i:(o=ce((.4360747*n+.3850649*t+.1430804*r)/ze),c=ce((.0139322*n+.0971045*t+.7141733*r)/Qe)),new x(116*i-16,500*(o-i),200*(i-c),e.opacity)}function An(e,n,t,r){return arguments.length===1?Je(e):new x(e,n,t,r??1)}function x(e,n,t,r){this.l=+e,this.a=+n,this.b=+t,this.opacity=+r}de(x,An,Ze(Re,{brighter(e){return new x(this.l+ee*(e??1),this.a,this.b,this.opacity)},darker(e){return new x(this.l-ee*(e??1),this.a,this.b,this.opacity)},rgb(){var e=(this.l+16)/116,n=isNaN(this.a)?e:e+this.a/500,t=isNaN(this.b)?e:e-this.b/200;return n=ze*se(n),e=qe*se(e),t=Qe*se(t),new Pe(le(3.1338561*n-1.6168667*e-.4906146*t),le(-.9787684*n+1.9161415*e+.033454*t),le(.0719453*n-.2289914*e+1.4052427*t),this.opacity)}}));function ce(e){return e>On?Math.pow(e,1/3):e/_e+Ve}function se(e){return e>Q?e*e*e:_e*(e-Ve)}function le(e){return 255*(e<=.0031308?12.92*e:1.055*Math.pow(e,1/2.4)-.055)}function fe(e){return(e/=255)<=.04045?e/12.92:Math.pow((e+.055)/1.055,2.4)}function dn(e){if(e instanceof L)return new L(e.h,e.c,e.l,e.opacity);if(e instanceof x||(e=Je(e)),e.a===0&&e.b===0)return new L(NaN,0<e.l&&e.l<100?0:NaN,e.l,e.opacity);var n=Math.atan2(e.b,e.a)*In;return new L(n<0?n+360:n,Math.sqrt(e.a*e.a+e.b*e.b),e.l,e.opacity)}function Me(e,n,t,r){return arguments.length===1?dn(e):new L(e,n,t,r??1)}function L(e,n,t,r){this.h=+e,this.c=+n,this.l=+t,this.opacity=+r}function Xe(e){if(isNaN(e.h))return new x(e.l,0,0,e.opacity);var n=e.h*kn;return new x(e.l,Math.cos(n)*e.c,Math.sin(n)*e.c,e.opacity)}de(L,Me,Ze(Re,{brighter(e){return new L(this.h,this.c,this.l+ee*(e??1),this.opacity)},darker(e){return new L(this.h,this.c,this.l-ee*(e??1),this.opacity)},rgb(){return Xe(this).rgb()}}));function Be(e){return function(n,t){var r=e((n=Me(n)).h,(t=Me(t)).h),i=K(n.c,t.c),o=K(n.l,t.l),c=K(n.opacity,t.opacity);return function(h){return n.h=r(h),n.c=i(h),n.l=o(h),n.opacity=c(h),n+""}}}const ar=Be(xn);var ir=Be(K);function Zn(e,n){e=e.slice();var t=0,r=e.length-1,i=e[t],o=e[r],c;return o<i&&(c=t,t=r,r=c,c=i,i=o,o=c),e[t]=n.floor(i),e[r]=n.ceil(o),e}const ge=new Date,he=new Date;function M(e,n,t,r){function i(o){return e(o=arguments.length===0?new Date:new Date(+o)),o}return i.floor=o=>(e(o=new Date(+o)),o),i.ceil=o=>(e(o=new Date(o-1)),n(o,1),e(o),o),i.round=o=>{const c=i(o),h=i.ceil(o);return o-c<h-o?c:h},i.offset=(o,c)=>(n(o=new Date(+o),c==null?1:Math.floor(c)),o),i.range=(o,c,h)=>{const U=[];if(o=i.ceil(o),h=h==null?1:Math.floor(h),!(o<c)||!(h>0))return U;let y;do U.push(y=new Date(+o)),n(o,h),e(o);while(y<o&&o<c);return U},i.filter=o=>M(c=>{if(c>=c)for(;e(c),!o(c);)c.setTime(c-1)},(c,h)=>{if(c>=c)if(h<0)for(;++h<=0;)for(;n(c,-1),!o(c););else for(;--h>=0;)for(;n(c,1),!o(c););}),t&&(i.count=(o,c)=>(ge.setTime(+o),he.setTime(+c),e(ge),e(he),Math.floor(t(ge,he))),i.every=o=>(o=Math.floor(o),!isFinite(o)||!(o>0)?null:o>1?i.filter(r?c=>r(c)%o===0:c=>i.count(0,c)%o===0):i)),i}const ne=M(()=>{},(e,n)=>{e.setTime(+e+n)},(e,n)=>n-e);ne.every=e=>(e=Math.floor(e),!isFinite(e)||!(e>0)?null:e>1?M(n=>{n.setTime(Math.floor(n/e)*e)},(n,t)=>{n.setTime(+n+t*e)},(n,t)=>(t-n)/e):ne);ne.range;const N=1e3,Y=N*60,k=Y*60,I=k*24,Ce=I*7,Fe=I*30,me=I*365,q=M(e=>{e.setTime(e-e.getMilliseconds())},(e,n)=>{e.setTime(+e+n*N)},(e,n)=>(n-e)/N,e=>e.getUTCSeconds());q.range;const Ue=M(e=>{e.setTime(e-e.getMilliseconds()-e.getSeconds()*N)},(e,n)=>{e.setTime(+e+n*Y)},(e,n)=>(n-e)/Y,e=>e.getMinutes());Ue.range;const $e=M(e=>{e.setUTCSeconds(0,0)},(e,n)=>{e.setTime(+e+n*Y)},(e,n)=>(n-e)/Y,e=>e.getUTCMinutes());$e.range;const De=M(e=>{e.setTime(e-e.getMilliseconds()-e.getSeconds()*N-e.getMinutes()*Y)},(e,n)=>{e.setTime(+e+n*k)},(e,n)=>(n-e)/k,e=>e.getHours());De.range;const je=M(e=>{e.setUTCMinutes(0,0,0)},(e,n)=>{e.setTime(+e+n*k)},(e,n)=>(n-e)/k,e=>e.getUTCHours());je.range;const G=M(e=>e.setHours(0,0,0,0),(e,n)=>e.setDate(e.getDate()+n),(e,n)=>(n-e-(n.getTimezoneOffset()-e.getTimezoneOffset())*Y)/I,e=>e.getDate()-1);G.range;const pe=M(e=>{e.setUTCHours(0,0,0,0)},(e,n)=>{e.setUTCDate(e.getUTCDate()+n)},(e,n)=>(n-e)/I,e=>e.getUTCDate()-1);pe.range;const Ge=M(e=>{e.setUTCHours(0,0,0,0)},(e,n)=>{e.setUTCDate(e.getUTCDate()+n)},(e,n)=>(n-e)/I,e=>Math.floor(e/I));Ge.range;function P(e){return M(n=>{n.setDate(n.getDate()-(n.getDay()+7-e)%7),n.setHours(0,0,0,0)},(n,t)=>{n.setDate(n.getDate()+t*7)},(n,t)=>(t-n-(t.getTimezoneOffset()-n.getTimezoneOffset())*Y)/Ce)}const ue=P(0),te=P(1),Pn=P(2),Rn=P(3),V=P(4),zn=P(5),qn=P(6);ue.range;te.range;Pn.range;Rn.range;V.range;zn.range;qn.range;function R(e){return M(n=>{n.setUTCDate(n.getUTCDate()-(n.getUTCDay()+7-e)%7),n.setUTCHours(0,0,0,0)},(n,t)=>{n.setUTCDate(n.getUTCDate()+t*7)},(n,t)=>(t-n)/Ce)}const ve=R(0),re=R(1),Qn=R(2),Vn=R(3),_=R(4),_n=R(5),Jn=R(6);ve.range;re.range;Qn.range;Vn.range;_.range;_n.range;Jn.range;const we=M(e=>{e.setDate(1),e.setHours(0,0,0,0)},(e,n)=>{e.setMonth(e.getMonth()+n)},(e,n)=>n.getMonth()-e.getMonth()+(n.getFullYear()-e.getFullYear())*12,e=>e.getMonth());we.range;const Ee=M(e=>{e.setUTCDate(1),e.setUTCHours(0,0,0,0)},(e,n)=>{e.setUTCMonth(e.getUTCMonth()+n)},(e,n)=>n.getUTCMonth()-e.getUTCMonth()+(n.getUTCFullYear()-e.getUTCFullYear())*12,e=>e.getUTCMonth());Ee.range;const O=M(e=>{e.setMonth(0,1),e.setHours(0,0,0,0)},(e,n)=>{e.setFullYear(e.getFullYear()+n)},(e,n)=>n.getFullYear()-e.getFullYear(),e=>e.getFullYear());O.every=e=>!isFinite(e=Math.floor(e))||!(e>0)?null:M(n=>{n.setFullYear(Math.floor(n.getFullYear()/e)*e),n.setMonth(0,1),n.setHours(0,0,0,0)},(n,t)=>{n.setFullYear(n.getFullYear()+t*e)});O.range;const d=M(e=>{e.setUTCMonth(0,1),e.setUTCHours(0,0,0,0)},(e,n)=>{e.setUTCFullYear(e.getUTCFullYear()+n)},(e,n)=>n.getUTCFullYear()-e.getUTCFullYear(),e=>e.getUTCFullYear());d.every=e=>!isFinite(e=Math.floor(e))||!(e>0)?null:M(n=>{n.setUTCFullYear(Math.floor(n.getUTCFullYear()/e)*e),n.setUTCMonth(0,1),n.setUTCHours(0,0,0,0)},(n,t)=>{n.setUTCFullYear(n.getUTCFullYear()+t*e)});d.range;function Ke(e,n,t,r,i,o){const c=[[q,1,N],[q,5,5*N],[q,15,15*N],[q,30,30*N],[o,1,Y],[o,5,5*Y],[o,15,15*Y],[o,30,30*Y],[i,1,k],[i,3,3*k],[i,6,6*k],[i,12,12*k],[r,1,I],[r,2,2*I],[t,1,Ce],[n,1,Fe],[n,3,3*Fe],[e,1,me]];function h(y,T,F){const D=T<y;D&&([y,T]=[T,y]);const w=F&&typeof F.range=="function"?F:U(y,T,F),A=w?w.range(y,+T+1):[];return D?A.reverse():A}function U(y,T,F){const D=Math.abs(T-y)/F,w=Hn(([,,X])=>X).right(c,D);if(w===c.length)return e.every(Se(y/me,T/me,F));if(w===0)return ne.every(Math.max(Se(y,T,F),1));const[A,J]=c[D/c[w-1][2]<c[w][2]/D?w-1:w];return A.every(J)}return[h,U]}const[cr,sr]=Ke(d,Ee,ve,Ge,je,$e),[Xn,Bn]=Ke(O,we,ue,G,De,Ue);function ye(e){if(0<=e.y&&e.y<100){var n=new Date(-1,e.m,e.d,e.H,e.M,e.S,e.L);return n.setFullYear(e.y),n}return new Date(e.y,e.m,e.d,e.H,e.M,e.S,e.L)}function Te(e){if(0<=e.y&&e.y<100){var n=new Date(Date.UTC(-1,e.m,e.d,e.H,e.M,e.S,e.L));return n.setUTCFullYear(e.y),n}return new Date(Date.UTC(e.y,e.m,e.d,e.H,e.M,e.S,e.L))}function B(e,n,t){return{y:e,m:n,d:t,H:0,M:0,S:0,L:0}}function $n(e){var n=e.dateTime,t=e.date,r=e.time,i=e.periods,o=e.days,c=e.shortDays,h=e.months,U=e.shortMonths,y=$(i),T=j(i),F=$(o),D=j(o),w=$(c),A=j(c),J=$(h),X=j(h),oe=$(U),ae=j(U),H={a:yn,A:Tn,b:Mn,B:Cn,c:null,d:Ne,e:Ne,f:Ct,g:xt,G:Wt,H:yt,I:Tt,j:Mt,L:en,m:Ut,M:Dt,p:Un,q:Dn,Q:Oe,s:Ae,S:pt,u:vt,U:wt,V:bt,w:St,W:Ft,x:null,X:null,y:Yt,Y:Ht,Z:Lt,"%":Ie},W={a:pn,A:vn,b:wn,B:bn,c:null,d:ke,e:ke,f:Ot,g:_t,G:Xt,H:Nt,I:kt,j:It,L:tn,m:At,M:dt,p:Sn,q:Fn,Q:Oe,s:Ae,S:Zt,u:Pt,U:Rt,V:zt,w:qt,W:Qt,x:null,X:null,y:Vt,Y:Jt,Z:Bt,"%":Ie},ie={a:cn,A:sn,b:ln,B:fn,c:gn,d:We,e:We,f:ft,g:He,G:xe,H:Le,I:Le,j:it,L:lt,m:at,M:ct,p:an,q:ot,Q:ht,s:mt,S:st,u:et,U:nt,V:tt,w:Kn,W:rt,x:hn,X:mn,y:He,Y:xe,Z:ut,"%":gt};H.x=s(t,H),H.X=s(r,H),H.c=s(n,H),W.x=s(t,W),W.X=s(r,W),W.c=s(n,W);function s(a,l){return function(f){var u=[],v=-1,m=0,b=a.length,S,Z,be;for(f instanceof Date||(f=new Date(+f));++v<b;)a.charCodeAt(v)===37&&(u.push(a.slice(m,v)),(Z=Ye[S=a.charAt(++v)])!=null?S=a.charAt(++v):Z=S==="e"?" ":"0",(be=l[S])&&(S=be(f,Z)),u.push(S),m=v+1);return u.push(a.slice(m,v)),u.join("")}}function p(a,l){return function(f){var u=B(1900,void 0,1),v=E(u,a,f+="",0),m,b;if(v!=f.length)return null;if("Q"in u)return new Date(u.Q);if("s"in u)return new Date(u.s*1e3+("L"in u?u.L:0));if(l&&!("Z"in u)&&(u.Z=0),"p"in u&&(u.H=u.H%12+u.p*12),u.m===void 0&&(u.m="q"in u?u.q:0),"V"in u){if(u.V<1||u.V>53)return null;"w"in u||(u.w=1),"Z"in u?(m=Te(B(u.y,0,1)),b=m.getUTCDay(),m=b>4||b===0?re.ceil(m):re(m),m=pe.offset(m,(u.V-1)*7),u.y=m.getUTCFullYear(),u.m=m.getUTCMonth(),u.d=m.getUTCDate()+(u.w+6)%7):(m=ye(B(u.y,0,1)),b=m.getDay(),m=b>4||b===0?te.ceil(m):te(m),m=G.offset(m,(u.V-1)*7),u.y=m.getFullYear(),u.m=m.getMonth(),u.d=m.getDate()+(u.w+6)%7)}else("W"in u||"U"in u)&&("w"in u||(u.w="u"in u?u.u%7:"W"in u?1:0),b="Z"in u?Te(B(u.y,0,1)).getUTCDay():ye(B(u.y,0,1)).getDay(),u.m=0,u.d="W"in u?(u.w+6)%7+u.W*7-(b+5)%7:u.w+u.U*7-(b+6)%7);return"Z"in u?(u.H+=u.Z/100|0,u.M+=u.Z%100,Te(u)):ye(u)}}function E(a,l,f,u){for(var v=0,m=l.length,b=f.length,S,Z;v<m;){if(u>=b)return-1;if(S=l.charCodeAt(v++),S===37){if(S=l.charAt(v++),Z=ie[S in Ye?l.charAt(v++):S],!Z||(u=Z(a,f,u))<0)return-1}else if(S!=f.charCodeAt(u++))return-1}return u}function an(a,l,f){var u=y.exec(l.slice(f));return u?(a.p=T.get(u[0].toLowerCase()),f+u[0].length):-1}function cn(a,l,f){var u=w.exec(l.slice(f));return u?(a.w=A.get(u[0].toLowerCase()),f+u[0].length):-1}function sn(a,l,f){var u=F.exec(l.slice(f));return u?(a.w=D.get(u[0].toLowerCase()),f+u[0].length):-1}function ln(a,l,f){var u=oe.exec(l.slice(f));return u?(a.m=ae.get(u[0].toLowerCase()),f+u[0].length):-1}function fn(a,l,f){var u=J.exec(l.slice(f));return u?(a.m=X.get(u[0].toLowerCase()),f+u[0].length):-1}function gn(a,l,f){return E(a,n,l,f)}function hn(a,l,f){return E(a,t,l,f)}function mn(a,l,f){return E(a,r,l,f)}function yn(a){return c[a.getDay()]}function Tn(a){return o[a.getDay()]}function Mn(a){return U[a.getMonth()]}function Cn(a){return h[a.getMonth()]}function Un(a){return i[+(a.getHours()>=12)]}function Dn(a){return 1+~~(a.getMonth()/3)}function pn(a){return c[a.getUTCDay()]}function vn(a){return o[a.getUTCDay()]}function wn(a){return U[a.getUTCMonth()]}function bn(a){return h[a.getUTCMonth()]}function Sn(a){return i[+(a.getUTCHours()>=12)]}function Fn(a){return 1+~~(a.getUTCMonth()/3)}return{format:function(a){var l=s(a+="",H);return l.toString=function(){return a},l},parse:function(a){var l=p(a+="",!1);return l.toString=function(){return a},l},utcFormat:function(a){var l=s(a+="",W);return l.toString=function(){return a},l},utcParse:function(a){var l=p(a+="",!0);return l.toString=function(){return a},l}}}var Ye={"-":"",_:" ",0:"0"},C=/^\s*\d+/,jn=/^%/,Gn=/[\\^$*+?|[\]().{}]/g;function g(e,n,t){var r=e<0?"-":"",i=(r?-e:e)+"",o=i.length;return r+(o<t?new Array(t-o+1).join(n)+i:i)}function En(e){return e.replace(Gn,"\\$&")}function $(e){return new RegExp("^(?:"+e.map(En).join("|")+")","i")}function j(e){return new Map(e.map((n,t)=>[n.toLowerCase(),t]))}function Kn(e,n,t){var r=C.exec(n.slice(t,t+1));return r?(e.w=+r[0],t+r[0].length):-1}function et(e,n,t){var r=C.exec(n.slice(t,t+1));return r?(e.u=+r[0],t+r[0].length):-1}function nt(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.U=+r[0],t+r[0].length):-1}function tt(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.V=+r[0],t+r[0].length):-1}function rt(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.W=+r[0],t+r[0].length):-1}function xe(e,n,t){var r=C.exec(n.slice(t,t+4));return r?(e.y=+r[0],t+r[0].length):-1}function He(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.y=+r[0]+(+r[0]>68?1900:2e3),t+r[0].length):-1}function ut(e,n,t){var r=/^(Z)|([+-]\d\d)(?::?(\d\d))?/.exec(n.slice(t,t+6));return r?(e.Z=r[1]?0:-(r[2]+(r[3]||"00")),t+r[0].length):-1}function ot(e,n,t){var r=C.exec(n.slice(t,t+1));return r?(e.q=r[0]*3-3,t+r[0].length):-1}function at(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.m=r[0]-1,t+r[0].length):-1}function We(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.d=+r[0],t+r[0].length):-1}function it(e,n,t){var r=C.exec(n.slice(t,t+3));return r?(e.m=0,e.d=+r[0],t+r[0].length):-1}function Le(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.H=+r[0],t+r[0].length):-1}function ct(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.M=+r[0],t+r[0].length):-1}function st(e,n,t){var r=C.exec(n.slice(t,t+2));return r?(e.S=+r[0],t+r[0].length):-1}function lt(e,n,t){var r=C.exec(n.slice(t,t+3));return r?(e.L=+r[0],t+r[0].length):-1}function ft(e,n,t){var r=C.exec(n.slice(t,t+6));return r?(e.L=Math.floor(r[0]/1e3),t+r[0].length):-1}function gt(e,n,t){var r=jn.exec(n.slice(t,t+1));return r?t+r[0].length:-1}function ht(e,n,t){var r=C.exec(n.slice(t));return r?(e.Q=+r[0],t+r[0].length):-1}function mt(e,n,t){var r=C.exec(n.slice(t));return r?(e.s=+r[0],t+r[0].length):-1}function Ne(e,n){return g(e.getDate(),n,2)}function yt(e,n){return g(e.getHours(),n,2)}function Tt(e,n){return g(e.getHours()%12||12,n,2)}function Mt(e,n){return g(1+G.count(O(e),e),n,3)}function en(e,n){return g(e.getMilliseconds(),n,3)}function Ct(e,n){return en(e,n)+"000"}function Ut(e,n){return g(e.getMonth()+1,n,2)}function Dt(e,n){return g(e.getMinutes(),n,2)}function pt(e,n){return g(e.getSeconds(),n,2)}function vt(e){var n=e.getDay();return n===0?7:n}function wt(e,n){return g(ue.count(O(e)-1,e),n,2)}function nn(e){var n=e.getDay();return n>=4||n===0?V(e):V.ceil(e)}function bt(e,n){return e=nn(e),g(V.count(O(e),e)+(O(e).getDay()===4),n,2)}function St(e){return e.getDay()}function Ft(e,n){return g(te.count(O(e)-1,e),n,2)}function Yt(e,n){return g(e.getFullYear()%100,n,2)}function xt(e,n){return e=nn(e),g(e.getFullYear()%100,n,2)}function Ht(e,n){return g(e.getFullYear()%1e4,n,4)}function Wt(e,n){var t=e.getDay();return e=t>=4||t===0?V(e):V.ceil(e),g(e.getFullYear()%1e4,n,4)}function Lt(e){var n=e.getTimezoneOffset();return(n>0?"-":(n*=-1,"+"))+g(n/60|0,"0",2)+g(n%60,"0",2)}function ke(e,n){return g(e.getUTCDate(),n,2)}function Nt(e,n){return g(e.getUTCHours(),n,2)}function kt(e,n){return g(e.getUTCHours()%12||12,n,2)}function It(e,n){return g(1+pe.count(d(e),e),n,3)}function tn(e,n){return g(e.getUTCMilliseconds(),n,3)}function Ot(e,n){return tn(e,n)+"000"}function At(e,n){return g(e.getUTCMonth()+1,n,2)}function dt(e,n){return g(e.getUTCMinutes(),n,2)}function Zt(e,n){return g(e.getUTCSeconds(),n,2)}function Pt(e){var n=e.getUTCDay();return n===0?7:n}function Rt(e,n){return g(ve.count(d(e)-1,e),n,2)}function rn(e){var n=e.getUTCDay();return n>=4||n===0?_(e):_.ceil(e)}function zt(e,n){return e=rn(e),g(_.count(d(e),e)+(d(e).getUTCDay()===4),n,2)}function qt(e){return e.getUTCDay()}function Qt(e,n){return g(re.count(d(e)-1,e),n,2)}function Vt(e,n){return g(e.getUTCFullYear()%100,n,2)}function _t(e,n){return e=rn(e),g(e.getUTCFullYear()%100,n,2)}function Jt(e,n){return g(e.getUTCFullYear()%1e4,n,4)}function Xt(e,n){var t=e.getUTCDay();return e=t>=4||t===0?_(e):_.ceil(e),g(e.getUTCFullYear()%1e4,n,4)}function Bt(){return"+0000"}function Ie(){return"%"}function Oe(e){return+e}function Ae(e){return Math.floor(+e/1e3)}var z,un,$t,jt,Gt;Et({dateTime:"%x, %X",date:"%-m/%-d/%Y",time:"%-I:%M:%S %p",periods:["AM","PM"],days:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],shortDays:["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],months:["January","February","March","April","May","June","July","August","September","October","November","December"],shortMonths:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]});function Et(e){return z=$n(e),un=z.format,$t=z.parse,jt=z.utcFormat,Gt=z.utcParse,z}function Kt(e){return new Date(e)}function er(e){return e instanceof Date?+e:+new Date(+e)}function on(e,n,t,r,i,o,c,h,U,y){var T=Wn(),F=T.invert,D=T.domain,w=y(".%L"),A=y(":%S"),J=y("%I:%M"),X=y("%I %p"),oe=y("%a %d"),ae=y("%b %d"),H=y("%B"),W=y("%Y");function ie(s){return(U(s)<s?w:h(s)<s?A:c(s)<s?J:o(s)<s?X:r(s)<s?i(s)<s?oe:ae:t(s)<s?H:W)(s)}return T.invert=function(s){return new Date(F(s))},T.domain=function(s){return arguments.length?D(Array.from(s,er)):D().map(Kt)},T.ticks=function(s){var p=D();return e(p[0],p[p.length-1],s??10)},T.tickFormat=function(s,p){return p==null?ie:y(p)},T.nice=function(s){var p=D();return(!s||typeof s.range!="function")&&(s=n(p[0],p[p.length-1],s??10)),s?D(Zn(p,s)):T},T.copy=function(){return Ln(T,on(e,n,t,r,i,o,c,h,U,y))},T}function lr(){return Nn.apply(on(Xn,Bn,O,we,ue,G,De,Ue,q,un).domain([new Date(2e3,0,1),new Date(2e3,0,2)]),arguments)}export{$n as A,un as B,$t as C,Gt as D,lr as E,Me as F,te as G,Pn as H,Rn as I,V as J,zn as K,qn as L,ur as a,$e as b,on as c,In as d,je as e,pe as f,ve as g,ir as h,ar as i,Ee as j,d as k,An as l,or as m,Zn as n,sr as o,cr as p,we as q,kn as r,q as s,O as t,jt as u,ue as v,G as w,De as x,Ue as y,ne as z};
