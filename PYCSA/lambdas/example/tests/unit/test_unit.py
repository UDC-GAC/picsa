import datetime
import os

import boto3
import pytest
from botocore.stub import Stubber

from src import lambda_function


FUNCTION_NAME = "test_function"
DATA = {
    "FunctionArn": "arn:aws:lambda:eu-west-1:127454711828:function:"+FUNCTION_NAME,
    "Handler": "lambda_function.lambda_handler",
    "Runtime": "python3.10",
    "Role": "arn:aws:iam::127454711828:role/test-role",
    "CodeSize": 1216,
    "Timeout": 900,
    "MemorySize": 128,
    "LastModified": datetime.datetime.today().strftime('%Y-%m-%dT%H:%M:%S.%f'),
    "EphemeralStorage": {"Size": 512},
    "Environment": {"Variables": {}}
}


@pytest.fixture(autouse=True)
def aws_credentials():
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"


@pytest.fixture()
def mock_not_exist_lambda(monkeypatch):
    """
    Boto3 mock for not exist lambda function
    """

    def mock_get_boto3_client(*args, **kwargs):
        client = boto3.client(*args, **kwargs)
        stubber = Stubber(client)
        if (len(args) > 0 and args[0] == "lambda") or (
            "service_name" in kwargs and kwargs["service_name"] == "lambda"
        ):
            stubber.add_client_error(
                "get_function_configuration", "ResourceNotFoundException", "Function not found: arn:aws:lambda:eu-west-1:127454711828:function:"+FUNCTION_NAME
            )
        stubber.activate()
        return client

    monkeypatch.setattr(lambda_function, "get_boto3_client", mock_get_boto3_client)


@pytest.fixture()
def mock_correct_execution(monkeypatch):
    """
    Boto3 mock correct function execution
    """
    def mock_get_boto3_client(*args, **kwargs):
        client = boto3.client(*args, **kwargs)
        stubber = Stubber(client)
        if (len(args) > 0 and args[0] == "lambda") or (
            "service_name" in kwargs and kwargs["service_name"] == "lambda"
        ):
            stubber.add_response("get_function_configuration", DATA, {"FunctionName": FUNCTION_NAME})
        stubber.activate()
        return client

    monkeypatch.setattr(lambda_function, "get_boto3_client", mock_get_boto3_client)


@pytest.mark.ut
def test_exception_function_name_missing():
    with pytest.raises(Exception, match="ERROR: Not 'function_name' key in event JSON"):
        lambda_function.lambda_handler({}, "")


@pytest.mark.ut
def test_exception_not_function(mock_not_exist_lambda):
    event = {"function_name": FUNCTION_NAME}
    with pytest.raises(
        Exception, match="".join(["ERROR: There is no lambda with the name ", FUNCTION_NAME])
    ):
        lambda_function.lambda_handler(event, "")

@pytest.mark.ut
def test_correct_execution(mock_correct_execution):
    event = {"function_name": FUNCTION_NAME}
    result = lambda_function.lambda_handler(event, "")
    assert result == DATA
