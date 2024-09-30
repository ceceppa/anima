"use strict";(self.webpackChunkdoc=self.webpackChunkdoc||[]).push([[958],{3905:function(e,t,n){n.d(t,{Zo:function(){return u},kt:function(){return v}});var r=n(7294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var c=r.createContext({}),s=function(e){var t=r.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},u=function(e){var t=s(e.components);return r.createElement(c.Provider,{value:t},e.children)},p="mdxType",m={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},f=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,i=e.originalType,c=e.parentName,u=l(e,["components","mdxType","originalType","parentName"]),p=s(n),f=a,v=p["".concat(c,".").concat(f)]||p[f]||m[f]||i;return n?r.createElement(v,o(o({ref:t},u),{},{components:n})):r.createElement(v,o({ref:t},u))}));function v(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var i=n.length,o=new Array(i);o[0]=f;var l={};for(var c in t)hasOwnProperty.call(t,c)&&(l[c]=t[c]);l.originalType=e,l[p]="string"==typeof e?e:a,o[1]=l;for(var s=2;s<i;s++)o[s]=n[s];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}f.displayName="MDXCreateElement"},1218:function(e,t,n){n.r(t),n.d(t,{assets:function(){return c},contentTitle:function(){return o},default:function(){return m},frontMatter:function(){return i},metadata:function(){return l},toc:function(){return s}});var r=n(3117),a=(n(7294),n(3905));const i={sidebar_position:3},o="Animate relative value",l={unversionedId:"basics/relative",id:"basics/relative",title:"Animate relative value",description:"Anima allows us to animate any property to an absolute or relative final value.",source:"@site/tutorials/basics/relative.md",sourceDirName:"basics",slug:"/basics/relative",permalink:"/anima/tutorials/basics/relative",draft:!1,tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"tutorialSidebar",previous:{title:"Multiple animations",permalink:"/anima/tutorials/basics/multiple-animations"},next:{title:"Dynamic values",permalink:"/anima/tutorials/basics/dynamic-value"}},c={},s=[{value:"Example",id:"example",level:2}],u={toc:s},p="wrapper";function m(e){let{components:t,...n}=e;return(0,a.kt)(p,(0,r.Z)({},u,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"animate-relative-value"},"Animate relative value"),(0,a.kt)("p",null,"Anima allows us to animate any property to an absolute or relative final value.\nPositions can be animated to a relative one by using any of the built-in ",(0,a.kt)("a",{parentName:"p",href:"/docs/anima-declaration/#anima_relative_position"},"anima",(0,a.kt)("em",{parentName:"a"},"relative_position"),"*")," helpers,\nwhile for any other property we can use the ",(0,a.kt)("a",{parentName:"p",href:"/docs/anima-declaration/#anima_as_relative"},"animate_as_relative")," method."),(0,a.kt)("p",null,"The only thing to keep in mind is that "),(0,a.kt)("h2",{id:"example"},"Example"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-gdscript"},"Anima.begin_single_shot(true) \\\n  .then( Anima.Node(self).anima_scale_x(1.5).anima_as_relative() ) \\\n  .play()\n")),(0,a.kt)("p",null,"This will increase the ",(0,a.kt)("inlineCode",{parentName:"p"},"scale:x")," value of +1.5, from whatever the current value was at the time the animation was created."))}m.isMDXComponent=!0}}]);