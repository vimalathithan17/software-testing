class CalculatorError(Exception):
    """Simple domain exception for the calculator service.

    Attributes:
        code: a short machine-friendly error code
        message: human-friendly message
    """

    def __init__(self, code: str, message: str):
        self.code = code
        self.message = message
        super().__init__(f"{code}: {message}")
