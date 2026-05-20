#!/bin/bash
# Pre-commit hook: Detect hardcoded secrets and tokens before committing
# Place in .git/hooks/pre-commit or run manually before /git command

echo "🔍 Running secret detection scan..."

# Patterns to detect hardcoded secrets
PATTERNS=(
  "ghp_[A-Za-z0-9]{36}"          # GitHub Personal Access Token
  "github_pat_[A-Za-z0-9]{22}"   # GitHub Fine-Grained PAT
  "sk-[A-Za-z0-9]{48}"           # OpenAI API Key
  "xoxb-[A-Za-z0-9-]+"           # Slack Bot Token
  "xoxp-[A-Za-z0-9-]+"           # Slack User Token
  "AIza[0-9A-Za-z-_]{35}"        # Google API Key
  "eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+" # JWT Token
  "-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----" # Private Keys
  "AKIA[0-9A-Z]{16}"             # AWS Access Key
  "password\s*[:=]\s*['\"][^'\"]+['\"]" # Hardcoded passwords
  "api_key\s*[:=]\s*['\"][^'\"]+['\"]"   # Hardcoded API keys
  "secret\s*[:=]\s*['\"][^'\"]+['\"]"    # Hardcoded secrets
)

FOUND=0

for pattern in "${PATTERNS[@]}"; do
  # Search in staged files only (if running as git hook)
  if git diff --cached --name-only 2>/dev/null | grep -q .; then
    files=$(git diff --cached --name-only)
  else
    # Search all tracked files
    files=$(git ls-files)
  fi
  
  for file in $files; do
    if [ -f "$file" ]; then
      matches=$(git show ":$file" 2>/dev/null | grep -E "$pattern" || grep -E "$pattern" "$file" 2>/dev/null)
      if [ -n "$matches" ]; then
        echo "❌ SECRET DETECTED in $file:"
        echo "   Pattern: $pattern"
        echo "   Match: $(echo "$matches" | head -1 | sed 's/./& /g' | cut -c1-80)..."
        FOUND=1
      fi
    fi
  done
done

if [ $FOUND -eq 1 ]; then
  echo ""
  echo "🛑 COMMIT BLOCKED: Hardcoded secrets detected!"
  echo ""
  echo "💡 Fix: Replace hardcoded values with environment variables:"
  echo '   "API_KEY": "${API_KEY}"'
  echo ""
  echo "   Then export the variable in your shell:"
  echo "   export API_KEY='your-actual-key'"
  echo ""
  echo "⚠️  Note: opencode.json must contain __GITHUB_TOKEN__ placeholder, not a real token."
  echo ""
  exit 1
else
  echo "✅ No hardcoded secrets detected."
  exit 0
fi
