(function(a){var y=a.languages.javascript["template-string"],q=y.pattern.source,d=y.inside.interpolation,w=d.inside["interpolation-punctuation"],O=d.pattern.source;function v(t,r){if(a.languages[t])return{pattern:RegExp("((?:"+r+")\\s*)"+q),lookbehind:!0,greedy:!0,inside:{"template-punctuation":{pattern:/^`|`$/,alias:"string"},"embedded-code":{pattern:/[\s\S]+/,alias:t}}}}function T(t,r){return"___"+r.toUpperCase()+"_"+t+"___"}function A(t,r,e){var n={code:t,grammar:r,language:e};return a.hooks.run("before-tokenize",n),n.tokens=a.tokenize(n.code,n.grammar),a.hooks.run("after-tokenize",n),n.tokens}function E(t){var r={};r["interpolation-punctuation"]=w;var e=a.tokenize(t,r);if(e.length===3){var n=[1,1];n.push.apply(n,A(e[1],a.languages.javascript,"javascript")),e.splice.apply(e,n)}return new a.Token("interpolation",e,d.alias,t)}function R(t,r,e){var n=a.tokenize(t,{interpolation:{pattern:RegExp(O),lookbehind:!0}}),g=0,u={},o=A(n.map(function(l){if(typeof l=="string")return l;for(var i,p=l.content;t.indexOf(i=T(g++,e))!==-1;);return u[i]=p,i}).join(""),r,e),c=Object.keys(u);return g=0,function l(i){for(var p=0;p<i.length;p++){if(g>=c.length)return;var s=i[p];if(typeof s=="string"||typeof s.content=="string"){var k=c[g],m=typeof s=="string"?s:s.content,b=m.indexOf(k);if(b!==-1){++g;var x=m.substring(0,b),B=E(u[k]),_=m.substring(b+k.length),f=[];if(x&&f.push(x),f.push(B),_){var z=[_];l(z),f.push.apply(f,z)}typeof s=="string"?(i.splice.apply(i,[p,1].concat(f)),p+=f.length-1):s.content=f}}else{var j=s.content;Array.isArray(j)?l(j):l([j])}}}(o),new a.Token(e,o,"language-"+e,t)}a.languages.javascript["template-string"]=[v("css","\\b(?:styled(?:\\([^)]*\\))?(?:\\s*\\.\\s*\\w+(?:\\([^)]*\\))*)*|css(?:\\s*\\.\\s*(?:global|resolve))?|createGlobalStyle|keyframes)"),v("html","\\bhtml|\\.\\s*(?:inner|outer)HTML\\s*\\+?="),v("svg","\\bsvg"),v("markdown","\\b(?:markdown|md)"),v("graphql","\\b(?:gql|graphql(?:\\s*\\.\\s*experimental)?)"),v("sql","\\bsql"),y].filter(Boolean);var S={javascript:!0,js:!0,typescript:!0,ts:!0,jsx:!0,tsx:!0};function h(t){return typeof t=="string"?t:Array.isArray(t)?t.map(h).join(""):h(t.content)}a.hooks.add("after-tokenize",function(t){t.language in S&&function r(e){for(var n=0,g=e.length;n<g;n++){var u=e[n];if(typeof u!="string"){var o=u.content;if(Array.isArray(o))if(u.type==="template-string"){var c=o[1];if(o.length===3&&typeof c!="string"&&c.type==="embedded-code"){var l=h(c),i=c.alias,p=Array.isArray(i)?i[0]:i,s=a.languages[p];if(!s)continue;o[1]=R(l,s,p)}}else r(o);else typeof o!="string"&&r([o])}}}(t.tokens)})})(Prism);