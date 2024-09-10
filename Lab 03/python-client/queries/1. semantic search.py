import weaviate
import weaviate.classes as k8s
import os

headers = {
    "X-OpenAI-Api-Key": os.getenv("OPENAI_APIKEY")
}

api_key = "minikube-secret-key"

client = weaviate.connect_to_local(
    host="127.0.0.1",
    port=8080,
    grpc_port=50051,
    headers=headers,
    auth_credentials=k8s.init.Auth.api_key(api_key)
)

try:
    questions = client.collections.get("Question") # grab collection

    response = questions.query.near_text( # query collection
        query="biology",
        limit=2
    )

    print(response.objects[0].properties)  # Inspect the first object

finally:
    client.close()

