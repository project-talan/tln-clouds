export const handler = async (event) => {
    // URL of your EKS loadbalancer
    const EKS_SERVICE_URL = process.env.EKS_SERVICE_URL;

    for (const record of event.Records) {
        const bucket = record.s3.bucket.name;
        const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));

        const payload = {
            source: "aws.s3",
            bucket: bucket,
            file_key: key,
            event_time: record.eventTime,
            region: record.awsRegion
        };

        console.log(`Send event to EKS: ${key}`);

        try {
            const response = await fetch(EKS_SERVICE_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-api-key': process.env.SERVICE_API_KEY || '' // autorization
                },
                body: JSON.stringify(payload),
                // timeout for request (defaoult 5-10 second)
                signal: AbortSignal.timeout(5000)
            });

            if (!response.ok) {
                throw new Error(`EKS Service responded with ${response.status}`);
            }

            const result = await response.json();
            console.log(`Event was received by EKS:`, result);

        } catch (error) {
            console.error(`Error by sending to EKS (${key}):`, error.message);
            // error for retry (Retry)
            throw error;
        }
    }

    return { status: 'success' };
};

