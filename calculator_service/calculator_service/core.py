"""Core calculator logic kept simple and pure for easy unit testing."""
from typing import Union
from .errors import CalculatorError

Number = Union[int, float]


def add(a: Number, b: Number) -> Number:
    return a + b


def subtract(a: Number, b: Number) -> Number:
    return a - b


def multiply(a: Number, b: Number) -> Number:
    return a * b


def divide(a: Number, b: Number) -> Number:
    if b == 0:
        raise CalculatorError("division_by_zero", "Cannot divide by zero")
    return a / b
