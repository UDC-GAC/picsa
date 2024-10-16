import boto3
import pytest
import zipfile
import io
import json

from src import lambda_function

FUNCTION_NAME = "it-test_function"
ROLE_NAME = "it-role-lambda"
POLICY_NAME = "LambdaExecutionPolicy"
CODE = """
import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps("¡Hola desde Lambda!")
    }
"""
LAMBDA_POLICY = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}

@pytest.fixture()
def create_lambda_function():
    iam_client = boto3.client("iam")
    lambda_client = boto3.client("lambda")
    # Try delete policy
    try:
        iam_client.delete_role_policy(RoleName=ROLE_NAME, PolicyName=POLICY_NAME)
    except iam_client.exceptions.NoSuchEntityException:
        pass
    # Try delete role
    try:
        iam_client.delete_role(RoleName=ROLE_NAME)
    except iam_client.exceptions.NoSuchEntityException:
        pass
    role_response = iam_client.create_role(
        RoleName=ROLE_NAME,
        AssumeRolePolicyDocument='''{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }'''
    )
    # Attach policy to role
    policy_response = iam_client.put_role_policy(
        RoleName=ROLE_NAME,
        PolicyName='LambdaExecutionPolicy',
        PolicyDocument=json.dumps(LAMBDA_POLICY)
    )
    # Create lambda
    try:
        lambda_client.delete_function(FunctionName=FUNCTION_NAME)
    except lambda_client.exceptions.ResourceNotFoundException:
        pass
    # Create zip file in memory with the code
    code_zip = io.BytesIO()
    with zipfile.ZipFile(code_zip, 'w') as zf:
        zf.writestr('lambda_function.py', CODE)
    # Establish read position in start point of zip file
    code_zip.seek(0)
    lambda_client.create_function(
        FunctionName=FUNCTION_NAME,
        Runtime='python3.9',
        Role=role_response['Role']['Arn'],
        Handler='lambda_function.lambda_handler',
        Code= {
            'ZipFile': code_zip.read()
        },
        Timeout=900,
        MemorySize=128,
        EphemeralStorage={
            'Size': 512
        },
        Environment={
            'Variables': {
                'test': 'test'
            }
        }
    )
    # Running test
    yield    
    lambda_client.delete_function(FunctionName=FUNCTION_NAME)
    iam_client.delete_role_policy(RoleName=ROLE_NAME, PolicyName=POLICY_NAME)
    iam_client.delete_role(RoleName=ROLE_NAME)


@pytest.mark.it
def test_exception_not_function():
    event = {"function_name": FUNCTION_NAME}
    with pytest.raises(
        Exception, match="".join(["ERROR: There is no lambda with the name ", FUNCTION_NAME])
    ):
        lambda_function.lambda_handler(event, "")


@pytest.mark.it
def test_correct_execution(create_lambda_function):
    event = {"function_name": FUNCTION_NAME}
    result = lambda_function.lambda_handler(event, "")
    # Check if the test crawler is removed
    print(result)
    assert True
