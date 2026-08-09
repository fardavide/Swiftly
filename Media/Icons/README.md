# App icon concepts

Seven alternatives to the current icon, as self-contained SVGs, plus a script that
installs whichever one wins into the asset catalog.

## Why replace the current one

The icon shipping today is a stock flat-illustration euro coin on a blue gradient.
Three problems, in order of how much they matter:

1. **It says "euro app".** Swiftly converts any of ~170 currencies. The icon names one.
2. **It falls apart small.** The coin carries a rim, an inner disc, a shading crescent
   and a diagonal highlight stripe. At the 16pt and 32pt sizes macOS asks for — Dock,
   Finder sidebar, Cmd-Tab — those layers collapse into an orange smudge.
3. **It is not ours.** It is a widely-licensed clip-art asset, so it carries no
   relationship to the product's name or to what the product does.

Every concept below is drawn as flat vector geometry with at most two tonal steps per
shape, which is what keeps them legible once they are 16 pixels wide.

## The concepts

| File | Idea | Notes |
| --- | --- | --- |
| `01-swap` | The letter S drawn as a two-way exchange arrow | Brand initial and the app's verb in one mark. Currency-agnostic. |
| `02-split` | One tile split on a curve, a currency per field | The most legible at small sizes; the most literal. |
| `03-duo` | Two coins, two currencies | Money, and visibly more than one kind of it. |
| `04-coin` | Today's idea, rebuilt | Same motif, real rim, no clip-art shine. The conservative pick. |
| `05-ring` | A currency inside an exchange loop | The most explicit "this app converts currencies". |
| `06-glass` | `01`'s mark under a Liquid Glass lens | Same geometry as `01`, different finish. |
| `07-light` | `01`'s mark on a light tile | Same geometry as `01`, inverted ground. |

`01`, `06` and `07` are three finishes of one mark, not three separate ideas.

## Applying one

```sh
cd Media/Icons
npm install
node apply_icon.mjs 01-swap
```

That rewrites, from the single SVG:

- `AppIcon.appiconset` — the full-bleed 1024 square for iOS (the system applies its
  own mask), and all ten macOS slots as the Big Sur tile: an 824pt rounded square
  centred in the 1024pt canvas with a drop shadow. The macOS slots currently hold
  bare full-bleed squares, which is why the app looks like a pasted screenshot in the
  Dock next to everything else.
- `LaunchIcon.imageset` — the icon under the iOS mask at 1x/2x/3x.
- `LaunchColor.colorset` — repointed at the chosen concept's own background, so the
  splash stops disagreeing with the icon it precedes.

## Editing

The SVGs are the source of truth and have no font dependency — the currency glyphs
are outlines, not text, so they open and edit identically in Pixelmator, Figma,
Sketch or Illustrator. Everything sits on a 1024x1024 canvas in the coordinate space
Apple's icon templates use, so measurements transfer directly.

`previews/` holds 512px renders and a contact sheet showing each concept at 256, 128,
64, 32 and 16px under the iOS mask. Regenerate a preview with any SVG rasteriser; the
sizes there are for review only and nothing reads them.
