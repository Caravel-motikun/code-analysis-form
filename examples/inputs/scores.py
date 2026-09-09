"""Small fictional module used only by the HTML example."""
MAX_SCORES = 64

def summarize_scores(values: list[int]) -> dict:
    if not 1 <= len(values) <= MAX_SCORES:
        raise ValueError("expected 1..64 scores")
    if any(type(v) is not int or not 0 <= v <= 100 for v in values):
        raise ValueError("scores must be integers in 0..100")
    return {
        "count": len(values),
        "min": min(values),
        "max": max(values),
        "mean": sum(values) / len(values),
    }
