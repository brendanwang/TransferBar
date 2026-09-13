# TransferBar icon artwork

Generated with the built-in image generation tool.

## Light prompt

Use case: logo-brand. Create a finished macOS application icon for TransferBar, a lightweight Finder file transfer progress menu bar utility. Light mode version. Single centered rounded-square porcelain white tile with subtle cool silver depth, isolated on genuinely transparent canvas, conventional macOS icon safe margins (tile occupies about 82% of square). Inside, two bold beautifully sculpted opposing horizontal transfer arrows in saturated ocean blue and cyan, with a small elegant horizontal progress track below, partially filled blue. Crisp minimal premium Apple-like utility aesthetic, soft dimensional bevels, restrained shadows, legible at tiny sizes. Symmetrical balanced composition. No text, no letters, no watermark, no extra objects. 1024x1024 square.

## Dark prompt

Use case: identity-preserve. Edit the supplied TransferBar app icon to create its matching DARK MODE version. Preserve precisely the tile silhouette, transparent outside canvas, margin, two opposing arrows, their locations and shapes, progress track and its fill level. Change ONLY the porcelain white tile to rich dark graphite with subtle bevel lighting, change track to recessed charcoal, and keep bright saturated blue/cyan arrows with restrained highlights so they read well against graphite. Same premium macOS icon, no text or extra elements. Clean transparent exterior.

Dark output cleanup: remove the rendered checkerboard and retain genuine transparent alpha outside the tile.

## Integration

AppIcon contains the light icon at all standard macOS sizes. TransferBarIcon is an appearance-aware image set used by the panel. AppDelegate observes effectiveAppearance to update the running application icon. The Finder bundle icon remains light; applicationIconImage does not change Finder's bundle icon.
