import streamlit as st
import pandas as pd
import pickle
import json
import random
from sklearn.metrics.pairwise import cosine_similarity

st.set_page_config(page_title="AI Assistant", page_icon="🤖")
st.header("💬 Intelligent Coding Assistant")

@st.cache_resource
def load_engine():
    try:
        df = pd.read_parquet('train_multilingual_clean.parquet', engine='pyarrow')
        with open('tfidf_vectorizer.pkl', 'rb') as f: vectorizer = pickle.load(f)
        with open('tfidf_matrix.pkl', 'rb') as f: matrix = pickle.load(f)
        with open('intent.json', 'r', encoding='utf-8') as f: intents = json.load(f)
        return df, vectorizer, matrix, intents
    except FileNotFoundError:
        return None, None, None, None

df, vectorizer, matrix, intents = load_engine()

def get_bot_response(user_query):
    user_query = user_query.lower().strip()

    for intent in intents['intents']:
        for pattern in intent['patterns']:
            if pattern.lower() in user_query:
                return random.choice(intent['responses']), "100%"

    query_vec = vectorizer.transform([user_query])
    similarity = cosine_similarity(query_vec, matrix)
    best_idx = similarity.argmax()
    score = similarity[0, best_idx]
    
    accuracy_percentage = f"{score * 100:.1f}%"
    
    if score < 0.3:
        return "عذراً، لست متأكداً من الإجابة. / I'm not sure, could you rephrase?", accuracy_percentage
    
    return df.iloc[best_idx]['output'], accuracy_percentage

if "messages" not in st.session_state:
    st.session_state.messages = [{"role": "assistant", "content": "Welcome! I'm here to help. / أهلاً بك! أنا هنا للمساعدة."}]

for msg in st.session_state.messages:
    icon = "🤖" if msg["role"] == "assistant" else "👤"
    with st.chat_message(msg["role"], avatar=icon):
        st.markdown(msg["content"])

if prompt := st.chat_input("Ask me anything..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user", avatar="👤"):
        st.markdown(prompt)

    with st.chat_message("assistant", avatar="🤖"):
        answer, acc_score = get_bot_response(prompt)
        full_response = f"{answer}\n\n*Accuracy: {acc_score}*"
        st.markdown(full_response)
        st.session_state.messages.append({"role": "assistant", "content": full_response})