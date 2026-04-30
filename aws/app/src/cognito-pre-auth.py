import boto3

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')
    
    print(event)
    
    if event['request']['validationData'] == None:
        return event
    
    user_pool_id = event['userPoolId']
    username = event['userName']
    

    
    tenant_attribute_name = 'custom:active_tenant'
    tenant_attribute_value = event['request']['validationData']['tenant_id']
    
    role_attribute_name = 'custom:role'
    role_attribute_value = event['request']['validationData']['role']
    
    tenant_user_id_attribute_name = 'custom:tenant_user_id'
    tenant_user_id_attribute_value = event['request']['validationData'].get('tenant_user_id', '')
    
    if tenant_attribute_value == '' or role_attribute_value == '':
        return event
    
    try:
        # Update the user attribute
        user_attributes = [
            {
                'Name': tenant_attribute_name,
                'Value': tenant_attribute_value
            },
            {
                'Name': role_attribute_name,
                'Value': role_attribute_value
            }
        ]
        
        if tenant_user_id_attribute_value:
            user_attributes.append({
                'Name': tenant_user_id_attribute_name,
                'Value': tenant_user_id_attribute_value
            })
        
        response = client.admin_update_user_attributes(
            UserPoolId=user_pool_id,
            Username=username,
            UserAttributes=user_attributes
        )
        print(f"Attributes updated successfully for user {username}.")
    except client.exceptions.ClientError as error:
        print(f"Error updating user attribute: {error}")
        raise error
    
    # Continue the authentication process
    return event