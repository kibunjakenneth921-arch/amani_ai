# Cloud Functions for Amani AI

This folder contains example Firebase Cloud Functions that can be deployed to support server-side actions such as sending push notifications and content moderation.

Install dependencies and deploy:

```bash
cd functions
npm install
firebase deploy --only functions
```

Environment variables:
- `OPENAI_API_KEY` (optional): if set, `moderateContent` will call OpenAI Moderation.

Functions:
- `sendNotification` (HTTP): POST { userId, title, body, data? }
- `moderateContent` (HTTP): POST { text }

Security:
- Restrict who can call these functions using IAM or by checking an API key in the request.
