# Bergeron Marital Property Agreement — Intake Form

## Overview

A production web-based intake questionnaire for The Talley Law Firm PLLC's Bergeron marital property agreement matter. 15-section multi-step wizard with save/resume, n8n webhook integration, Supabase storage, and Dropbox file management.

## Architecture

- **Frontend**: Single HTML file with Tailwind CSS, hosted on GitHub Pages
- **Backend**: n8n workflow handles form submissions
- **Database**: Supabase (PostgreSQL) with JSONB storage
- **File Storage**: Dropbox via n8n integration
- **Domain**: intake.thetalleylaw.com

## Quick Start

### 1. Deploy to GitHub Pages

```bash
git remote add origin https://github.com/YOUR_USERNAME/bergeron-postnup-intake.git
git push -u origin main
```

Then in GitHub repo Settings -> Pages -> Source: Deploy from branch -> main -> / (root) -> Save

### 2. Configure Custom Domain

In your DNS provider (for thetalleylaw.com):

- Add CNAME record: `intake` -> `YOUR_USERNAME.github.io`
- In GitHub Pages settings, set custom domain to `intake.thetalleylaw.com`
- Enable "Enforce HTTPS"

Note: DNS propagation may take up to 24 hours.

### 3. Set Up Supabase Table

- Go to your Supabase project dashboard
- Open SQL Editor
- Paste and run the contents of `supabase-schema.sql`
- Or use the Supabase CLI: `supabase db push`

Note down:

- Project URL (e.g., https://xxxx.supabase.co)
- Service Role Key (from Settings -> API)

### 4. Import n8n Workflow

1. Open your n8n instance
2. Go to Workflows -> Import from File
3. Select `n8n-workflow.json`
4. Configure credentials:
   - **Supabase**: Set environment variables or update HTTP Request nodes with your Supabase URL and service role key
   - **Dropbox**: Create a Dropbox OAuth2 credential (Settings -> Credentials -> Add -> Dropbox OAuth2 API)
5. Activate the workflow
6. Copy the webhook URL (shown in the Webhook trigger node)

### 5. Update the Form

Open `index.html` and replace these placeholders:

- `YOUR_N8N_WEBHOOK_URL` -> your actual n8n webhook URL (e.g., `https://your-n8n.com/webhook/bergeron-intake`)
- `YOUR_SUPABASE_URL` -> your Supabase project URL
- `YOUR_SUPABASE_ANON_KEY` -> your Supabase anon key (for read-only draft loading)

### 6. Configure Dropbox OAuth in n8n

1. Go to [Dropbox App Console](https://www.dropbox.com/developers/apps)
2. Create a new app -> Scoped access -> Full Dropbox
3. Under Permissions, enable: files.content.write, files.content.read
4. Copy App Key and App Secret
5. In n8n -> Credentials -> Dropbox OAuth2 API -> enter App Key, App Secret
6. Click "Connect" and authorize

### 7. Test the Form

1. Open `intake.thetalleylaw.com` (or localhost if testing locally)
2. Fill in a few fields on step 1
3. Click "Save Progress" — verify:
   - n8n webhook receives the POST
   - Supabase table gets a new row with status='draft'
   - TXT summary appears in Dropbox folder
   - Remaining fields TXT appears in Dropbox
4. Note the token from the URL or response
5. Open the form with `?token=YOUR_TOKEN` — verify it reloads your saved data
6. Complete all 15 sections and click Submit — verify:
   - Status changes to 'final' in Supabase
   - PDF is generated and saved to Dropbox
   - Confirmation page appears with download button

## File Structure

```
bergeron-intake-form/
├── index.html              # Complete 15-section intake form
├── n8n-workflow.json        # Ready-to-import n8n workflow
├── supabase-schema.sql      # Database table creation script
├── CNAME                    # Custom domain for GitHub Pages
├── README.md                # This file
└── logo.png                 # Firm logo (add manually)
```

## Form Features

- 15-step wizard matching the exact PDF questionnaire
- Auto-save to localStorage every 30 seconds
- Save Progress button on every step (POSTs to n8n)
- Resume via `?token=` URL parameter
- File upload with drag-and-drop, size/type validation
- Conditional field visibility (Yes/No toggles)
- Dynamic table rows (add/remove)
- Honeypot spam protection
- reCAPTCHA v3 placeholder (add site key to enable)
- Mobile-responsive design
- Confirmation page with JSON download on final submit

## Three Independent Copies of Data

1. **Supabase**: JSONB column with full responses, queryable
2. **Dropbox TXT**: Human-readable summary saved on every save
3. **Dropbox PDF**: Formatted PDF matching questionnaire layout (on final submit)

## Security Notes

- Form data is transmitted over HTTPS
- Supabase RLS restricts access to service_role only
- No client data is exposed via anon key
- Tokens are UUID-based (not guessable)
- Honeypot field catches basic bots

## Maintenance

- To update form fields: edit index.html directly
- To change Dropbox folder path: update the Code node in n8n workflow
- To add new sections: add a new step div and update totalSteps in JS

---

*Confidential — The Talley Law Firm PLLC*