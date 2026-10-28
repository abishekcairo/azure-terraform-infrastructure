# Production-Style Azure Infrastructure with Terraform

One-paragraph summary: what it builds and why it matters.

## Architecture
![Architecture](docs/architecture.png)

## Tech stack
Azure, Terraform, GitHub Actions, OIDC, Checkov, TFLint, pre-commit

## Features
- Modular design (networking, compute, database, keyvault, monitoring)
- Remote state with locking in Azure Storage
- Separate dev and prod environments
- CI/CD: plan on PR, approval-gated apply
- Secrets in Key Vault, private database, no public servers

## Repository structure
(paste your folder tree)

## How to deploy
1. Prerequisites
2. Bootstrap the remote state
3. Deploy dev
4. Deploy prod
(include exact commands)

## CI/CD pipeline
(diagram + short explanation + screenshots)

## Security decisions
(your checklist and the reasons)

## Cost
(estimate from the Azure pricing calculator + how you kept it low)

## Testing and results
(screenshots: website, load balancing, alert email, drift, locking)

## Challenges and lessons learned
(real errors you hit and how you solved them)

## Future improvements
AKS, hub-spoke network, Application Gateway with WAF, Terraform tests, Infracost
