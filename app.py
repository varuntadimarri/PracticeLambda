import logging
import boto3
from io import BytesIO
from PIL import Image
import os
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def list_objects(s3_client, bucket):
    try:
        response = s3_client.list_objects_v2(Bucket=bucket)
        if 'Contents' not in response:
            logger.info(f"No objects found in bucket: {bucket}")
            return []
        keys = [obj['Key'] for obj in response['Contents']]
        logger.info(f"Objects found in bucket {bucket}: {keys}")
        return keys
    except s3_client.exceptions.ClientError as e:
        logger.error(f"Error listing objects in bucket {bucket}: {str(e)}")
        raise e

def lambda_handler(event, context):
    try:
        logger.info(f"received event")
        logger.info(json.dumps(event, indent=2))
        
        if 'Records' not in event or not isinstance(event['Records'], list) or not event['Records']:
            raise KeyError("event doesnt contain 'Records' key or its not a lis or empty")
            
            
        s3_client = boto3.client('s3')
        bucket_objects = list_objects(s3_client, 'varun-practice-source-bucket2')

        for sqs_message in event['Records']:
            logger.info("SQS msg")
            logger.info(json.dumps(sqs_message, indent=2))
            
            if 'body' not in sqs_message:
                raise KeyError("SQS msg doesnot contain 'body' key")
            try:
                sns_message = json.loads(sqs_message['body'])
            except json.JSONDecodeError as e:
                raise ValueError(f"Failed to decode SNS msg body: {str(e)}")
                
            logger.info("SNS msg type: {}".format(type(sns_message)))
            logger.info(json.dumps(sns_message, indent=2))
            
            if 'Message' not in sns_message:
                raise KeyError("SNS message does not contain 'Message' key")
            
            try:
                s3_event = json.loads(sns_message['Message'])
            except json.JSONDecodeError as e:
                raise ValueError(f"failed to decode s3 event message: {str(e)}")
            
            logger.info("S3 event type: {}".format(type(s3_event)))
            logger.info(json.dumps(s3_event, indent=2))

            
            if 'Records' not in s3_event or not isinstance(s3_event['Records'], list) or not s3_event['Records']:
                raise KeyError("event doesnt contains 'Records' key or its empty")
            
            
            
            for record in s3_event['Records']:
                
                logger.info("S3 record")
                logger.info(json.dumps(record, indent=2))
            
                
                if 's3' not in record or 'bucket' not in record['s3'] or 'name' not in record['s3']['bucket'] or 'object' not in record['s3'] or 'key' not in record['s3']['object']:
                    raise KeyError("event structure is not expected")
                
                bucket = record["s3"]["bucket"]["name"]
                key = record["s3"]["object"]["key"]
                
                logger.info(f"Attempting to access bucket: {bucket}, key: {key}")
                
                logger.info(f"bucket: {bucket}, key: {key}")
                if key not in bucket_objects:
                    possible_keys = [f"{key[:-4]}.jpeg", f"{key[:-4]}.jpg", f"{key[-4]}.png"]
                    corrected_key = next((k for k in possible_keys if k in bucket_objects), None)
                    if corrected_key:
                        logger.info(f"Correcting key from {key} to {corrected_key}")
                        key = corrected_key
                    else:
                        raise ValueError(f"No objects found with key: {key}")
                        
                thumbnail_bucket = "varun-practice-target-bucket1"
                thumbnail_name, thumbnail_ext = os.path.splitext(key)
                thumbnail_key = f"{thumbnail_name}_thumbnail{thumbnail_ext}"
        
                logger.info(f"Bucket name: {bucket}, file name: {key}, Thumbnail Bucket name: {thumbnail_bucket}, file name: {thumbnail_key}")
                
                # Load and open image from S3
                try:
                    file_byte_string = s3_client.get_object(Bucket=bucket, Key=key)['Body'].read()
                    logger.info(f"successfully accessed object: {key} in bucket {bucket}")
            
                except s3_client.exceptions.NoSuchKey as e:
                    logger.error(f"the object with key {key} doesnot exist in bucket {bucket}")
                    raise e
                except s3_client.exceptions.ClientError as e:
                    error_code = e.response['Error']['Code']
                    if error_code == '403':
                        logger.error(f"Access to the object with key {key} in bucket {bucket} is denied")
                    else:
                        logger.error(f"unexpected error: {e}")
                    raise e
                except boto3.exceptions.S3UploadFailedError as e:
                    logger.error(f"failed to get the object {key} from bucket {bucket}: {str(e)}")
                    raise e
                
                logger.info(f"uploaded the {thumbnail_key} to {thumbnail_bucket}")
                
                img = Image.open(BytesIO(file_byte_string))
                logger.info(f"Size before compression: {img.size}")

                # Generate thumbnail
                img.thumbnail((500,500), Image.ANTIALIAS)
                logger.info(f"Size after compression: {img.size}")

                # Dump and save image to S3 
                buffer = BytesIO()
                img.save(buffer, "JPEG")
                buffer.seek(0)
                
                try:
                    sent_data = s3_client.put_object(Bucket=thumbnail_bucket, Key=thumbnail_key, Body=buffer)
                except boto3.exceptions.S3UploadFailedError as e:
                    logger.error(f"Failed to upload  image {thumbnail_key} to bucket {thumbnail_bucket}: {str(e)}")
                    raise e
                except s3_client.exceptions.ClientError as e:
                    logger.error(f"Failed to upload image {thumbnail_key} to bucket {thumbnail_bucket}: {str(e)}")
                    raise e
                    
                if sent_data['ResponseMetadata']['HTTPStatusCode'] != 200:
                    raise Exception('Failed to the upload image {} to bucket {}'.format(key, bucket))

        return event
    
    except KeyError as e:
        logger.error(f"KeyError: {str(e)}. Event's structure:")
        logger.error(json.dumps(event, indent=2))
        raise e
        
    except Exception as e:
        logger.error(f"error processing image {key} from bucket {bucket}: {str(e)}")
        raise