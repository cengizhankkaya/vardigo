# Vardigo launch assets

These 220pt images and the platform launcher icons are exported from
`assets/branding/vardigo_splash_logo.png` without changing the original artwork.

To reproduce them on macOS, run from `apps/mobile`:

```sh
swift -module-cache-path /tmp/vardigo-branding-modules tool/export_branding.swift
```

The native launch screen is static until Flutter renders its first frame; the
Flutter startup widget provides the animation. The native background follows
the system's light/dark appearance. Flutter then applies the saved in-app theme.
