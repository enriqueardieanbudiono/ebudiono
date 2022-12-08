#!/bin/bash

LISTOFBUCKETS=$(aws s3api list-buckets --query='Buckets[*].Name')

# Use for loop to delete multiple buckets
for i in $LISTOFBUCKETS
do
    KEY=$(aws s3api list-objects --bucket raw-ebudi --output=text --query="Contents[*].Key")

    # Use for loop to delete multiple objects
    for j in $KEY
    do
        echo "Deleting object $j inside bucket $i"
        aws s3api delete-object \
            --bucket $i \
            --key $j
        
        echo "Object $j deleted"
    done

    echo "Deleting bucket $i"
    aws s3api delete-bucket \
        --bucket $i
done

echo "Buckets deletion complete"