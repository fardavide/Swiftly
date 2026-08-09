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
| `06-*` | Six lens shapes under one Liquid Glass field | See below. |
| `07-light` | `01`'s mark on a light tile | Same geometry as `01`, inverted ground. |

### The `06-*` glass set

The first glass attempt bent a constant-width stroke into an S-ish path and
attached two triangles to it. A drawn S has modulated weight — it swells through
the curves and narrows at the joints — and that modulation is what makes the eye
file a shape as a letter. Without it the mark read as a bent pipe wearing
triangles: not convincing as a letter, not convincing as a symbol.

These six replace it. The colour field is identical across all of them, so the
only variable is the shape of the lens. They are sorted by how much letter is
left in them, and none of them sits halfway.

| File | Shape | Reads as |
| --- | --- | --- |
| `06-letter` | Inter Display Black's S, untouched | A letter |
| `06-blade` | The same S, terminals carried on into arrow points | A letter that moves |
| `06-dollar` | The drawn `$` glyph | A letter that is money — and specifically USD |
| `06-arrows` | Two arrows, opposite directions | Convert. Survives smallest of the six |
| `06-loop` | A closed exchange cycle | Convert — and also refresh |
| `06-euro` | The `€` glyph | Money, in one currency |
| `06-equals` | The two merged — see below | Money, no currency named |

Whichever wins should also replace the mark in `01-swap` and `07-light`, which
carry the same rejected geometry.

### The merged mark (`*-equals`)

`$` is an S with a bar through it; `€` is a bowl with a double bar through it.
Give the S the euro's double bar and you get one glyph that carries both — and
the double bar is an equals sign, which is the thing a converter asserts. It also
names no single currency, which is the problem the redesign started on.

The rules have to be seen crossing the letter. Three placements were tried and
two of them fail, both for reasons the row profile of the glyph makes obvious.

- **Rules stopping inside the letter.** Running them in from the left and ending
  them within the stroke keeps every edge tidy, and it is exactly what the euro
  does — the euro's bowl is a C, so a bar crosses one narrow vertical stroke and
  then runs free across the opening. An S has no opening there. What shows is two
  tabs beside a letter, and two tabs assert nothing.
- **Rules crossing with a clearance cut out of the letter.** Keeps the rules
  unbroken, but the S's stroke runs almost horizontally through that band, so the
  clearance takes the middle of the letter with it. What survives reads as an O.
- **Rules crossing the waist, aligned at their ends.** This is the one. The S is
  a diagonal band up to 404 units wide at mid-height, so it buries each rule and
  releases it at a different x on each side — but once the rules start and stop
  together, that reads as the letter sitting in front of them rather than as a
  stagger.

Two details make it work. The letter is set one weight lighter than elsewhere in
the set: Inter's Black S has open bands only at y 335..395 and y 620..680, where
Bold's are 90 units tall instead of 60, so a rule has more aperture to show
through. And the rules run past the letter on both sides by the same amount,
because equal length is what the eye uses to pair them.

| File | Treatment |
| --- | --- |
| `06-equals` | Liquid Glass |
| `01-equals` | Flat, indigo ground |
| `07-equals-light` | Flat, light ground |

The glass version carries a wider bar gap than the flat ones. Its rim dilates
every edge by 13 units, so a gap tuned on the flat mark closes to a slot; both
are set to leave the same visible opening.

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
