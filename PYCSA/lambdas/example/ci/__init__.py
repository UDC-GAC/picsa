"""Auxiliar module to run CI commands."""
import subprocess as sp
from pathlib import Path
from shutil import which

pytest_command_ut = "pytest --cov=src --cov-report term:skip-covered --cov-report xml --cov-report html --durations=0 --cov-fail-under=90"
pytest_command_it = "pytest"


def test():
    """Run project unit tests."""
    print("====| TEST: RUNNING PYTEST UTs")
    sp.check_call(
        f"{pytest_command_ut} -m ut",
        shell=True,
    )


def test_it():
    """Run project integration tests."""
    print("====| TEST: RUNNING PYTEST ITs")
    sp.check_call(
        f"{pytest_command_it} -m it",
        shell=True,
    )


def lint():
    """Run linters."""
    if which("black"):
        _black_lint()
    else:
        _pylint()


def format_code():
    """Format code."""
    print("====| FORMAT: FORMAT PROJECT CODE")
    print("====| FORMAT: RUNNING ISORT")
    # No need to check if installed, it is included as dep of Pylint
    sp.check_call("isort .", shell=True)

    print("====| FORMAT: RUNNING BLACK")
    if which("black"):
        sp.check_call("black .", shell=True)
    else:
        _missing_command("black")


def _black_lint():
    """Run Black as linter."""
    print("====| LINT: RUNNING BLACK")
    if which("black"):
        sp.check_call("black --check .", shell=True)
    else:
        _missing_command("black")


def _pylint():
    """Run Pylint as linter."""
    print("====| LINT: RUNNING PYLINT")
    if which("pylint"):
        sp.check_call("pylint ./src/ ./tests/ ./ci/", shell=True)
    else:
        _missing_command("pylint")


def verify():
    """Run all the verification steps."""
    print("====| VERIFY: RUN PROJECT VERIFICATION")
    lint()
    test()


def package():
    """Package src code in zip"""
    print("====| PACKAGE: CREATE ZIP ON DIST")
    sp.check_call("cd src && zip -r artifact.zip *", shell=True)
    sp.check_call("mkdir -p dist", shell=True)
    sp.check_call("mv src/artifact.zip dist/", shell=True)


def _missing_command(command):
    """Print error with command"""
    print("====| ERROR: WRONG COMMAND: " + command)
