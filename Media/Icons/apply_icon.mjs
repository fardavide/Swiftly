#!/usr/bin/env node
// Install one of the concepts in Media/Icons/concepts into the asset catalog.
//
//   cd Media/Icons && npm install && node apply_icon.mjs 01-swap
//
// Rasterises the chosen SVG into every slot AppIcon.appiconset declares, refreshes
// the launch imageset, and repoints LaunchColor at the concept's own background so
// the splash and the icon stop disagreeing.
//
// iOS gets the full-bleed square (the system applies its own mask). macOS gets the
// Big Sur tile geometry: an 824pt rounded square centred in the 1024pt canvas with
// a drop shadow, which is what stops a Mac icon looking like a pasted screenshot.

import { Resvg } from '@resvg/resvg-js'
import { readFileSync, writeFileSync, readdirSync, unlinkSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const HERE = dirname(fileURLToPath(import.meta.url))
const REPO = resolve(HERE, '../..')
const CONCEPTS = join(HERE, 'concepts')
const APPICON = join(REPO, 'Swiftly/Assets.xcassets/AppIcon.appiconset')
const LAUNCHICON = join(REPO, 'Swiftly/Assets.xcassets/LaunchIcon.imageset')
const LAUNCHCOLOR = join(REPO, 'Swiftly/Assets.xcassets/LaunchColor.colorset')

// The colour the launch screen sits on, per concept. Picked from each icon's own
// background so the splash reads as an extension of the icon rather than a clash.
const LAUNCH_COLOURS = {
  '01-swap': '#2A32A8',
  '01-equals': '#2A32A8',
  '07-equals-light': '#F4F6FA',
  '06-equals': '#2A2596',
  '02-split': '#0E4A50',
  '03-duo': '#26309A',
  '04-coin': '#26309A',
  '05-ring': '#16191F',
  // The 06-* set are all the same glass field with a different lens shape.
  '06-letter': '#2A2596',
  '06-blade': '#2A2596',
  '06-dollar': '#2A2596',
  '06-arrows': '#2A2596',
  '06-loop': '#2A2596',
  '06-euro': '#2A2596',
  '07-light': '#F4F6FA',
}

const name = process.argv[2]
if (!name) {
  const available = readdirSync(CONCEPTS).filter((f) => f.endsWith('.svg'))
  console.error(`usage: node apply_icon.mjs <concept>\n\n  ${available.map((f) => f.replace('.svg', '')).join('\n  ')}`)
  process.exit(1)
}

const svg = readFileSync(join(CONCEPTS, `${name}.svg`), 'utf8')

// ---------------------------------------------------------------- geometry ---

/** Apple's continuous-corner square, sampled as a polygon. */
function squircle(size, x = 0, y = 0, n = 5, steps = 360) {
  const a = size / 2
  const cx = x + size / 2
  const cy = y + size / 2
  const pts = []
  for (let i = 0; i < steps; i++) {
    const t = (2 * Math.PI * i) / steps
    const ct = Math.cos(t)
    const st = Math.sin(t)
    pts.push(
      `${(cx + a * Math.sign(ct) * Math.abs(ct) ** (2 / n)).toFixed(2)},` +
        `${(cy + a * Math.sign(st) * Math.abs(st) ** (2 / n)).toFixed(2)}`,
    )
  }
  return `M${pts.join('L')}Z`
}

/** Strip the outer <svg> element so the artwork can be re-wrapped. */
function inner(source) {
  return source.replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '')
}

/** The 824-in-1024 rounded tile macOS expects, shadow included. */
function macTile(source) {
  const TILE = 824
  const OFFSET = (1024 - TILE) / 2
  const scale = TILE / 1024
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
<defs>
  <clipPath id="tileClip"><path d="${squircle(TILE, OFFSET, OFFSET)}"/></clipPath>
  <filter id="tileShadow" x="-20%" y="-20%" width="140%" height="140%">
    <feDropShadow dx="0" dy="14" stdDeviation="16" flood-color="#000000" flood-opacity="0.28"/>
  </filter>
</defs>
<g filter="url(#tileShadow)"><g clip-path="url(#tileClip)">
  <g transform="translate(${OFFSET},${OFFSET}) scale(${scale})">${inner(source)}</g>
</g></g>
</svg>`
}

/** The icon under the iOS mask, for the launch screen. */
function masked(source) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
<defs><clipPath id="iosClip"><path d="${squircle(1024)}"/></clipPath></defs>
<g clip-path="url(#iosClip)">${inner(source)}</g>
</svg>`
}

function png(source, size) {
  return new Resvg(source, {
    fitTo: { mode: 'width', value: size },
    font: { loadSystemFonts: false },
    background: 'rgba(0,0,0,0)',
  })
    .render()
    .asPng()
}

// ------------------------------------------------------------------- write ---

// macOS slots, keyed by the point size and scale the catalog declares.
const MAC_SLOTS = [
  [16, 1],
  [16, 2],
  [32, 1],
  [32, 2],
  [128, 1],
  [128, 2],
  [256, 1],
  [256, 2],
  [512, 1],
  [512, 2],
]

for (const f of readdirSync(APPICON)) {
  if (f.endsWith('.png')) unlinkSync(join(APPICON, f))
}

writeFileSync(join(APPICON, 'AppIcon-iOS-1024.png'), png(svg, 1024))

const tile = macTile(svg)
const images = [
  { filename: 'AppIcon-iOS-1024.png', idiom: 'universal', platform: 'ios', size: '1024x1024' },
]
for (const [pointSize, scale] of MAC_SLOTS) {
  const px = pointSize * scale
  const filename = `AppIcon-macOS-${pointSize}x${pointSize}@${scale}x.png`
  writeFileSync(join(APPICON, filename), png(tile, px))
  images.push({
    filename,
    idiom: 'mac',
    scale: `${scale}x`,
    size: `${pointSize}x${pointSize}`,
  })
}

writeFileSync(
  join(APPICON, 'Contents.json'),
  JSON.stringify({ images, info: { author: 'xcode', version: 1 } }, null, 2) + '\n',
)

// Launch screen: the masked icon, at the sizes the imageset already used.
for (const f of readdirSync(LAUNCHICON)) {
  if (f.endsWith('.png')) unlinkSync(join(LAUNCHICON, f))
}
const maskedSvg = masked(svg)
const launchImages = [1, 2, 3].map((scale) => {
  const filename = `LaunchIcon@${scale}x.png`
  writeFileSync(join(LAUNCHICON, filename), png(maskedSvg, 512 * scale))
  return { filename, idiom: 'universal', scale: `${scale}x` }
})
writeFileSync(
  join(LAUNCHICON, 'Contents.json'),
  JSON.stringify({ images: launchImages, info: { author: 'xcode', version: 1 } }, null, 2) + '\n',
)

const hex = LAUNCH_COLOURS[name]
if (hex) {
  writeFileSync(
    join(LAUNCHCOLOR, 'Contents.json'),
    JSON.stringify(
      {
        colors: [
          {
            color: {
              'color-space': 'srgb',
              components: {
                alpha: '1.000',
                blue: `0x${hex.slice(5, 7).toUpperCase()}`,
                green: `0x${hex.slice(3, 5).toUpperCase()}`,
                red: `0x${hex.slice(1, 3).toUpperCase()}`,
              },
            },
            idiom: 'universal',
          },
        ],
        info: { author: 'xcode', version: 1 },
      },
      null,
      2,
    ) + '\n',
  )
}

console.log(`applied ${name}: 1 iOS slot, ${MAC_SLOTS.length} macOS slots, launch icon, launch colour ${hex ?? '(unchanged)'}`)
