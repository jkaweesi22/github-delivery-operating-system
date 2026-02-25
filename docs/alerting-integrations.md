# Alerting Integrations

## Overview

The Delivery Operating System supports two real-time alert channels:

1. **Telegram** — Via Bot API
2. **WhatsApp** — Via Meta Cloud API or Twilio

Alerting is **optional, modular, and non-blocking**. By default, all alert flags are `false`; enable per channel in your trigger workflow.

| Property | Behavior |
|----------|----------|
| Default state | Disabled (`enable_telegram: false`, `enable_whatsapp: false`) |
| Enable | Set `enable_telegram: true` or `enable_whatsapp: true` in trigger |
| Missing secrets | Alert jobs skip execution; workflow succeeds |
| Failure handling | `continue-on-error: true` — governance never blocked by alert failures |

All credentials use `${{ secrets.* }}`. No tokens are hardcoded.

---

## Telegram

### Required Secrets

| Secret | Description |
|--------|-------------|
| `TELEGRAM_BOT_TOKEN` | Bot token from [@BotFather](https://t.me/botfather) |
| `TELEGRAM_CHAT_ID` | Chat or channel ID to receive messages |

### Setup

1. Create a bot with [@BotFather](https://t.me/botfather); copy the token.
2. Start a chat with your bot or add it to a group/channel.
3. Get the chat ID:
   - Send a message to the bot or channel.
   - Visit `https://api.telegram.org/bot<TOKEN>/getUpdates` and read the `chat.id` from the response.
4. Add secrets in the repository: **Settings → Secrets and variables → Actions**.

### Message Format

```
📦 Delivery OS Alert

Event: PR Merged
Repo: owner/repo
Title: Feature X implementation
Triggered by: @username
Link: https://github.com/owner/repo/pull/42
```

### Trigger Events

- PR merged
- `production` label added
- `sprint-planning` label added
- `risk` label added

---

## WhatsApp

Two providers are supported. Configure one; the workflows detect which secrets are present.

### Option A: Meta WhatsApp Cloud API

| Secret | Description |
|--------|-------------|
| `WHATSAPP_ACCESS_TOKEN` | Meta Graph API access token |
| `WHATSAPP_PHONE_NUMBER_ID` | Phone number ID from Meta Business Suite |
| `WHATSAPP_RECIPIENT_NUMBER` | Recipient in E.164 (e.g., 14155238886) |

#### Setup

1. Create a Meta Developer account and WhatsApp Business API app.
2. Obtain the phone number ID and access token from the Meta dashboard.
3. Add the three secrets to your repository.

### Option B: Twilio WhatsApp API

| Secret | Description |
|--------|-------------|
| `TWILIO_ACCOUNT_SID` | Twilio account SID |
| `TWILIO_AUTH_TOKEN` | Twilio auth token |
| `TWILIO_WHATSAPP_NUMBER` | Twilio WhatsApp number (e.g., whatsapp:+14155238886) |
| `WHATSAPP_RECIPIENT_NUMBER` | Recipient number (e.g., +1234567890) |

#### Setup

1. Create a Twilio account and enable WhatsApp Sandbox or Production.
2. Get SID, auth token, and WhatsApp-enabled number from the console.
3. Add the four secrets to your repository.

### Message Format

```
🚨 Delivery OS Alert

Event: Production Release Request
Repo: owner/repo
Title: Sprint 12 - Release Candidate
QA Recommendation: Approve for Production
Link: https://github.com/owner/repo/issues/42
```

### Trigger Events

- PR merged
- `production` label added

---

## Security

- **Never commit tokens** — Use repository secrets only.
- **Minimal scope** — Use tokens with minimal required permissions.
- **Rotation** — Rotate tokens periodically; update secrets in GitHub.
