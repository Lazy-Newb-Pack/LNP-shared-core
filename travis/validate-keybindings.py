import re, os, sys
def write(*args):
    sys.stdout.write(*args)
    sys.stdout.flush()
with open('keybinds/Vanilla_DF.txt') as f:
    contents = f.read()
all_bindings = set(re.findall(r'\[BIND:([^:]+)', contents))
print('%i bindings found in Vanilla_DF.txt' % len(all_bindings))

filenames = list(filter(lambda f: f.endswith('.txt'), os.listdir('keybinds')))
errors = []
success = True
for filename in filenames:
    with open(os.path.join('keybinds', filename)) as f:
        contents = f.read()
        bindings = set(re.findall(r'\[BIND:([^:]+)', contents))
        missing = all_bindings - bindings
        extras = bindings - all_bindings
        if len(missing):
            success = False
            print('%s: Missing keybindings: %s' % (filename, ', '.join(missing)))
        if len(extras):
            success = False
            print('%s: Unexpected keybindings found: %s' % (filename, ', '.join(extras)))
        for b in bindings:
            index = contents.index('[BIND:' + b) + 1
            if contents.find('[BIND:', index) == contents.find('[', index) or contents.find('[', index) == -1:
                success = False
                print('%s: Binding %s is missing keys' % (filename, b))
sys.exit(0 if success else 1)
