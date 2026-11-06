#!/bin/bash
#
# Enables trusted publishing for a repository.
# 
# Preconditions:
# - You must be logged in as a maintainer ("npm login"). Administrative permissions for the packages on npmjs.com are required
# - Your npmjs.com account must use 2FA
# - The packages need to exist already. Enabling trusted publishing requires at least one previous publish operation to initialize the package.
#
# The first `npm trust` call will challenge your 2FA (e.g. passkey).
# Authenticate the request, and check the "do not challenge for 5 minutes" checkbox in the login interface.
#
# Note that this script is not idempotent: it will create new trust relationships on each run.
# Use `npm trust list $packagename` to list existing trust relationships.
#
# For more details, see https://docs.npmjs.com/cli/v12/commands/npm-trust
set -euo pipefail

REPO="open-pioneer/trails-build-tools"

# List of packages to manage.
# For example, in a pnpm based repository, run:
#
#  $ pnpm ls -r --depth -1 --json | jq ".[] | select(.private | not) | .name"
PACKAGES=(
    "@open-pioneer/build-common"
    "@open-pioneer/build-package"
    "@open-pioneer/build-package-cli"
    "@open-pioneer/build-support"
    "@open-pioneer/changesets-release-line"
    "@open-pioneer/check-pnpm-duplicates"
    "@open-pioneer/cli-common"
    "@open-pioneer/create-license-report"
    "@open-pioneer/pnpm-plugin-defaults"
    "@open-pioneer/vite-plugin-pioneer"
)

for pkg in "${PACKAGES[@]}"; do
    echo "Setting up trusted publishing for $pkg / ci.yaml"
    npm trust github "$pkg" \
        --repo="$REPO" \
        --file=ci.yml \
        --registry=https://registry.npmjs.org/ \
        --allow-publish --yes
    sleep 2

    echo "Setting up trusted publishing for $pkg / publish-snapshot.yaml"
    npm trust github "$pkg" \
        --repo="$REPO" \
        --file=publish-snapshot.yml \
        --registry=https://registry.npmjs.org/ \
        --allow-publish --yes

    sleep 2 # Avoid rate limiting
done
