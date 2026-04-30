import { CognitoIdentityProviderClient, AdminUpdateUserAttributesCommand } from "@aws-sdk/client-cognito-identity-provider";

const client = new CognitoIdentityProviderClient({});

export const handler = async (event) => {
    console.log(JSON.stringify(event, null, 2));

    const validationData = event.request.validationData;

    // check if validation data exist
    if (!validationData) {
        return event;
    }

    const userPoolId = event.userPoolId;
    const username = event.userName;

    const tenantAttributeValue = validationData.tenant_id;
    const roleAttributeValue = validationData.role;
    const tenantUserIdAttributeValue = validationData.tenant_user_id || '';

    // check teh field
    if (!tenantAttributeValue || !roleAttributeValue) {
        return event;
    }

    try {
        const userAttributes = [
            {
                Name: 'custom:active_tenant',
                Value: tenantAttributeValue
            },
            {
                Name: 'custom:role',
                Value: roleAttributeValue
            }
        ];

        // add tenant_user_id, if it exist
        if (tenantUserIdAttributeValue) {
            userAttributes.push({
                Name: 'custom:tenant_user_id',
                Value: tenantUserIdAttributeValue
            });
        }

        const command = new AdminUpdateUserAttributesCommand({
            UserPoolId: userPoolId,
            Username: username,
            UserAttributes: userAttributes
        });

        await client.send(command);
        console.log(`Attributes updated successfully for user ${username}.`);

    } catch (error) {
        console.error(`Error updating user attribute: ${error.message}`);
        throw error;
    }

    // continue autentification
    return event;
};