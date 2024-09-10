import weaviate
import weaviate.classes as k8s
import os
import requests

headers = {
    "X-OpenAI-Api-Key": os.getenv("OPENAI_APIKEY")
}

client = weaviate.connect_to_local(
    host="localhost",
    port=8080,
    grpc_port=50051,
    headers=headers
)

print(client.is_ready())

client.close()
