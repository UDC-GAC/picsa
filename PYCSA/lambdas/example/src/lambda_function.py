import functools
import json
import logging
import os
import traceback
import uuid

import boto3

logger = logging.getLogger()
format = (
    '{"id": "'
    + str(uuid.uuid1())
    + '", "function": "%(funcName)s", "line": %(lineno)d, "level": "%(levelname)s", %(message)s }'
)
logger.handlers[0].setFormatter(logging.Formatter(format))
logger.setLevel(eval(os.environ["log_level"]))


def log(function_name, msg, in_args, out_args):
    """
    Function to abstract logs funtions
    :param function_name: Name of the logging function to call according to its log level.
    :param msg: Message of log.
    :param in_args: Dict with input parameters.
    :param out_args: Dict with output parameters
    :return:
    Return function to call.
    """
    function = getattr(logger, function_name.lower())
    try:
        in_args = json.dumps(in_args)
    except TypeError:
        in_args = '"' + str(in_args).replace('"', "'") + '"'
    try:
        out_args = json.dumps(out_args)
    except TypeError:
        out_args = '"' + str(out_args).replace('"', "'") + '"'
    msg = msg.replace('"', "'")
    return functools.partial(
        function,
        '"message": "%s", "input": %s, "output": %s',
        str(msg),
        in_args,
        out_args,
    )


def get_boto3_client(*args, **kwargs):
    """
    Function to create a boto3 client and needed to facilitate testing
    :param args: List of arguments to client.
    :param kwargs: Dict of arguments to client.
    :return:
    Returns client instance of service.
    """
    log("debug", "Start", {"args": args, "kwargs": kwargs}, {})()
    client = boto3.client(*args, **kwargs)
    log("debug", "Finish", {"args": args, "kwargs": kwargs}, {"client": client})()
    return client


def get_config_values(client, lambda_name):
    """
    Get important lambda config parameters
    :return:
    Returns dict with important config parameters.
    """
    log("debug", "Start", {"client": client, "lambda_name": lambda_name}, {})()
    data = {}
    try:
        result = client.get_function_configuration(FunctionName=lambda_name)
        data['FunctionArn'] = result['FunctionArn']
        data['Handler'] = result['Handler']
        data['Runtime'] = result['Runtime']
        data['Role'] = result['Role']
        data['CodeSize'] = result['CodeSize']
        data['Timeout'] = result['Timeout']
        data['MemorySize'] = result['MemorySize']
        data['LastModified'] = result['LastModified']
        data['EphemeralStorage'] = result['EphemeralStorage']
        data['Environment'] = result['Environment']
    except client.exceptions.ResourceNotFoundException:
        error = "ERROR: There is no lambda with the name " + lambda_name
        log("error", error, {"client": client, "lambda_name": lambda_name}, {})()
        raise Exception(error)
    log("debug", "Finish", {"client": client, "lambda_name": lambda_name}, {"data": data})()
    return data


def lambda_handler(event, context):
    """
    Gets the important lambda configuration parameters
    :param event: Have key function with the name of function.
    :param context: Not used.
    :return:
    Returns result with config parameters.
    """
    log("debug", "Start", {"event": event, "context": context}, {})()
    try:
        if "function_name" in event:
            lambda_client = get_boto3_client("lambda")
            lambda_name = event["function_name"]
            result = get_config_values(lambda_client, lambda_name)
        else:
            error = "ERROR: Not 'function_name' key in event JSON"
            log("error", error, {"event": event, "context": context}, {})()
            raise Exception(error)
    except Exception as e:
        log(
            "error",
            traceback.format_exc(),
            {"event": event, "context": context},
            {"ret_val": False},
        )()
        raise Exception(e)
    log("debug", "Finish", {"event": event, "context": context}, {"result": result})()
    return result

