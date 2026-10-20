# Working with Claude Code

Once the Postiz MCP server is connected (README step 5), Claude Code can list your channels, upload media and schedule posts. A good loop:

1. **Point at the source.** *"The invites are in ~/Work/Client X/. Make a 4-slide 1080×1350 carousel for each, in the style of this Pinterest board."*
2. **Review before anything is public.** Ask for a contact sheet of all slides. Check that names, numbers and QR codes are blurred.
3. **Captions.** *"Write a caption for each: a hook, what the design includes, a swipe cue, a DM call to action, max 5 hashtags."*
4. **Upload and schedule.** *"Convert to JPEG, upload, and schedule on Instagram: post 1 Tue 19:00, post 2 Thu 19:00 (my time zone is UTC+3)."* Postiz wants **UTC** times, so say your time zone.
5. **Verify.** *"List my scheduled posts for the next two weeks."* Every one should be in state `QUEUE`.
6. **Reminders.** On macOS, Claude can add Reminders via AppleScript: *"Remind me 2 minutes after each post to check it went live and add the song."*

## Rules worth giving Claude (it remembers them if you ask it to)
- The contact or RSVP slide goes **last** in an invitation carousel.
- Every slide carries your credit line in a corner.
- Max 5 hashtags.
- Always show the final text, slides and times, and wait for "yes" before scheduling.

## Things Claude can't do here
- Add Instagram music to carousels, or hide like counts (API limits; do these in the app).
- Sign in to Meta, LinkedIn or Tailscale for you, or type passwords and API keys. You do those steps.
