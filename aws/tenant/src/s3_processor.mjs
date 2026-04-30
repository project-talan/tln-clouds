export const handler = async (event) => {
    // URL вашого сервісу в EKS (Internal Load Balancer або ClusterIP з VPC Lattice)
    const EKS_SERVICE_URL = "http://cluster.local";

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

        console.log(`Надсилання події до EKS: ${key}`);

        try {
            const response = await fetch(EKS_SERVICE_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-api-key': process.env.SERVICE_API_KEY || '' // Якщо потрібна авторизація
                },
                body: JSON.stringify(payload),
                // Таймаут для запиту (важливо, щоб вкластися в 5-10 секунд)
                signal: AbortSignal.timeout(5000)
            });

            if (!response.ok) {
                throw new Error(`EKS Service responded with ${response.status}`);
            }

            const result = await response.json();
            console.log(`Подію успішно оброблено сервісом в EKS:`, result);

        } catch (error) {
            console.error(`Помилка при надсиланні до EKS (${key}):`, error.message);
            // Якщо це критично — викидаємо помилку, щоб S3 спробував пізніше (Retry)
            throw error;
        }
    }

    return { status: 'success' };
};

