#!/usr/bin/env python

import argparse
import logging
import os
import sys
from contextlib import redirect_stderr, redirect_stdout

from semantic_router import Route, RouteLayer
from semantic_router.encoders import HuggingFaceEncoder

logging.getLogger("semantic_router.utils.logger").setLevel(logging.WARNING)

VALID_MODES = {"fast", "capable", "code"}


ROUTES = [
    Route(
        name="code",
        utterances=[
            "review this shell command",
            "fix this python error",
            "explain this stack trace",
            "review this justfile",
            "check this yaml config",
            "debug this script",
            "review this code",
            "explain this command",
            "fix this bug",
            "review this config",
            "explain this error",
        ],
    ),
    Route(
        name="capable",
        utterances=[
            "compare these implementation options",
            "make a plan",
            "explain the tradeoffs",
            "think through the architecture",
            "summarise the pros and cons",
            "help me decide",
            "analyse this approach",
            "what is the best option",
            "reason through this",
            "evaluate this decision",
        ],
    ),
    Route(
        name="fast",
        utterances=[
            "summarise this briefly",
            "answer this question",
            "explain this simply",
            "give me a short answer",
            "what does this mean",
            "summarise this in three bullets",
            "rewrite this quickly",
            "make this clearer",
            "give me a quick summary",
        ],
    ),
]


def route_prompt(prompt: str) -> str:

    # Keep stdout/stderr clean so callers receive only the selected mode.
    # The semantic-router package logs RouteLayer initialisation noise on startup.
    with open(os.devnull, "w", encoding="utf-8") as devnull:
        with redirect_stdout(devnull), redirect_stderr(devnull):
            encoder = HuggingFaceEncoder()
            router = RouteLayer(encoder=encoder, routes=ROUTES)
            result = router(prompt)

    mode = getattr(result, "name", None)

    if mode not in VALID_MODES:
        return "fast"

    return mode


def main() -> int:
    parser = argparse.ArgumentParser(description="Route a prompt to an ai mode.")
    parser.add_argument("prompt", nargs="*", help="Prompt text to route")
    args = parser.parse_args()

    prompt = " ".join(args.prompt).strip()

    if not prompt:
        print("No prompt provided for semantic routing.", file=sys.stderr)
        return 2

    print(route_prompt(prompt))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
