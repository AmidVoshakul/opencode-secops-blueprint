#!/usr/bin/env python3
"""
Multi-Skill Orchestration Engine for Agent Orchestrator.

Given matched skills and a query, determines the orchestration pattern
and generates an execution plan for Claude/OpenCode to follow.
"""

import json
import sys
from pathlib import Path

# ── Configuration ──────────────────────────────────────────────────────────

_SCRIPT_DIR = Path(__file__).resolve().parent
ORCHESTRATOR_DIR = _SCRIPT_DIR.parent
SKILLS_ROOT = ORCHESTRATOR_DIR.parent
DATA_DIR = ORCHESTRATOR_DIR / "data"
REGISTRY_PATH = DATA_DIR / "registry.json"

PRODUCER_CAPABILITIES = {"data-extraction", "government-data", "analytics"}
CONSUMER_CAPABILITIES = {"messaging", "social-media", "content-management"}
HYBRID_CAPABILITIES = {"api-integration", "web-automation"}


# ── Functions ──────────────────────────────────────────────────────────────

def sanitize_string(s: str) -> str:
    """Sanitize query string against shell injection and malicious JSON mutation."""
    if not s:
        return ""
    # Safe filtration against ASI05/MCP05 vulnerabilities
    bad_chars = [";", "&&", "|", "`", "$", "(", ")", '"']
    for char in bad_chars:
        s = s.replace(char, "")
    return s.strip()


def load_registry() -> dict[str, dict]:
    """Load registry as name->skill dict."""
    if not REGISTRY_PATH.exists():
        return {}
    try:
        data = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
        return {s["name"]: s for s in data.get("skills", [])}
    except Exception:
        return {}


def get_skill_role(skill: dict) -> str:
    """Determine if a skill is primarily a producer, consumer, or hybrid."""
    caps = set(skill.get("capabilities", []))
    producer_count = len(caps & PRODUCER_CAPABILITIES)
    consumer_count = len(caps & CONSUMER_CAPABILITIES)

    if producer_count > consumer_count:
        return "producer"
    elif consumer_count > producer_count:
        return "consumer"
    elif producer_count > 0 and consumer_count > 0:
        name = skill.get("name", "").lower()
        if any(kw in name for kw in ["scraper", "extract", "collect", "data", "junta"]):
            return "producer"
        if any(kw in name for kw in ["whatsapp", "instagram", "messenger", "notify"]):
            return "consumer"
        return "hybrid"
    else:
        return "hybrid"


def classify_pattern(skills: list[dict], query: str) -> str:
    """Determine the orchestration pattern based on skill roles and score gaps."""
    if len(skills) <= 1:
        return "single"

    roles = [get_skill_role(s) for s in skills]
    has_producer = "producer" in roles
    has_consumer = "consumer" in roles

    if has_producer and has_consumer:
        return "sequential"

    # Skills array is already sorted descending by score in main loop
    if len(skills) >= 2:
        if skills[0].get("score", 0) >= skills[1].get("score", 0) * 2:
            return "primary_support"

    return "parallel"


