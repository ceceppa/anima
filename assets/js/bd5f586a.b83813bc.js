"use strict";(self.webpackChunkdoc=self.webpackChunkdoc||[]).push([[254],{3905:function(e,t,a){a.d(t,{Zo:function(){return s},kt:function(){return g}});var n=a(7294);function l(e,t,a){return t in e?Object.defineProperty(e,t,{value:a,enumerable:!0,configurable:!0,writable:!0}):e[t]=a,e}function i(e,t){var a=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),a.push.apply(a,n)}return a}function r(e){for(var t=1;t<arguments.length;t++){var a=null!=arguments[t]?arguments[t]:{};t%2?i(Object(a),!0).forEach((function(t){l(e,t,a[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(a)):i(Object(a)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(a,t))}))}return e}function o(e,t){if(null==e)return{};var a,n,l=function(e,t){if(null==e)return{};var a,n,l={},i=Object.keys(e);for(n=0;n<i.length;n++)a=i[n],t.indexOf(a)>=0||(l[a]=e[a]);return l}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(n=0;n<i.length;n++)a=i[n],t.indexOf(a)>=0||Object.prototype.propertyIsEnumerable.call(e,a)&&(l[a]=e[a])}return l}var p=n.createContext({}),d=function(e){var t=n.useContext(p),a=t;return e&&(a="function"==typeof e?e(t):r(r({},t),e)),a},s=function(e){var t=d(e.components);return n.createElement(p.Provider,{value:t},e.children)},m="mdxType",u={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},k=n.forwardRef((function(e,t){var a=e.components,l=e.mdxType,i=e.originalType,p=e.parentName,s=o(e,["components","mdxType","originalType","parentName"]),m=d(a),k=l,g=m["".concat(p,".").concat(k)]||m[k]||u[k]||i;return a?n.createElement(g,r(r({ref:t},s),{},{components:a})):n.createElement(g,r({ref:t},s))}));function g(e,t){var a=arguments,l=t&&t.mdxType;if("string"==typeof e||l){var i=a.length,r=new Array(i);r[0]=k;var o={};for(var p in t)hasOwnProperty.call(t,p)&&(o[p]=t[p]);o.originalType=e,o[m]="string"==typeof e?e:l,r[1]=o;for(var d=2;d<i;d++)r[d]=a[d];return n.createElement.apply(null,r)}return n.createElement.apply(null,a)}k.displayName="MDXCreateElement"},8770:function(e,t,a){a.r(t),a.d(t,{assets:function(){return p},contentTitle:function(){return r},default:function(){return u},frontMatter:function(){return i},metadata:function(){return o},toc:function(){return d}});var n=a(3117),l=(a(7294),a(3905));const i={sidebar_position:1},r="AnimaNode",o={unversionedId:"anima-node/anima-node",id:"anima-node/anima-node",title:"AnimaNode",description:"Usage",source:"@site/docs/anima-node/anima-node.md",sourceDirName:"anima-node",slug:"/anima-node/",permalink:"/anima/docs/anima-node/",draft:!1,editUrl:"https://github.com/ceceppa/anima/docs/docs/anima-node/anima-node.md",tags:[],version:"current",lastUpdatedAt:1648541622,formattedLastUpdatedAt:"Mar 29, 2022",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"tutorialSidebar",previous:{title:"Built-in Easings",permalink:"/anima/docs/anima/easings"}},p={},d=[{value:"Usage",id:"usage",level:2},{value:"1. Manually added to the scene",id:"1-manually-added-to-the-scene",level:3},{value:"2. Gdscript way",id:"2-gdscript-way",level:3},{value:"Signals",id:"signals",level:2},{value:"animation_started",id:"animation_started",level:3},{value:"animation_completed",id:"animation_completed",level:3},{value:"loop_started",id:"loop_started",level:3},{value:"loop_completed",id:"loop_completed",level:3},{value:"Methods",id:"methods",level:2},{value:"Reference",id:"reference",level:2},{value:"then: sequential animations",id:"then-sequential-animations",level:3},{value:"Syntax",id:"syntax",level:4},{value:"Example",id:"example",level:4},{value:"Timeline",id:"timeline",level:5},{value:"with: parallel animations",id:"with-parallel-animations",level:3},{value:"Syntax",id:"syntax-1",level:4},{value:"Example",id:"example-1",level:4},{value:"clear",id:"clear",level:3},{value:"Syntax",id:"syntax-2",level:4},{value:"get_length",id:"get_length",level:3},{value:"Syntax",id:"syntax-3",level:4},{value:"set_visibility_strategy",id:"set_visibility_strategy",level:3},{value:"Syntax",id:"syntax-4",level:4},{value:"Visibility Strategies",id:"visibility-strategies",level:5},{value:"Example",id:"example-2",level:4},{value:"loop",id:"loop",level:3},{value:"Syntax",id:"syntax-5",level:4},{value:"loop_with_delay",id:"loop_with_delay",level:3},{value:"Syntax",id:"syntax-6",level:4},{value:"Example",id:"example-3",level:4},{value:"loop_backwards",id:"loop_backwards",level:3},{value:"Syntax",id:"syntax-7",level:4},{value:"loop_backwards_with_delay",id:"loop_backwards_with_delay",level:3},{value:"Syntax",id:"syntax-8",level:4},{value:"Example",id:"example-4",level:4},{value:"play",id:"play",level:3},{value:"Syntax",id:"syntax-9",level:4},{value:"play_with_delay",id:"play_with_delay",level:3},{value:"Syntax",id:"syntax-10",level:4},{value:"Example",id:"example-5",level:4},{value:"play_backwards",id:"play_backwards",level:3},{value:"Syntax",id:"syntax-11",level:4},{value:"play_backwards_with_delay",id:"play_backwards_with_delay",level:3},{value:"Syntax",id:"syntax-12",level:4},{value:"Example",id:"example-6",level:4},{value:"stop",id:"stop",level:3},{value:"Syntax",id:"syntax-13",level:4},{value:"set_loop_strategy",id:"set_loop_strategy",level:3},{value:"Syntax",id:"syntax-14",level:4},{value:"USE_EXISTING_RELATIVE_DATA",id:"use_existing_relative_data",level:4},{value:"RECALCULATE_RELATIVE_DATA",id:"recalculate_relative_data",level:4},{value:"wait",id:"wait",level:3},{value:"Syntax",id:"syntax-15",level:4},{value:"Example",id:"example-7",level:4},{value:"set_default_duration",id:"set_default_duration",level:3}],s={toc:d},m="wrapper";function u(e){let{components:t,...i}=e;return(0,l.kt)(m,(0,n.Z)({},s,i,{components:t,mdxType:"MDXLayout"}),(0,l.kt)("h1",{id:"animanode"},"AnimaNode"),(0,l.kt)("h2",{id:"usage"},"Usage"),(0,l.kt)("p",null,"This node is used to handle the setup of all the animations supported by the addon.\nThere are two ways you can use it:"),(0,l.kt)("ol",null,(0,l.kt)("li",{parentName:"ol"},"By manually adding the node to your scene"),(0,l.kt)("li",{parentName:"ol"},"Via gdscript")),(0,l.kt)("h3",{id:"1-manually-added-to-the-scene"},"1. Manually added to the scene"),(0,l.kt)("p",null,'Suppose we have added the node to our scene and its name is "AnimaNode" now we can access its functionality with, for example:'),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},'$AnimaNode.then( Anima.Node($node).anima_animation("tada", 0.7) ).play()\n')),(0,l.kt)("h3",{id:"2-gdscript-way"},"2. Gdscript way"),(0,l.kt)("p",null,"To add the node programmatically via gdscript you have to invoke the ",(0,l.kt)("a",{parentName:"p",href:"#begin"},"begin")," or ",(0,l.kt)("a",{parentName:"p",href:"#begin-single-shot"},"begin_single_shot")," function first:"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"Anima.begin(self) \\\n    .then( Anima.Node($node).anima_position_x(100, 0.3) ) \\\n    .play()\n\n# OR\n\nAnima.begin_single_shot(self) \\\n    .then( Anima.Node($node).anima_position_x(100, 0.3) ) \\\n    .play()\n")),(0,l.kt)("h2",{id:"signals"},"Signals"),(0,l.kt)("h3",{id:"animation_started"},"animation_started"),(0,l.kt)("p",null,"Emitted when the animation or loop starts"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"signal animation_started\n")),(0,l.kt)("h3",{id:"animation_completed"},"animation_completed"),(0,l.kt)("p",null,"Emitted when the animation or loop starts"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"signal animation_completed\n")),(0,l.kt)("h3",{id:"loop_started"},"loop_started"),(0,l.kt)("p",null,"Emitted when a loop starts"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"signal loop_started(loop_count: int)\n")),(0,l.kt)("h3",{id:"loop_completed"},"loop_completed"),(0,l.kt)("p",null,"Emitted when a loop completes"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"signal loop_completed(loop_count: int)\n")),(0,l.kt)("h2",{id:"methods"},"Methods"),(0,l.kt)("ul",null,(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#then-sequential-animations"},"then(AnimationDeclaration)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#with-parallel-animations"},"with(AnimationDeclaration)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#wait"},"wait(delay)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#play"},"play()")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#play-with-delay"},"play_with_delay(delay)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#play-with-delay"},"play_with_speed(speed)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#play-with-delay"},"play_backwards(delay)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#play-with-delay"},"play_backwards_with_delay(delay)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#play-with-delay"},"play_backwards_with_speed(speed)")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#stop"},"stop()")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#clear"},"clear()")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#set_visibility_strategy"},"set_visibility_strategy")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#set-loop-strategy"},"set_loop_strategy()")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#get-length"},"get_length()")),(0,l.kt)("li",{parentName:"ul"},(0,l.kt)("a",{parentName:"li",href:"#set-default-duration"},"set_default_duration"))),(0,l.kt)("h2",{id:"reference"},"Reference"),(0,l.kt)("h3",{id:"then-sequential-animations"},"then: sequential animations"),(0,l.kt)("p",null,"The ",(0,l.kt)("inlineCode",{parentName:"p"},"then")," method allows you to animate elements in a sequence."),(0,l.kt)("h4",{id:"syntax"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"then( data: AnimaAnimationDeclaration )\n")),(0,l.kt)("h4",{id:"example"},"Example"),(0,l.kt)("p",null,(0,l.kt)("img",{alt:"Example of sequential animation",src:a(1613).Z,width:"420",height:"245"})),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"Anima.begin_single_shot(self, 'sequential') \\\n    .then( Anima.Node($Logo).anima_position_x(100, 1) ) \\\n    .then( Anima.Node($Logo).anima_position_y(80, 1).anima_delay(-0.5) ) \\\n    .then( Anima.Node($Logo).anima_rotate(90, 1).anima_delay(0.5) ) \\\n    .play()\n")),(0,l.kt)("h5",{id:"timeline"},"Timeline"),(0,l.kt)("p",null,"When we play this animation, we can see the node moving in diagonal after about 0.5s, and for about 0.5s, as we used a negative delay to the 2nd animation:"),(0,l.kt)("p",null,(0,l.kt)("img",{alt:"Sequential",src:a(2075).Z,width:"581",height:"124"})),(0,l.kt)("h3",{id:"with-parallel-animations"},"with: parallel animations"),(0,l.kt)("p",null,"The ",(0,l.kt)("inlineCode",{parentName:"p"},"with")," method allows you to animate elements in parallel."),(0,l.kt)("h4",{id:"syntax-1"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"with( data: AnimationDeclaration )\n")),(0,l.kt)("h4",{id:"example-1"},"Example"),(0,l.kt)("p",null,(0,l.kt)("img",{alt:"Example of parallel animation",src:a(2524).Z,width:"420",height:"245"})),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"Anima.begin(self, 'parallel') \\\n    .then( Anima.Node($Logo).anima_position_x(100, 1) ) \\\n    .with( Anima.Node($Logo).anima_position_y(80, 1) ) \\\n    .with( Anima.Node($Logo).anima_rotate(90, 1) ) \\\n    .play()\n")),(0,l.kt)("h3",{id:"clear"},"clear"),(0,l.kt)("p",null,"Clears all the animations."),(0,l.kt)("h4",{id:"syntax-2"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.clear()\n")),(0,l.kt)("h3",{id:"get_length"},"get_length"),(0,l.kt)("p",null,"Returns the total animation duration."),(0,l.kt)("h4",{id:"syntax-3"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.get_length()\n")),(0,l.kt)("h3",{id:"set_visibility_strategy"},"set_visibility_strategy"),(0,l.kt)("p",null,"This method allows hiding all the nodes that will be animated when the animation hasn't started yet.\nLet's have a look at the following gif:"),(0,l.kt)("p",null,(0,l.kt)("a",{parentName:"p",href:"../images/hide_strategy.gif"},"Hide strategy")),(0,l.kt)("p",null,"we have three elements:"),(0,l.kt)("ol",null,(0,l.kt)("li",{parentName:"ol"},"Window"),(0,l.kt)("li",{parentName:"ol"},"Text"),(0,l.kt)("li",{parentName:"ol"},"Button")),(0,l.kt)("p",null,"We want all of them hidden for this kind of animation when it has not started yet.\nA simple solution can hide them in the editor; it works. But I always end up forgetting to re-hide stuff after doing some test.\nSo this method is helpful to avoid this kind of distraction, as we can specify, during the creation of the animation, that we want to hide :)"),(0,l.kt)("h4",{id:"syntax-4"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre"},"set_visibility_strategy(strategy: Anima.VISIBILITY, always_apply_on_play := true)\n")),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Param"),(0,l.kt)("th",{parentName:"tr",align:null},"Type"),(0,l.kt)("th",{parentName:"tr",align:null},"Description"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"strategy"),(0,l.kt)("td",{parentName:"tr",align:null},"int"),(0,l.kt)("td",{parentName:"tr",align:null},"The visibility strategy to apply")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"always_apply_on_play"),(0,l.kt)("td",{parentName:"tr",align:null},"bool"),(0,l.kt)("td",{parentName:"tr",align:null},"If true re-apply the visibility strategy every time ",(0,l.kt)("inlineCode",{parentName:"td"},".play()")," is called")))),(0,l.kt)("h5",{id:"visibility-strategies"},"Visibility Strategies"),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Strategy"),(0,l.kt)("th",{parentName:"tr",align:null},"Description"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"Anima.Visibility.IGNORE"),(0,l.kt)("td",{parentName:"tr",align:null},"Leaves everything as it is")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"Anima.Visibility.HIDDEN_ONLY"),(0,l.kt)("td",{parentName:"tr",align:null},"Hides the element using the ",(0,l.kt)("inlineCode",{parentName:"td"},".hide()")," method")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"Anima.Visibility.TRANSPARENT_ONLY"),(0,l.kt)("td",{parentName:"tr",align:null},"Sets the modulate alpha channel to 0")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"Anima.Visibility.HIDDEN_AND_TRANSPARENT"),(0,l.kt)("td",{parentName:"tr",align:null},"Hides and makes the elements transparent")))),(0,l.kt)("p",null,(0,l.kt)("inlineCode",{parentName:"p"},"TRANSPARENT")," and ",(0,l.kt)("inlineCode",{parentName:"p"},"HIDDEN")," have a different impact on the node:"),(0,l.kt)("ul",null,(0,l.kt)("li",{parentName:"ul"},"A ",(0,l.kt)("em",{parentName:"li"},"transparent")," node can still receive the focus and click events. So, a button will still show the hand cursor when hovered. But it will keep the space occupied"),(0,l.kt)("li",{parentName:"ul"},"A ",(0,l.kt)("em",{parentName:"li"},"HIDDEN")," node cannot be clicked and does not occupy any space. So this means that when made visible, it will claim its space, and you might experience other elements being pushed to a different position.")),(0,l.kt)("h4",{id:"example-2"},"Example"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},'func _ready():\n    Anima.begin(self, \'sequence_and_parallel\') \\\n        .set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \\\n        .then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \\\n        .then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \\\n        .then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \\\n        .play_with_delay(0.5)\n')),(0,l.kt)("h3",{id:"loop"},"loop"),(0,l.kt)("p",null,"Loops the animation # given ",(0,l.kt)("inlineCode",{parentName:"p"},"times"),"."),(0,l.kt)("p",null,(0,l.kt)("strong",{parentName:"p"},"NOTE"),": By default Anima will not re-calculate the relative data. See ",(0,l.kt)("a",{parentName:"p",href:"#set-loop-strategy"},"set_loop_strategy")," for more information."),(0,l.kt)("h4",{id:"syntax-5"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.loop(times: int = -1)\n")),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Param"),(0,l.kt)("th",{parentName:"tr",align:null},"Type"),(0,l.kt)("th",{parentName:"tr",align:null},"Description"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"times"),(0,l.kt)("td",{parentName:"tr",align:null},"int"),(0,l.kt)("td",{parentName:"tr",align:null},"Number of loops to execute. Use ",(0,l.kt)("inlineCode",{parentName:"td"},"-1")," to have an infinite loop.")))),(0,l.kt)("h3",{id:"loop_with_delay"},"loop","_","with","_","delay"),(0,l.kt)("p",null,"Loops the animation # given ",(0,l.kt)("inlineCode",{parentName:"p"},"times")," with an interval of # ",(0,l.kt)("inlineCode",{parentName:"p"},"seconds")," between each loop"),(0,l.kt)("h4",{id:"syntax-6"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.play_with_delay(delay: float, times: int)\n")),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Param"),(0,l.kt)("th",{parentName:"tr",align:null},"Type"),(0,l.kt)("th",{parentName:"tr",align:null},"Description"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"delay"),(0,l.kt)("td",{parentName:"tr",align:null},"float"),(0,l.kt)("td",{parentName:"tr",align:null},"Delay before starting a new loop. ",(0,l.kt)("strong",{parentName:"td"},"NOTE")," it is not applied for the first loop")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"times"),(0,l.kt)("td",{parentName:"tr",align:null},"int"),(0,l.kt)("td",{parentName:"tr",align:null},"Number of loops to execute. Use ",(0,l.kt)("inlineCode",{parentName:"td"},"-1")," to have an infinite loop.")))),(0,l.kt)("h4",{id:"example-3"},"Example"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},'Anima.begin(self, \'sequence_and_parallel\') \\\n    .then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \\\n    .then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \\\n    .then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \\\n    .set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \\\n    .loop_with_delay(0.5, 5)\n')),(0,l.kt)("p",null,"Loops the animation ",(0,l.kt)("em",{parentName:"p"},"5")," times and applies a delay of 0.5 seconds from the 2nd loop."),(0,l.kt)("h3",{id:"loop_backwards"},"loop_backwards"),(0,l.kt)("p",null,"Loops the animation backwards X given ",(0,l.kt)("inlineCode",{parentName:"p"},"times"),"."),(0,l.kt)("p",null,(0,l.kt)("strong",{parentName:"p"},"NOTE"),": By default Anima will not re-calculate the relative data. See ",(0,l.kt)("a",{parentName:"p",href:"#set-loop-strategy"},"set_loop_strategy")," for more information."),(0,l.kt)("h4",{id:"syntax-7"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.loop_backwards(times: int = -1)\n")),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Param"),(0,l.kt)("th",{parentName:"tr",align:null},"Type"),(0,l.kt)("th",{parentName:"tr",align:null},"Description"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"times"),(0,l.kt)("td",{parentName:"tr",align:null},"int"),(0,l.kt)("td",{parentName:"tr",align:null},"Number of loops to execute. Use ",(0,l.kt)("inlineCode",{parentName:"td"},"-1")," to have an infinite loop.")))),(0,l.kt)("h3",{id:"loop_backwards_with_delay"},"loop","_","backwards","_","with","_","delay"),(0,l.kt)("p",null,"Loops the animation backwards X given ",(0,l.kt)("inlineCode",{parentName:"p"},"times")," with an interval of Y ",(0,l.kt)("inlineCode",{parentName:"p"},"seconds")," between each loop"),(0,l.kt)("h4",{id:"syntax-8"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.play_backwards_with_delay(delay: float, times: int)\n")),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Param"),(0,l.kt)("th",{parentName:"tr",align:null},"Type"),(0,l.kt)("th",{parentName:"tr",align:null},"Description"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"delay"),(0,l.kt)("td",{parentName:"tr",align:null},"float"),(0,l.kt)("td",{parentName:"tr",align:null},"Delay before starting a new loop. ",(0,l.kt)("strong",{parentName:"td"},"NOTE")," it is not applied for the first loop")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"times"),(0,l.kt)("td",{parentName:"tr",align:null},"int"),(0,l.kt)("td",{parentName:"tr",align:null},"Number of loops to execute. Use ",(0,l.kt)("inlineCode",{parentName:"td"},"-1")," to have an infinite loop.")))),(0,l.kt)("h4",{id:"example-4"},"Example"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},'Anima.begin(self, \'sequence_and_parallel\') \\\n    .then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \\\n    .then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \\\n    .then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \\\n    .set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \\\n    .loop_backwards_with_delay(0.5, 5)\n')),(0,l.kt)("p",null,"Loops the animation ",(0,l.kt)("em",{parentName:"p"},"5")," times and applies a delay of 0.5 seconds from the 2nd loop."),(0,l.kt)("h3",{id:"play"},"play"),(0,l.kt)("p",null,"Plays the entire animation"),(0,l.kt)("h4",{id:"syntax-9"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.play()\n")),(0,l.kt)("h3",{id:"play_with_delay"},"play","_","with","_","delay"),(0,l.kt)("p",null,"Plays the entire animation after the specified delay has occurred."),(0,l.kt)("h4",{id:"syntax-10"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.play_with_delay()\n")),(0,l.kt)("h4",{id:"example-5"},"Example"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},'Anima.begin(self, \'sequence_and_parallel\') \\\n    .then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \\\n    .then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \\\n    .then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \\\n    .set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \\\n    .play_with_delay(0.5)\n')),(0,l.kt)("p",null,"Plays the animation after 0.5 seconds."),(0,l.kt)("h3",{id:"play_backwards"},"play","_","backwards"),(0,l.kt)("p",null,"Plays the entire animation backwards."),(0,l.kt)("h4",{id:"syntax-11"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.play_backwards()\n")),(0,l.kt)("h3",{id:"play_backwards_with_delay"},"play","_","backwards","_","with","_","delay"),(0,l.kt)("p",null,"Plays the entire animation backwards after the specified delay has occurred."),(0,l.kt)("h4",{id:"syntax-12"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.play_backwards_with_delay()\n")),(0,l.kt)("h4",{id:"example-6"},"Example"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},'Anima.begin(self, \'sequence_and_parallel\') \\\n    .then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \\\n    .then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \\\n    .then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \\\n    .set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \\\n    .play_backwards_with_delay(0.5)\n')),(0,l.kt)("p",null,"Plays the animation backwards after 0.5 seconds."),(0,l.kt)("h3",{id:"stop"},"stop"),(0,l.kt)("p",null,"Stops the entire animation"),(0,l.kt)("h4",{id:"syntax-13"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"anima.stop()\n")),(0,l.kt)("h3",{id:"set_loop_strategy"},"set","_","loop","_","strategy"),(0,l.kt)("p",null,"Set what to do when a new loop starts"),(0,l.kt)("h4",{id:"syntax-14"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"set_loop_strategy(strategy: int)\n")),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Strategy"),(0,l.kt)("th",{parentName:"tr",align:null},"Description"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"Anima.LOOP.USE_EXISTING_RELATIVE_DATA"),(0,l.kt)("td",{parentName:"tr",align:null},"(Default) Repeats the animation as it is, all the relative data calculated stays the same")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"Anima.LOOP.RECALCULATE_RELATIVE_DATA"),(0,l.kt)("td",{parentName:"tr",align:null},"Re-calculate the relative data before starting the animation again")))),(0,l.kt)("p",null,"To understand the difference between those two properties, let's consider the following code:"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},'var anima = Anima.begin(self)\nanima.then({ node = $Node, to = 10, relative = true, property = "position:x" })\n')),(0,l.kt)("p",null,"We asked Anima to animate the X position of 10 pixels from its relative position. For example, suppose its starting position is ",(0,l.kt)("inlineCode",{parentName:"p"},"Vector2(30, 7)"),", then at the end of the 1st loop, the node X position will be ",(0,l.kt)("inlineCode",{parentName:"p"},"Vector2(30, 17)"),"."),(0,l.kt)("h4",{id:"use_existing_relative_data"},"USE_EXISTING_RELATIVE_DATA"),(0,l.kt)("p",null,"The relative data is only calculated once. This means that if we animate a node relative to its current property when the new loop starts, we will use the same initial and final value."),(0,l.kt)("p",null,"So, looking at the example above, Anima resets the Node position to its initial value ",(0,l.kt)("inlineCode",{parentName:"p"},"Vector2(30, 7)"),". And at the end of the loop, the final position will be once again ",(0,l.kt)("inlineCode",{parentName:"p"},"Vector2(30, 17)"),"."),(0,l.kt)("h4",{id:"recalculate_relative_data"},"RECALCULATE_RELATIVE_DATA"),(0,l.kt)("p",null,"This strategy recalculates the relative data before starting the new loop."),(0,l.kt)("p",null,"So, looking at the example above, we'll have:"),(0,l.kt)("table",null,(0,l.kt)("thead",{parentName:"table"},(0,l.kt)("tr",{parentName:"thead"},(0,l.kt)("th",{parentName:"tr",align:null},"Loop"),(0,l.kt)("th",{parentName:"tr",align:null},"Initial position"),(0,l.kt)("th",{parentName:"tr",align:null},"Final position"))),(0,l.kt)("tbody",{parentName:"table"},(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"1"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, 7)"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, 17)")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"2"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, 17)"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, 27)")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"3"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, 27)"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, 37)")),(0,l.kt)("tr",{parentName:"tbody"},(0,l.kt)("td",{parentName:"tr",align:null},"...n"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, n - 1)"),(0,l.kt)("td",{parentName:"tr",align:null},"Vector2(30, (n - 1) + 10)")))),(0,l.kt)("p",null,"As you can see, using this strategy keeps incrementing the fina value indefinitely."),(0,l.kt)("h3",{id:"wait"},"wait"),(0,l.kt)("p",null,"Adds a delay for the next animation."),(0,l.kt)("h4",{id:"syntax-15"},"Syntax"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},"wait(delay: float)\n")),(0,l.kt)("h4",{id:"example-7"},"Example"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-gdscript"},".wait(0.3) # delays the next animation of 0.3 seconds\n")),(0,l.kt)("h3",{id:"set_default_duration"},"set_default_duration"),(0,l.kt)("p",null,"Sets the default animation duration."),(0,l.kt)("p",null,(0,l.kt)("strong",{parentName:"p"},"NOTE"),": This value is used only if we don't set the animation duration value."))}u.isMDXComponent=!0},2524:function(e,t,a){t.Z=a.p+"assets/images/parallel-afbe8fea99329a40ac479ce6b001eb79.gif"},1613:function(e,t,a){t.Z=a.p+"assets/images/then-b18b456b04f304ecc66352818610de6c.gif"},2075:function(e,t){t.Z="data:image/png;base64,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Hcc71PFxRUREpB5IEhR9ig3P/x5wjLf+UOBCbF6jd926KdjQ/suBft6xRmOj13xzgReAi1zelV76w7C+Rkn90JXFb467DZs+YASwCasxagncnUf+IiIi0sAkndH6ImAqNrFiNda/aCoW2JzlpduIDb2vwmqNlgFfAOcTP9rrbOA1rOZmAxaAbcJqc3ZPWEawSSj7Awe659/BAq4rCEfDLQXGACdjfYxERESkjFVizWHLYrZNwjo6+xMyrgNOwIa77w80wWa0fo1tZ6qejo0cOx4bnr8QeBabzHFqJO0qV46BLt9m2OSQ09m2T1JgAvA68GXMtrHYKLdg7qQl2Eiz6HEfxGba3pTmGCIiIlImCr1TvZTSOJrS9P/nkRKRUthEinGxI21FREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREREpMGqKMExDwT2Bu4qwbFFtjvX92NkqoLflLocImVu6dg59Ct1IaS0KktwzDOBURQeFI3AAqwxwFeFFkqkVLY2oqoiRetSl0OkzK0rdQGk9BqVugB5qALuBB4ERgJNS1scERERaQjqW1DUHXgdOAl4uMRlERERkQakEqttmQysAk4D9gSWA88DH6TZ50RgP2ALMBt4BqiJSdsVGAZ0AhYDjwFb05SlCjgF62/0JfAc8G4kzXFYIDcYODvD6zrAHfdGYD3WZDcXeCMm7elYbdMjGfITERGRBq4Sa4r6PXAq0BJYBvQAbgIuAO710u+MBSv9sCBnK3A18B4WKC3z0h4BPI0FO/OAzsBVwIyYcnTDgrBdseClE3A98Av3F/gDcB/Wh6hxhtd1JXA8sMS9tkuATcA+kXSdgEeB8SgoEhERKWtB89lPgBuADsC+WFD0CfDLSPoJwG7AIGB3oCfQH9gFeMhL1xwLMj7Hap4GAF2Aa7HgK2oC0AoLtr6JNZPdDlyD1fr4gk7VmUbOPQr8DasBS2Gduvu5cvuGYYHhAxnyEhERkTIQBEUfAnd461dggUUXoI1b1wc4DLgbeMdLOxe4FTgEC34AjgF2wmqbFnlp7wYWRsrQHxiKNXUF21JYQARwVsLXBBagHYLVUIHVBG0Ezo2kOxtYAEzL4xgiIiLSgARD8mdjgYhvpVu2xWp89nPPX4vJ51W3HOzy6psmbQp4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"}}]);