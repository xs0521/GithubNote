(function(n){var a="(?:[ 	]+(?![ 	])(?:<SP_BS>)?|<SP_BS>)".replace(/<SP_BS>/g,function(){return`\\\\[\r
](?:\\s|\\\\[\r
]|#.*(?!.))*(?![\\s#]|\\\\[\r
])`}),t=`"(?:[^"\\\\\r
]|\\\\(?:\r
|[^]))*"|'(?:[^'\\\\\r
]|\\\\(?:\r
|[^]))*'`,S=`--[\\w-]+=(?:<STR>|(?!["'])(?:[^\\s\\\\]|\\\\.)+)`.replace(/<STR>/g,function(){return t}),o={pattern:RegExp(t),greedy:!0},i={pattern:/(^[ \t]*)#.*/m,lookbehind:!0,greedy:!0};function e(r,P){return r=r.replace(/<OPT>/g,function(){return S}).replace(/<SP>/g,function(){return a}),RegExp(r,P)}n.languages.docker={instruction:{pattern:/(^[ \t]*)(?:ADD|ARG|CMD|COPY|ENTRYPOINT|ENV|EXPOSE|FROM|HEALTHCHECK|LABEL|MAINTAINER|ONBUILD|RUN|SHELL|STOPSIGNAL|USER|VOLUME|WORKDIR)(?=\s)(?:\\.|[^\r\n\\])*(?:\\$(?:\s|#.*$)*(?![\s#])(?:\\.|[^\r\n\\])*)*/im,lookbehind:!0,greedy:!0,inside:{options:{pattern:e("(^(?:ONBUILD<SP>)?\\w+<SP>)<OPT>(?:<SP><OPT>)*","i"),lookbehind:!0,greedy:!0,inside:{property:{pattern:/(^|\s)--[\w-]+/,lookbehind:!0},string:[o,{pattern:/(=)(?!["'])(?:[^\s\\]|\\.)+/,lookbehind:!0}],operator:/\\$/m,punctuation:/=/}},keyword:[{pattern:e("(^(?:ONBUILD<SP>)?HEALTHCHECK<SP>(?:<OPT><SP>)*)(?:CMD|NONE)\\b","i"),lookbehind:!0,greedy:!0},{pattern:e("(^(?:ONBUILD<SP>)?FROM<SP>(?:<OPT><SP>)*(?!--)[^ 	\\\\]+<SP>)AS","i"),lookbehind:!0,greedy:!0},{pattern:e("(^ONBUILD<SP>)\\w+","i"),lookbehind:!0,greedy:!0},{pattern:/^\w+/,greedy:!0}],comment:i,string:o,variable:/\$(?:\w+|\{[^{}"'\\]*\})/,operator:/\\$/m}},comment:i},n.languages.dockerfile=n.languages.docker})(Prism);
