import weaviate
import weaviate.classes as k8s
import os
import requests
import json

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
    client.collections.delete(name="Question") # clean slate
    
    questions = client.collections.create(
        name="Question",
        vectorizer_config=k8s.config.Configure.Vectorizer.text2vec_openai(), # Set the vectorizer to "text2vec-openai" to use the OpenAI API for vector-related operations
        generative_config=k8s.config.Configure.Generative.openai() # Set the generative module to "generative-openai" to use the OpenAI API for RAG
        )
        
    resp = requests.get('https://raw.githubusercontent.com/weaviate-tutorials/quickstart/main/data/jeopardy_tiny.json')
    data = json.loads(resp.text)  # Load data

    question_objs = list()
    for i, d in enumerate(data):
        question_objs.append({
            "answer": d["Answer"],
            "question": d["Question"],
            "category": d["Category"],
        })
    
    questions = client.collections.get("Question") # grab collection
    questions.data.insert_many(question_objs) # insert data into the collection
    
    print("Collections created")

finally:
    client.close()