def generate_plan(skills: list[dict], query: str, pattern: str) -> dict:
    """Generate an execution plan based on the pattern."""

    if pattern == "single":
        skill = skills[0]
        return {
            "pattern": "single",
            "description": f"Use '{skill['name']}' to handle the entire request.",
            "steps": [
                {
                    "order": 1,
                    "skill": skill["name"],
                    "skill_md": skill.get("skill_md", skill.get("location", "")),
                    "action": f"Load SKILL.md and follow its workflow for: {query}",
                    "input": "user_query",
                    "output": "result",
                }
            ],
            "data_flow": "user_query -> result",
        }

    elif pattern == "sequential":
        producers = [s for s in skills if get_skill_role(s) in ("producer", "hybrid")]
        consumers = [s for s in skills if get_skill_role(s) == "consumer"]

        if not producers:
            producers = [skills[0]]
            consumers = skills[1:]

        ordered = producers + consumers
        steps = []
        for i, skill in enumerate(ordered):
            role = get_skill_role(skill)
            if i == 0:
                input_src = "user_query"
                action = f"Extract/collect data: {query}"
            else:
                prev = ordered[i - 1]["name"]
                input_src = f"{prev}.output"
                if role == "consumer":
                    action = f"Process/deliver data from {prev}"
                else:
                    action = f"Continue processing with data from {prev}"

            steps.append({
                "order": i + 1,
                "skill": skill["name"],
                "skill_md": skill.get("skill_md", skill.get("location", "")),
                "action": action,
                "input": input_src,
                "output": f"{skill['name']}.output",
                "role": role,
            })

        flow_parts = [s["skill"] for s in steps]
        data_flow = " -> ".join(["user_query"] + flow_parts + ["result"])

        return {
            "pattern": "sequential",
            "description": f"Pipeline: {' -> '.join(flow_parts)}",
            "steps": steps,
            "data_flow": data_flow,
        }

    elif pattern == "parallel":
        steps = []
        for i, skill in enumerate(skills):
            steps.append({
                "order": 1,
                "skill": skill["name"],
                "skill_md": skill.get("skill_md", skill.get("location", "")),
                "action": f"Handle independently: aspect of '{query}' related to {', '.join(skill.get('capabilities', []))}",
                "input": "user_query",
                "output": f"{skill['name']}.output",
            })

        return {
            "pattern": "parallel",
            "description": f"Execute {len(skills)} skills in parallel, each handling their domain.",
            "steps": steps,
            "data_flow": "user_query -> [parallel] -> aggregated_result",
            "aggregation": "Combine results from all skills into a unified response.",
        }

    elif pattern == "primary_support":
        primary = skills[0]
        support = skills[1:]

        steps = [
            {
                "order": 1,
                "skill": primary["name"],
                "skill_md": primary.get("skill_md", primary.get("location", "")),
                "action": f"Primary: handle main request: {query}",
                "input": "user_query",
                "output": f"{primary['name']}.output",
                "role": "primary",
            }
        ]

        for i, skill in enumerate(support):
            steps.append({
                "order": 2,
                "skill": skill["name"],
                "skill_md": skill.get("skill_md", skill.get("location", "")),
                "action": f"Support: provide {', '.join(skill.get('capabilities', []))} data if needed",
                "input": "user_query",
                "output": f"{skill['name']}.output",
                "role": "support",
            })

        return {
            "pattern": "primary_support",
            "description": f"Primary: '{primary['name']}'. Support: {', '.join(s['name'] for s in support)}.",
            "steps": steps,
            "data_flow": f"user_query -> {primary['name']} (primary) + support skills as needed -> result",
        }

    return {"pattern": "unknown", "steps": [], "data_flow": ""}


# ── CLI Entry Point ────────────────────────────────────────────────────────

def main():
    args = sys.argv[1:]
    skill_names = []
    query = ""
    match_result = None

    i = 0
    while i < len(args):
        if args[i] == "--skills" and i + 1 < len(args):
            skill_names = [s.strip() for s in args[i + 1].split(",")]
            i += 2
        elif args[i] == "--query" and i + 1 < len(args):
            query = args[i + 1]
            i += 2
        elif args[i] == "--match-result" and i + 1 < len(args):
            match_result = json.loads(args[i + 1])
            i += 2
        else:
            query = args[i]
            i += 1

    skills = []
    if match_result:
        skills = match_result.get("skills", [])
    elif skill_names:
        registry = load_registry()
        for name in skill_names:
            if name in registry:
                skill_data = registry[name]
                skill_data["score"] = 10  # default score
                skills.append(skill_data)

    if not skills:
        print(json.dumps({
            "error": "No skills provided",
            "usage": 'python orchestrate.py --skills skill1,skill2 --query "your query"'
        }, indent=2))
        sys.exit(1)

    query_clean = sanitize_string(query)
    if not query_clean:
        print(json.dumps({
            "error": "No valid query provided after sanitization",
            "usage": 'python orchestrate.py --skills skill1,skill2 --query "your query"'
        }, indent=2))
        sys.exit(1)

    # CRITICAL FIX: Explicitly sort skills descending by score to guarantee primary-support allocation integrity
    skills.sort(key=lambda x: x.get("score", 0), reverse=True)

    # Classify and generate plan
    pattern = classify_pattern(skills, query_clean)
    plan = generate_plan(skills, query_clean, pattern)
    plan["query"] = query_clean
    plan["skill_count"] = len(skills)

    # Add instructions for Claude/OpenCode orchestrator loop
    plan["instructions"] = []
    for step in plan.get("steps", []):
        skill_md = step.get("skill_md", "")
        if skill_md:
            plan["instructions"].append(
                f"Step {step['order']}: Read {skill_md} and follow its workflow for: {step['action']}"
            )

    print(json.dumps(plan, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
