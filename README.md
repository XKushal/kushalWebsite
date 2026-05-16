# kushal.chat

Personal website for Kushal Singh, built with a small custom static-site generator using Python, Jinja2, Mistune, and Tailwind CSS.

## Dependencies

```bash
pnpm install
uv sync
```

## Development

```bash
uv run python src/build.py --output dist
pnpm dev
```

## Production

```bash
pnpm build
```

The production site is intended to deploy on Vercel with `dist/` as the static output directory.
