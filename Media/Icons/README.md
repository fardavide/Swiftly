# App icon

The icon is **Split** — `concepts/02-split.svg`. That SVG is the source of truth;
everything in the asset catalog is generated from it by `apply_icon.mjs`.

## What it replaced

The icon that shipped until now was a stock flat-illustration euro coin on a blue
gradient. Three problems, in order of how much they mattered:

1. **It said "euro app".** Swiftly converts around 170 currencies and the icon
   named one of them.
2. **It fell apart small.** The coin carried a rim, an inner disc, a shading
   crescent and a diagonal highlight stripe. At the 16pt and 32pt sizes macOS asks
   for — Dock, Finder sidebar, Cmd-Tab — those layers collapsed into an orange
   smudge.
3. **It was not ours.** A widely licensed clip-art asset, carrying no
   relationship to the product's name or to what the product does.

Split answers the first two. It still names two currencies rather than none, but
it is the strongest small-size performer of everything drawn: when the glyphs have
dissolved, two colour fields meeting on a curve are still a distinct shape, which
is more than most icons manage at 16pt.

## Other directions still on file

Kept because they are genuinely different answers, not variations:

| File | Idea |
| --- | --- |
| `03-duo` | Two coins, overlapping. Money, and visibly more than one kind of it. |
| `04-coin` | The old idea rebuilt — one coin, a real rim, no clip-art shine. |
| `05-ring` | A currency inside an exchange loop. The most explicit of the set. |

A larger family built on an S monogram — the letter alone, with arrow terminals,
struck by the euro's double bar, and the same shapes in Liquid Glass and light
finishes — was explored and dropped. It is in this branch's history if it is ever
worth revisiting.

## Regenerating the catalog

```sh
cd Media/Icons
npm install
node apply_icon.mjs 02-split
```

That rewrites, from the single SVG:

- `AppIcon.appiconset` — the full-bleed 1024 square for iOS (the system applies
  its own mask), and all ten macOS slots as the Big Sur tile: an 824pt rounded
  square centred in the 1024pt canvas with a drop shadow. The macOS slots used to
  hold bare full-bleed squares, which is why the app read as a pasted screenshot
  in the Dock next to everything else.
- `LaunchIcon.imageset` — the icon under the iOS mask at 1x/2x/3x.
- `LaunchColor.colorset` — the deep teal from the icon's own lower field, so the
  splash stops disagreeing with the icon it precedes.

## Editing

The SVGs have no font dependency — the currency glyphs are outlines, not text, so
they open and edit identically in Pixelmator, Figma, Sketch or Illustrator.
Everything sits on a 1024x1024 canvas in the coordinate space Apple's icon
templates use, so measurements transfer directly. Re-run `apply_icon.mjs` after
any change.

`previews/` holds 512px renders and a contact sheet showing each concept at 256,
128, 64, 32 and 16px under the iOS mask. Nothing reads them; they are for review.
