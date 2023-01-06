const fs = require('fs');
const path = require('path');
const visit = require('unist-util-visit');
var VFile = require('vfile')

function inlineTransclusions(options = {}) {

  const proc = this;
  return function transformer(tree, file) {

    // Collect a map of all the imports seen.
    // Maps from "imported name" to "parsed AST of that markdown file"
    const imports = {};

    visit(tree, 'import', (node, index, parent) => {

      const matches = /import {?(\w+)}? from (('|").+('|"));/.exec(node.value);
      if (matches) {

        const destination = matches[2];

        if (/\.mdx/.exec(destination)) {
          const full = path.resolve(file.dirname, destination.replace("'", '').replace("'", ''));
          var root = proc.parse(
            new VFile({path: full, contents: fs.readFileSync(full).toString('utf8')})
          );
          const key = matches[1];
          
          // If we find an import for a markdown file, store it in the hash,.
          console.log('storing key: '+key);
          imports[key] = root;
        //   console.log(JSON.stringify(root));

          // remove the import, not strictly necessary
          parent.children.splice(index, 1);
          return [visit.SKIP, index];
        }

        return;
      }
    });

    visit(tree, 'jsx', (node, index, parent) => {

      const matches = /\<([^\s>]+) ?\/>/.exec(node.value);
      if (matches) {
        const key = matches[1];
        // console.log('found use of '+key);

        const node = imports[key];
        
        // When visiting JSX nodes, if we find one where thee corresponding import is in our hash,
        // Replace this JSX tag with the AST that we parsed from the target file.
        if (node) {
          parent.children = [...parent.children.splice(0, index), ...node.children, ...parent.children.splice(index+1)];

        //   console.log(JSON.stringify(parent, 2));
          return [visit.CONTINUE];
        }
      }
    });
  };
}

module.exports = inlineTransclusions;