# Notes

This is a small thing I wrote for myself.

* www/ will be served

* src/ will be watched and rendered

## Rendering

Anything with extension .md will be put through marked, and the extension will be stripped.

Existing files in www/ will be replaced by renders as needed, but static files in www/ are okay too.

Some html, scripts etc. will be added to the renders.

## Serving

Changes to /www will cause a refresh.

# Known problems

* Only renders the root of src/, ie. not recursively

* Doesn't catch up on launch: only renders things that change while it's running