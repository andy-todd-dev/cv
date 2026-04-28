---
name: Andrew Todd
location: Brighton, East Sussex, United Kingdom
phone: "+44770 953 9459"
email: email.andy.todd@gmail.com
linkedin: https://www.linkedin.com/in/andrew-todd-81a61766/
github: https://github.com/andy-todd-dev
---

## Skills

::: {.skilltable}

### Kotlin/Java

Ktor · Kotest · Exposed · Axon · Gradle · Coroutines · Koin · Arrow

### Scala

Http4s · Cats · Cats Effect · Circe · Doobie · Akka · Akka-Streams · SBT · Specs2

### Web

TypeScript · React · Next.js · Vite · Tailwind CSS · PWA

### Mobile

Flutter · Dart · Riverpod · Drift · Patrol · Kotlin · Jetpack Compose · Hilt

### Tooling

Git · GitHub · GitHub Actions · Docker · Dev Containers · Kubernetes · Terraform · AWS SAM · Nginx · PostgreSQL · MongoDB · Redis · MQTT · Cypress · Cucumber · Grafana · Prometheus

### Platforms

GCP · AWS · Firebase

### Integrations

Stripe · PayPal · WorldPay · UPS · DHL · RevenueCat · Gemini · eBay · Starling Bank

### Methodologies

Test Driven Development · Behaviour Driven Development · Domain Driven Design · Event Sourcing · CQRS · Hexagonal Architecture · Continuous Delivery / Integration · Microservices · Functional Programming · Pair Programming · Mob Programming · Agile (Scrum, Kanban)

### AI Development

GitHub Copilot · Copilot Agents

:::

## Experience

### Recipe Raven — Founder & Developer \hfill \cvdate{2024 – Present}

- Sole founder and developer of a commercial cross-platform recipe app (Flutter/Android) with a dual-runtime Firebase backend — TypeScript Cloud Functions for AI/web pipelines, Python for NLP; currently in closed testing ahead of commercial launch via Google Play
- Engineered a Gemini-powered recipe extraction pipeline handling URLs, Instagram HTML scraping (no official API), images, and OCR; parameterised prompt design with per-field type-safe response parsing to prevent LLM hallucination propagation
- Implemented production-grade subscription credit metering: Firestore pessimistic locking to prevent race conditions across concurrent requests, idempotent RevenueCat deductions, and immediate UI feedback from backend responses
- Local-first architecture using Drift (SQLite) with a versioned `importData`/`compileRecipe` schema split, enabling transparent re-parsing of all stored recipes when extraction logic improves; stepwise migrations including in-SQL data transformations
- CI/CD pipeline with Workload Identity Federation (no stored credentials), automated build versioning via Firebase, and Android keystore injection from secrets

### The Geek Tech Workshop — Founder & Developer \hfill \cvdate{February 2022 – Present}

- Operated a commercial e-store (sole trader) selling repaired electronics and 3D-printed board game accessories
- Built a serverless automated accounting pipeline using AWS SAM (Lambda, API Gateway, Google Sheets) that integrates with eBay and Starling Bank APIs
- Created `bambu-cli`, a Python CLI tool for managing print jobs across Bambu Lab 3D printers; published on PyPI and Docker Hub
- Developed an Android app (Kotlin/Jetpack Compose) to scan and rewrite RFID tags on Bambu filament spools

```{=latex}
\newpage
```

### Hozah Ltd, London — Software Engineer, Architect, Technical Lead, CTO \hfill \cvdate{March 2019 – February 2022}

- Managing Dev and Support teams at Tech startup
- Technical leadership for architecting, maintenance and development of existing and new software solutions within Hozah: a Smart Parking and Payment Solutions company
- Solutions built using Kotlin, Scala and JavaScript (React). Infrastructure hosted primarily with Google Cloud Platform
- Systems and architecture made heavy use of Domain Driven Design, event based communication, and event sourcing
- Guided Dev team to more productive processes and tooling through discussion, feedback and presentation
- Migrated team to Infrastructure As Code approach
- Mentoring of junior developers with Pair and Mob programming and code review

### Dice Technology Ltd, London — Backend Developer \hfill \cvdate{September 2018 – March 2019}

- Building very low latency microservices. Streaming data from sporting events to clients using akka-streams
- Infrastructure / deployment flow built and maintained by the Dev team (in AWS)

### Yoox Net-A-Porter, London — Senior Developer \hfill \cvdate{May 2014 – September 2018}

- Lead voice in drive to migrate from Perl monolith to Scala implemented Service Oriented Architecture
- Creation of Shipping-Option, Shipment-Booking and Document-Generation services, built to high traffic SLAs. Earlier services hosted in-house, later using AWS
- Mentoring of graduate / junior developers through Pair Programming, code-review, and team discussion. Also presenting material to rest of company Scala community and / or running more practical workshops

### The Net-A-Porter Group, London — Perl Developer \hfill \cvdate{November 2012 – May 2014}

- Key part of effort to modernise legacy code-base with 'modern' Perl libraries and techniques
- Collaborated with Devops teams to push older projects to adopt newer build, test, and deploy tools as they became available

### Webfusion Ltd, London — Perl Developer / Team Leader \hfill \cvdate{June 2011 – November 2012}

- Maintained and added new integrations with payment providers (Worldpay, Paypal, Direct Debit)
- Lead voice in project to normalise representations of services to customers, as represented in architecture. This lead to making considerable efficiencies in how repayments for these services were calculated and processed

### Intergage Ltd, Poole/Southampton — Perl Developer \hfill \cvdate{January 2008 – June 2011}

- Improvements to internally developed CMS system, both front and back end
- Worked directly with customers with custom requirements in order to create proposed technical project specifications
- Part of team also responsible for systems administration and general technical support

## Education

### University of Glamorgan, South Wales — BSc Software Engineering, 2:1 \hfill \cvdate{2004 – 2007}

### Professional Development

- Functional Programming Principles in Scala (Coursera)
- Migrating to a Service Oriented Architecture
- Core Scala (Underscore)
