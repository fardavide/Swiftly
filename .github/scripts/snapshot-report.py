#!/usr/bin/env python3
"""Turn swift-snapshot-testing failure artifacts into a human-checkable HTML report.

On a snapshot mismatch the test writes the freshly-rendered image to
``<failures>/<Suite>/<name>.png`` (see SwiftlyTests/SnapshotSupport.swift, which pins
``SNAPSHOT_ARTIFACTS``). The committed baseline lives at the same relative path under
``<snapshots>`` (``__Snapshots__/<Suite>/<name>.png``). This pairs them and emits a small,
self-contained report folder: expected vs actual side by side, plus an in-browser *difference*
blend, so a reviewer can see exactly which screens drifted — no 60 MB .xcresult to spelunk.

Usage:
    snapshot-report.py <failures-dir> <snapshots-dir> <out-dir>

Exits 0 even when there's nothing to report (the failure may have been a build/runtime error, not a
snapshot mismatch) so the CI upload step always has a folder to publish.
"""

from __future__ import annotations

import html
import shutil
import sys
from pathlib import Path
from urllib.parse import quote

# Vocabulary of the trailing tokens `assertScreenSnapshot` appends to every `named:` slug. Only used
# to turn those tokens into chips: anything unrecognised is left as part of the state text, so a
# change to the snapshot matrix degrades the report's readability and never drops an image.
DEVICES = {"iPhone", "iPad"}
ORIENTATIONS = {"portrait", "landscape"}
SCHEMES = {"light", "dark"}


def prettify_suite(name: str) -> str:
    """`ConverterSnapshotTests` -> `Converter`."""
    trimmed = name.removesuffix("SnapshotTests").removesuffix("Tests")
    spaced = "".join(f" {c}" if c.isupper() else c for c in trimmed).strip()
    return spaced or name


def parse_variant(stem: str) -> tuple[str, str | None, str | None, str | None]:
    """Split a snapshot file stem into (state, device, orientation, scheme).

    Stem shape is ``<test-func>.<state>-<device>-<orientation>-<scheme>`` — the config/scheme suffix
    that `assertScreenSnapshot` appends. Each trailing token is claimed only if it is a known one and
    something is left to name the state with, so a stem that carries fewer of them (or none at all)
    still reports its full variant as the state rather than being mangled.
    """
    variant = stem.split(".", 1)[1] if "." in stem else stem
    tokens = variant.split("-")
    scheme = tokens.pop() if len(tokens) > 1 and tokens[-1] in SCHEMES else None
    orientation = tokens.pop() if len(tokens) > 1 and tokens[-1] in ORIENTATIONS else None
    device = tokens.pop() if len(tokens) > 1 and tokens[-1] in DEVICES else None
    return "-".join(tokens) or variant, device, orientation, scheme


def chip(label: str) -> str:
    return f'<span class="chip">{html.escape(label)}</span>'


def pane(title: str, src: str, klass: str = "") -> str:
    href = quote(src)
    return (
        f'<figure class="pane {klass}">'
        f"<figcaption>{html.escape(title)}</figcaption>"
        f'<a href="{href}" target="_blank" rel="noopener">'
        f'<img loading="lazy" src="{href}" alt="{html.escape(title)}"></a>'
        f"</figure>"
    )


def diff_pane(expected_src: str, actual_src: str) -> str:
    exp, act = quote(expected_src), quote(actual_src)
    return (
        '<figure class="pane">'
        "<figcaption>Difference</figcaption>"
        '<div class="diff">'
        f'<img loading="lazy" src="{exp}" alt="expected">'
        f'<img loading="lazy" class="top" src="{act}" alt="actual">'
        "</div></figure>"
    )


def build_card(entry: dict) -> str:
    state, device, orientation, scheme = parse_variant(entry["stem"])
    chips = "".join(chip(c) for c in (device, orientation, scheme) if c)
    header = (
        '<div class="card-head">'
        f'<h3>{html.escape(state)}</h3>'
        f'<div class="chips">{chips}</div>'
        f'<code>{html.escape(entry["rel"])}</code>'
        "</div>"
    )
    if entry["expected"] is None:
        body = (
            '<div class="new-badge">No committed baseline — this is a brand-new snapshot. '
            "Record it locally and commit if it looks right.</div>"
            '<div class="panes">' + pane("Rendered", entry["actual"]) + "</div>"
        )
    else:
        body = (
            '<div class="panes">'
            + pane("Expected (baseline)", entry["expected"])
            + pane("Actual (this run)", entry["actual"])
            + diff_pane(entry["expected"], entry["actual"])
            + "</div>"
        )
    return f'<section class="card">{header}{body}</section>'


