┌─────────────────────────────┐
│           API Gateway       │
│           (HTTP API)        │
│                             │
│  POST /shorten   GET /{short_url}
│         │                 │
│         └──────────┬──────┘
│                    │
│                    │
│                    ▼
┌─────────────────────────────┐
│           Lambda            │
│       (CreateShortURL)      │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │                       │  │
│  └─────────┬─────────────┘  │
│            │                │
│            ▼                │
┌─────────────────────────────┐
│           DynamoDB          │
│           (URLs Table)      │
│                             │
│  Stores mapping between     │
│  short URLs and long URLs   │
└─────────────────────────────┘
                    │
                    │
                    ▼
┌─────────────────────────────┐
│           Lambda            │
│         (RedirectURL)       │
│                             │
│ Retrieves long URL from DB  │
│   and redirects the user    │
└─────────────────────────────┘
             │
             ▼
┌─────────────────────────────┐
│            Client           │
│            (Browser)        │
└─────────────────────────────┘

        (Optional)
        ┌─────────────────────┐
        │          S3         │
        │  (Static Frontend)  │
        └─────────────────────┘
