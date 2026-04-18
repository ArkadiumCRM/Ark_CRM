// Extract __bundler/template JSON-string from Claude Design standalone HTML
// Usage: node extract-bundler-template.js <input.html> <output.html>

const fs = require('fs');
const path = require('path');

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  console.error('Usage: node extract-bundler-template.js <input> <output>');
  process.exit(1);
}

const src = fs.readFileSync(input, 'utf8');
const re = /<script type="__bundler\/template">\s*([\s\S]*?)\s*<\/script>/;
const m = src.match(re);
if (!m) { console.error('No __bundler/template found'); process.exit(1); }

const jsonStr = m[1].trim();
const html = JSON.parse(jsonStr);
fs.writeFileSync(output, html, 'utf8');
console.log(`Extracted ${html.length} bytes → ${output}`);
