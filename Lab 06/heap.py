import weaviate
import weaviate.classes as k8s
import os
import numpy as np

headers = {
    "X-OpenAI-Api-Key": os.getenv("OPENAI_APIKEY")
}

client = weaviate.connect_to_local(
    host="localhost",
    port=8080,
    grpc_port=50051,
    headers=headers
)

client.collections.delete(name="Question") # clean slate

questions = client.collections.create(
        name="Question",
        vectorizer_config=k8s.config.Configure.Vectorizer.text2vec_openai(), # Set the vectorizer to "text2vec-openai" to use the OpenAI API for vector-related operations
        generative_config=k8s.config.Configure.Generative.openai() # Set the generative module to "generative-openai" to use the OpenAI API for RAG
        )

print('collection created')

# Simulate heap usage by creating 1000 objects with random vectors
with questions.batch.dynamic() as batch:
    for i in range (1000):
        batch.add_object(
        properties={"text": f"text for id {1}", "filter": "aaa"}
)

print('objects created')

client.close()
