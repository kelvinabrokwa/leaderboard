package biz.kelvin.leaderboard

import com.google.cloud.secretmanager.v1.AccessSecretVersionRequest
import com.google.cloud.secretmanager.v1.AccessSecretVersionResponse
import com.google.cloud.secretmanager.v1.SecretManagerServiceClient

fun getGcpDbPassword() : String {
    SecretManagerServiceClient.create().use { client ->
        val accessRequest = AccessSecretVersionRequest.newBuilder()
                .setName(GCP.SECRET_DATABASE_PASSWORD_NAME)
                .build()
        val response: AccessSecretVersionResponse = client.accessSecretVersion(accessRequest)
        return response.payload.data.toStringUtf8()
    }
}