# Diagram Conventions (draw.io / diagrams.net)

All diagrams live in a module's `diagrams/` folder as `.drawio` files
(plain XML, mxGraph format — viewable/editable for free at
[diagrams.net](https://app.diagrams.net), no account needed).

## Naming

`<topic>-<diagram-type>.drawio`, all lowercase, hyphen-separated. Examples:
- `entra-id-hierarchy.drawio`
- `rbac-scope-inheritance.drawio`
- `hub-spoke-topology.drawio`

`<diagram-type>` is one of: `hierarchy`, `topology`, `flow`, `comparison`,
`architecture`.

## Exporting images (optional)

If you want a static image for embedding/preview, export alongside the
source with the same base name:
- `entra-id-hierarchy.drawio` → `entra-id-hierarchy.png`

In diagrams.net: **File > Export as > PNG/SVG**, save next to the `.drawio`
file. Keep the `.drawio` source under version control — it's the editable
master; the exported image is a convenience copy.

## Style guidance

- Use the built-in **Azure** shape library (**More Shapes... > Networking /
  Azure**) for service icons so diagrams look consistent with Microsoft
  documentation.
- One diagram = one concept. Prefer several small, focused diagrams over one
  dense diagram.
- Every diagram should be referenced from at least one concept doc or the
  module README, with a one-line caption explaining what it shows.

## Opening a diagram

1. Go to [diagrams.net](https://app.diagrams.net) (or open the desktop app).
2. **Open Existing Diagram** > select the `.drawio` file from this repo.
3. Edit and re-save (Ctrl+S) back to the same path to keep it in the repo.