PAGE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Snapshot diff report</title>
<style>
  :root {{ color-scheme: dark; }}
  * {{ box-sizing: border-box; }}
  body {{
    margin: 0; padding: 24px;
    font: 15px/1.5 -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
    background: #16181d; color: #e7e9ee;
  }}
  header {{ max-width: 1100px; margin: 0 auto 24px; }}
  h1 {{ font-size: 22px; margin: 0 0 6px; }}
  .lede {{ color: #9aa0ab; margin: 0 0 14px; max-width: 70ch; }}
  .toolbar {{ display: flex; gap: 16px; align-items: center; flex-wrap: wrap;
    padding: 10px 14px; background: #1e2128; border: 1px solid #2c3038; border-radius: 10px; }}
  .toolbar label {{ display: flex; gap: 8px; align-items: center; cursor: pointer; user-select: none; }}
  .count {{ font-weight: 600; }}
  main {{ max-width: 1100px; margin: 0 auto; }}
  .suite {{ margin: 28px 0 8px; font-size: 13px; letter-spacing: .08em; text-transform: uppercase; color: #7f8794; }}
  .card {{ background: #1e2128; border: 1px solid #2c3038; border-radius: 12px; padding: 16px; margin: 12px 0; }}
  .card-head {{ display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap; margin-bottom: 12px; }}
  .card-head h3 {{ margin: 0; font-size: 16px; }}
  .chips {{ display: flex; gap: 6px; }}
  .chip {{ font-size: 12px; padding: 2px 8px; border-radius: 999px; background: #2c3140; color: #c7cdd8; }}
  .card-head code {{ margin-left: auto; font-size: 11px; color: #737a86; }}
  .panes {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 12px; }}
  .pane figcaption {{ font-size: 12px; color: #9aa0ab; margin-bottom: 6px; }}
  .pane img {{ width: 100%; height: auto; display: block; border-radius: 8px; border: 1px solid #2c3038; background: #0d0f13; }}
  .diff {{ position: relative; line-height: 0; border-radius: 8px; overflow: hidden; background: #000; }}
  .diff img {{ width: 100%; height: auto; display: block; }}
  .diff .top {{ position: absolute; inset: 0; mix-blend-mode: difference; }}
  body.amplify .diff {{ filter: brightness(3) contrast(1.4); }}
  .new-badge {{ background: #3a2f14; border: 1px solid #6b571f; color: #f0d9a0;
    padding: 8px 12px; border-radius: 8px; margin-bottom: 12px; font-size: 13px; }}
  .empty {{ text-align: center; color: #9aa0ab; padding: 60px 20px; }}
  a {{ color: inherit; }}
</style>
</head>
<body class="amplify">
<header>
  <h1>Snapshot diff report</h1>
  <p class="lede">Each card is one screen whose render no longer matches its committed baseline.
  <strong>Expected</strong> is the checked-in reference, <strong>Actual</strong> is what this run
  produced, and <strong>Difference</strong> blends the two so only the changed pixels light up.
  If a diff is just rendering or font-rasterization drift, re-record the baselines locally and commit;
  if it's a real UI regression, fix the view. Baselines are never recorded on CI.</p>
  <div class="toolbar">
    <span class="count">{count}</span>
    <label><input type="checkbox" id="amp" checked> Amplify differences</label>
  </div>
</header>
<main>
{body}
</main>
<script>
  document.getElementById('amp').addEventListener('change', function (e) {{
    document.body.classList.toggle('amplify', e.target.checked);
  }});
</script>
</body>
</html>
"""


def main() -> int:
    if len(sys.argv) != 4:
        print(__doc__)
        return 2
    failures_dir = Path(sys.argv[1])
    snapshots_dir = Path(sys.argv[2])
    out_dir = Path(sys.argv[3])
    out_dir.mkdir(parents=True, exist_ok=True)

    failures = sorted(failures_dir.rglob("*.png")) if failures_dir.is_dir() else []

    entries: list[dict] = []
    for actual_path in failures:
        rel = actual_path.relative_to(failures_dir)
        reference_path = snapshots_dir / rel
        actual_out = Path("actual") / rel
        (out_dir / actual_out).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(actual_path, out_dir / actual_out)

        expected_out: str | None = None
        if reference_path.is_file():
            expected_rel = Path("expected") / rel
            (out_dir / expected_rel).parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(reference_path, out_dir / expected_rel)
            expected_out = expected_rel.as_posix()

        entries.append(
            {
                "suite": rel.parts[0] if len(rel.parts) > 1 else "Snapshots",
                "rel": rel.as_posix(),
                "stem": actual_path.stem,
                "actual": actual_out.as_posix(),
                "expected": expected_out,
            }
        )

    if entries:
        sections: list[str] = []
        current_suite: str | None = None
        for entry in entries:
            if entry["suite"] != current_suite:
                current_suite = entry["suite"]
                sections.append(f'<h2 class="suite">{html.escape(prettify_suite(current_suite))}</h2>')
            sections.append(build_card(entry))
        body = "\n".join(sections)
        count = f'{len(entries)} mismatched screen{"s" if len(entries) != 1 else ""}'
    else:
        body = (
            '<p class="empty">No snapshot image mismatches were captured.<br>'
            "The failure was likely a build or runtime error — check the job log.</p>"
        )
        count = "0 mismatched screens"

    (out_dir / "index.html").write_text(PAGE.format(count=html.escape(count), body=body), encoding="utf-8")

    print(f"Snapshot diff report: {count} -> {out_dir / 'index.html'}")
    for entry in entries:
        tag = "" if entry["expected"] else "  (new, no baseline)"
        print(f"  - {entry['rel']}{tag}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
