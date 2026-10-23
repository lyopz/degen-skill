---
name: widget-board
description: Adds a floating "tab wheel" of widget cards at the bottom of a site — a spinning row of picture cards that follows the page's sections and does something when tapped (jump to a section, open a link, copy text, call, book). Use when lyopz asks for a widget board, tab wheel, bottom wheel, bottom dock or quick-action cards on any website or project.
---

<!-- from: lyopz (own design, first built on the Degen Skills showcase site) -->

# Widget Board

A dock that slides up after the hero. Cards sit on a curved wheel; the front one glows. It turns by itself to match the section you've scrolled to, and you can spin it with the mouse wheel, the ‹ › buttons, arrow keys or a swipe. Tapping a side card brings it to the front; tapping the front card does its action.

Code: `widget-board.js` in this folder (paste into a `<script>`). Image cards use `particle-media` automatically if `particle-media.js` is on the page too.

## Pick the widgets (the important part)

The board is a rough idea that changes per project. **Decide the cards from what visitors of THIS project need most**, 4–6 cards, most useful first:
- Each card = one picture or tiny preview + one clear action.
- Actions: `section` (scroll to part of the page), `href` (link, `tel:`, `mailto:`, map), `copy` (copy text: commands, promo codes, addresses, wallet/contract text), `action` (custom JS, e.g. open a cart or modal).
- Prefer actions people would otherwise hunt for. Examples:
  - **Skill/dev library:** Skills · 3D · Packs · Install (copy `git pull`) · GitHub link.
  - **Restaurant:** Menu · Book a table (link) · Call (tel:) · Directions (map) · Hours.
  - **Shop / clothing brand:** New drops · Best sellers · Cart · Copy promo code · Instagram/TikTok.
  - **Game:** Play · Trailer · Discord · Copy server/game code · Leaderboard.
  - **Portfolio / service:** Work · Pricing · Book a call · Copy email.
- Use the site's real pictures (or Higgsfield art) on cards that have them; text cards (`html`) for commands or codes.
- When lyopz changes the board on one site, follow his new version from then on.

## Use it
```js
WidgetBoard({
  items: [
    { label: 'Skills',  img: 'cards.jpg', section: 'skills' },
    { label: 'Install', html: '$ git pull<br>✓ ready', copy: 'cd $HOME\\.claude\\degen-skill; git pull' },
    { label: 'GitHub',  bg: 'linear-gradient(135deg,#e11d2e,#4a0710)', html: '★ repo', href: 'https://github.com/lyopz/degen-skill' },
  ],
  accent: '#e11d2e',      // match the site's main color
  showAfter: '#hero',     // hide while the hero is on screen; null = always visible
});
```
Item fields: `label`, `img`, `html`, `bg`, `section`, `href`, `copy`, `action`, `actionLabel`.

## Notes
- Give the page bottom padding (~180px) so the dock never covers the footer.
- Keep labels to one or two words. Copy cards show "⧉ Copy" and flip to "✓ Copied".
- Respects reduced motion (no particles). Works on phones (swipe).
- Example in use: the Degen Skills showcase site.
