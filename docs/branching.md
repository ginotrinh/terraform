#### Branching Strategy
- main: Production environment (protected)
- uat: UAT environment (protected)
- dev: Development environment (protected)
- feature/*: Feature branches for new work
- hotfix/*: Hotfix branches for urgent fixes

#### Branch Protection Rules
Set up the following protection rules in GitHub:
-   `main` branch:
    -   Require pull request before merging
    -   Require approvals from at least 2 reviewers
    -   Require status checks to pass (Terraform validation, security scan)
    -   Require linear history (no merge commits)
    -   Allow force pushes only for admins
-   `uat` branch:
    -   Require pull request before merging
    -   Require approval from at least 1 reviewer
    -   Require status checks to pass
    -   Allow force pushes only for admins
-   `dev` branch:
    -   Require pull request before merging
    -   Require approval from at least 1 reviewer
    -   Require status checks to pass

