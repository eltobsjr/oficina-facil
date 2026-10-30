import { marked } from 'marked';
import fs from 'fs';
const [,, src, out, title] = process.argv;
let md = fs.readFileSync(src, 'utf8')
  .replace(/^---\n[\s\S]*?\n---\n/, '')
  .replace(/\[\[([^\]|]+)\|([^\]]+)\]\]/g, '$2')
  .replace(/\[\[([^\]]+)\]\]/g, '$1');
const body = marked.parse(md).replace(
  /<pre><code class="language-mermaid">([\s\S]*?)<\/code><\/pre>/g,
  (_, c) => `<pre class="mermaid">${c.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&').replace(/&quot;/g,'"').replace(/&#39;/g,"'")}</pre>`);
const html = `<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>${title}</title>
<style>
@page { size: A4; margin: 18mm 16mm; }
body { font-family: "DejaVu Sans", Arial, sans-serif; font-size: 10.5pt; line-height: 1.45; color: #1a1a1a; }
h1 { color: #1F4E79; border-bottom: 3px solid #1F4E79; padding-bottom: 6px; font-size: 22pt; }
h2 { color: #1F4E79; font-size: 15pt; margin-top: 26px; break-after: avoid; }
h3 { color: #1F4E79; font-size: 12.5pt; break-after: avoid; }
h4 { font-size: 11.5pt; margin-bottom: 4px; break-after: avoid; }
table { border-collapse: collapse; width: 100%; margin: 10px 0; font-size: 9.5pt; break-inside: avoid; }
th { background: #1F4E79; color: #fff; text-align: left; }
th, td { border: 1px solid #b8c4d0; padding: 4px 7px; vertical-align: top; }
tr:nth-child(even) td { background: #f3f6f9; }
blockquote { border-left: 4px solid #1F4E79; background: #eef3f8; margin: 12px 0; padding: 6px 14px; }
code { background: #eef1f4; padding: 1px 4px; border-radius: 3px; font-size: 9pt; }
pre.mermaid { text-align: center; break-inside: avoid; background: #fff; }
pre.mermaid svg { max-width: 100%; max-height: 230mm; width: auto; height: auto; }
pre:not(.mermaid) { background: #f3f6f9; padding: 8px; break-inside: avoid; white-space: pre-wrap; word-break: break-word; font-size: 8.5pt; }
hr { border: 0; border-top: 1px solid #c5d0db; margin: 20px 0; }
</style></head><body>${body}
<script src="mermaid.min.js"></script>
<script>mermaid.initialize({startOnLoad:true, theme:'base', themeVariables:{primaryColor:'#dbe7f3', primaryBorderColor:'#1F4E79', lineColor:'#1F4E79', primaryTextColor:'#1a1a1a'}, flowchart:{useMaxWidth:true}, securityLevel:'loose'});</script>
</body></html>`;
fs.writeFileSync(out, html);
