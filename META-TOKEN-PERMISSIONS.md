# Meta and Pinterest token permissions for The Brain

What the owner's apps are allowed to do on his social accounts, written down once so every agent and
every future connector follows it. Rule from the owner (21 October 2026): **search only, never post.**
The one exception he allowed: saving memes to a collection so nothing is lost, and removing them later.

## Meta (Instagram Graph API)

Reference: https://developers.facebook.com/documentation/development/permissions

| Permission or feature | Used by The Brain | What it allows | Writes? |
| --- | --- | --- | --- |
| `instagram_basic` | yes | read the owner's Instagram professional account profile and media | no |
| `pages_show_list` | yes | list the Facebook Page the Instagram account is linked to | no |
| `pages_read_engagement` | yes | read that Page's metadata (needed to reach the linked Instagram account) | no |
| Instagram Public Content Access (feature, App Review) | yes | hashtag search: `ig_hashtag_search`, `top_media`, `recent_media`; captions, counts, links; 30 hashtags per 7 days | no |
| `instagram_manage_insights` | not now; only per task with the owner's approval | the owner's own account insights | no |
| `instagram_content_publish`, `instagram_business_content_publish` | never | create and publish posts | yes |
| `instagram_manage_comments`, `instagram_business_manage_comments` | never | create, delete, hide comments | yes |
| `instagram_manage_messages`, `instagram_business_manage_messages` | never | read and answer Direct messages | yes |
| `instagram_manage_engagement` | never | like and unlike | yes |
| `instagram_manage_contents` | never | delete posts, stories, reels | yes |
| `pages_manage_posts`, `pages_manage_engagement`, `pages_manage_metadata` | never | post, comment, change the Page | yes |
| `pages_read_user_content` | never | read and delete user comments on the Page | partly |
| `business_management` | never | Business Manager and ad accounts | yes |

Instagram's API has no "save to collection" endpoint, so a meme found on Instagram is kept as its
info (caption, counts, link, licence) in the memez folder on the owner's PC, never as a repost or a
saved post on Instagram.

How the app enforces it: `server/instagram.mjs` in the-brain makes GET calls only. The token is
stored in `%APPDATA%\the-brain\instagram.json`, never in a repo, a prompt or the app window.

## Pinterest (API v5)

| Scope | Used by The Brain | What it allows | Writes? |
| --- | --- | --- | --- |
| `pins:read` | yes | pin search, find a specific meme, read a pin | no |
| `boards:read` | yes | find the owner's secret `memez` board | no |
| `user_accounts:read` | yes | check the token at setup | no |
| `pins:write` | yes, memez board only | save a found pin to the memez board; remove a pin from it | yes, that board only |
| `boards:write` | yes, once | make the secret `memez` board if the owner has none | yes, once |
| anything else (`boards:write` on other boards, ads, catalogs, messaging) | never | | |

How the app enforces it: `server/pinterest.mjs` lets a write through only when it is a save to the
memez board, a delete of a pin that is already on that board, or the one-time creation of a secret
board named `memez`. Every other write is refused before it reaches Pinterest.

## Reddit, Imgflip, Google Trends, Know Your Meme

Public reads without any account. Nothing to grant.

## Asking for more

Any permission not marked "yes" above is requested only for one named task, after the owner says yes
in the app, and is dropped from the token afterwards.
