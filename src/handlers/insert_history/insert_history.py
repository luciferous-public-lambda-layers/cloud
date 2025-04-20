from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import TYPE_CHECKING

from aws_lambda_powertools.utilities.data_classes import event_source
from aws_lambda_powertools.utilities.data_classes.dynamo_db_stream_event import (
    DynamoDBRecord,
    DynamoDBRecordEventName,
    DynamoDBStreamEvent,
)
from zoneinfo import ZoneInfo

from utils.aws import create_resource
from utils.dataclasses import load_environments
from utils.logger import create_logger, logging_function, logging_handler

if TYPE_CHECKING:
    from mypy_boto3_dynamodb.service_resource import DynamoDBServiceResource, Table


@dataclass(frozen=True)
class EnvironmentVariables:
    table_name: str


logger = create_logger(__name__)
jst = ZoneInfo("Asia/Tokyo")
raw_resource_ddb: DynamoDBServiceResource = create_resource("dynamodb")


@logging_handler(logger)
@event_source(data_class=DynamoDBStreamEvent)
def handler(event: DynamoDBStreamEvent, context):
    main(event=event, resource_ddb=raw_resource_ddb)


@logging_function(logger)
def main(*, event: DynamoDBStreamEvent, resource_ddb: DynamoDBServiceResource):
    env = load_environments(class_dataclass=EnvironmentVariables)
    table: Table = resource_ddb.Table(env.table_name)
    for record in event.records:
        process_record(record=record, table=table)


@logging_function(logger)
def process_record(*, record: DynamoDBRecord, table: Table):
    logger.debug("event_name", data={"event_name": record.event_name.name})
    if record.event_name == DynamoDBRecordEventName.INSERT:
        item = create_item_for_insert(record=record)
    elif record.event_name == DynamoDBRecordEventName.MODIFY:
        item = create_item_for_modify(record=record)
    elif record.event_name == DynamoDBRecordEventName.REMOVE:
        item = create_item_for_remove(record=record)
    else:
        raise RuntimeError(f"想定外のeventName ({record.event_name})")
    logger.debug("item", data={"item": item})
    table.put_item(Item=item)


@logging_function(logger)
def parse_approximate_creation_date_time(*, record: DynamoDBRecord) -> str:
    unixtime = record.dynamodb.approximate_creation_date_time
    return datetime.fromtimestamp(unixtime, jst).isoformat()


@logging_function(logger)
def parse_event_name(*, record: DynamoDBRecord) -> str:
    return record.event_name.name


@logging_function(logger)
def parse_identifier(*, record: DynamoDBRecord) -> str:
    return record.dynamodb.keys["identifier"]


@logging_function(logger)
def create_item_for_insert(*, record: DynamoDBRecord) -> dict:
    return {
        "identifier": parse_identifier(record=record),
        "updatedAt": datetime.now(jst).isoformat(),
        "approximateCreationDateTime": parse_approximate_creation_date_time(
            record=record
        ),
        "eventName": parse_event_name(record=record),
        "newImage": record.dynamodb.new_image,
    }


@logging_function(logger)
def create_item_for_modify(*, record: DynamoDBRecord) -> dict:
    return {
        "identifier": parse_identifier(record=record),
        "updatedAt": datetime.now(jst).isoformat(),
        "approximateCreationDateTime": parse_approximate_creation_date_time(
            record=record
        ),
        "eventName": parse_event_name(record=record),
        "newImage": record.dynamodb.new_image,
        "oldImage": record.dynamodb.old_image,
    }


@logging_function(logger)
def create_item_for_remove(*, record: DynamoDBRecord) -> dict:
    return {
        "identifier": parse_identifier(record=record),
        "updatedAt": datetime.now(jst).isoformat(),
        "approximateCreationDateTime": parse_approximate_creation_date_time(
            record=record
        ),
        "eventName": parse_event_name(record=record),
        "oldImage": record.dynamodb.old_image,
    }
