import logging

from semantic_router import Route, RouteLayer
from semantic_router.encoders import HuggingFaceEncoder

logging.getLogger("semantic_router.utils.logger").setLevel(logging.WARNING)

routes = [
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
        ],
    ),
]

encoder = HuggingFaceEncoder()
router = RouteLayer(encoder=encoder, routes=routes)

tests = [
    "Review this shell command",
    "Compare these implementation options",
    "Summarise this in three bullets",
]

for prompt in tests:
    result = router(prompt)
    print(f"{prompt} -> {result.name}")
