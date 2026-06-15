"""One-off helper: extract narration text from an AZ-104 doc HTML page.
Usage: python extract_narration.py <input.html> <output.txt>
"""
import re
import sys
import html

src, dst = sys.argv[1], sys.argv[2]

with open(src, "r", encoding="utf-8") as f:
    raw = f.read()

# Strip script/style blocks
raw = re.sub(r"(?is)<script.*?</script>", "", raw)
raw = re.sub(r"(?is)<style.*?</style>", "", raw)

# Strip nav and sidebar (not useful for narration)
raw = re.sub(r'(?is)<nav class="site-nav">.*?</nav>', "", raw)
raw = re.sub(r'(?is)<aside class="sidebar">.*?</aside>', "", raw)

# Strip the footer (boilerplate, not useful for narration)
raw = re.sub(r'(?is)<div class="footer">.*?</div>\s*</div>\s*</div>', "</div></div>", raw)

# Add pauses after structural elements
for tag in ["h1", "h2", "h3", "h4", "p", "li", "tr"]:
    raw = re.sub(rf"(?i)</{tag}>", ". \n", raw)
raw = re.sub(r"(?i)</div>", " \n", raw)

# Remove remaining tags
text = re.sub(r"<[^>]+>", " ", raw)

# Decode HTML entities
text = html.unescape(text)

# Clean up symbols not worth narrating
text = re.sub(r"[├└│─]", "", text)   # box-drawing chars
text = text.replace("→", " to ")
text = text.replace("⇄", " and ")
text = text.replace("↔", " and ")
text = text.replace("–", " - ").replace("—", " - ")
text = re.sub(r"[\U0001F300-\U0001FAFF←-⇿⌀-⏿☀-➿]", "", text)  # emoji/arrows/symbols

# Collapse whitespace
lines = [ln.strip() for ln in text.splitlines()]
lines = [ln for ln in lines if ln]
text = "\n".join(lines)
text = re.sub(r"[ \t]+", " ", text)

with open(dst, "w", encoding="utf-8") as f:
    f.write(text)

print(f"Extracted {len(text)} characters to {dst}")
