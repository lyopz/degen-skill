"""Turn every templates/*.lua into a Roblox model file (.rbxmx) you can drop into Studio,
and build the Studio plugin DegenTemplates.rbxmx (all templates inside, insert with one click).
Name.lua -> ModuleScript (default). Name.server.lua -> Script. Name.client.lua -> LocalScript.
Usage: python make_rbxmx.py   (writes templates/rbxmx/*.rbxmx)"""
import os, glob, html
HERE = os.path.dirname(os.path.abspath(__file__)); SRC = os.path.join(HERE, 'templates'); OUT = os.path.join(SRC, 'rbxmx')
os.makedirs(OUT, exist_ok=True)
for f in sorted(glob.glob(os.path.join(SRC, '*.lua'))):
    base = os.path.basename(f)[:-4]
    cls = 'Script' if base.endswith('.server') else 'LocalScript' if base.endswith('.client') else 'ModuleScript'
    name = base.replace('.server', '').replace('.client', '')
    code = open(f, encoding='utf-8').read().replace(']]>', ']]]]><![CDATA[>')
    xml = f'''<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" version="4">
<Item class="{cls}" referent="RBX0"><Properties><string name="Name">{html.escape(name)}</string><ProtectedString name="Source"><![CDATA[{code}]]></ProtectedString></Properties></Item>
</roblox>'''
    open(os.path.join(OUT, name + '.rbxmx'), 'w', encoding='utf-8').write(xml)
    print('wrote', name + '.rbxmx', '(' + cls + ')')

# Studio plugin with every template inside
items = []
for i, f in enumerate(sorted(glob.glob(os.path.join(SRC, '*.lua')))):
    base = os.path.basename(f)[:-4]
    cls = 'Script' if base.endswith('.server') else 'LocalScript' if base.endswith('.client') else 'ModuleScript'
    name = base.replace('.server', '').replace('.client', '')
    code = open(f, encoding='utf-8').read().replace(']]>', ']]]]><![CDATA[>')
    items.append(f'<Item class="{cls}" referent="T{i}"><Properties><string name="Name">{html.escape(name)}</string>{'' if cls == 'ModuleScript' else '<bool name="Disabled">true</bool>'}<ProtectedString name="Source"><![CDATA[{code}]]></ProtectedString></Properties></Item>')
pcode = open(os.path.join(HERE, 'plugin.lua'), encoding='utf-8').read().replace(']]>', ']]]]><![CDATA[>')
plugin = (f'<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" version="4">\n<Item class="Script" referent="P0"><Properties><string name="Name">DegenTemplates</string><ProtectedString name="Source"><![CDATA[{pcode}]]></ProtectedString></Properties>'
          f'<Item class="Folder" referent="F0"><Properties><string name="Name">Templates</string></Properties>{"".join(items)}</Item></Item>\n</roblox>')
open(os.path.join(HERE, 'DegenTemplates.rbxmx'), 'w', encoding='utf-8').write(plugin)
print('wrote DegenTemplates.rbxmx (Studio plugin,', len(items), 'templates)')
