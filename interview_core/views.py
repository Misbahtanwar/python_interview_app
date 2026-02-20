from rest_framework.response import Response
from rest_framework.views import APIView
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator 
from groq import Groq  # <-- Gemini ki jagah Groq

# Standard Python Imports
import os
import json

# App-specific Imports
from .models import UploadedFile 
from docx import Document 

# --- Groq Client Setup ---
# Render par humne variable ka naam GROQ_API_KEY rakha hai
GROQ_API_KEY = os.environ.get("GROQ_API_KEY") 

try:
    client = Groq(api_key=GROQ_API_KEY)
except Exception as e:
    print(f"Groq Client Init Error: {e}") 

# Memory/Session handle karne ke liye simple list
global_chat_history = []

# 1. CHATBOTVIEW: (Interview Expert Logic)
@method_decorator(csrf_exempt, name='dispatch')
class ChatbotView(APIView):
    """Chatbot functionality with Groq AI."""
    def post(self, request):
        global global_chat_history
        user_message = request.data.get('message', '').strip() 
        if not user_message:
            return Response({"error": "No message provided"}, status=400)
        
        SYSTEM_PROMPT = (
            "You are an expert Technical Interviewer focusing strictly on Python, Django, and Flutter. "
            "Your goal is to assess the user's technical profile. Provide concise, interview-ready answers. "
            "Use bullet points for quick summaries whenever possible."
        )

        try:
            # History taiyar karna
            messages = [{"role": "system", "content": SYSTEM_PROMPT}]
            for msg in global_chat_history[-5:]: # Aakhri 5 baatein yaad rakhega
                messages.append(msg)
            messages.append({"role": "user", "content": user_message})

            # Groq API Call
            completion = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=messages,
                max_tokens=500,
                temperature=0.7
            )
            
            ai_answer = completion.choices[0].message.content
            
            # History update
            global_chat_history.append({"role": "user", "content": user_message})
            global_chat_history.append({"role": "assistant", "content": ai_answer})

            return Response({"question": user_message, "answer": ai_answer})

        except Exception as e:
            print("Groq API Error:", str(e))
            return Response({"error": "AI response failed. Please try again."}, status=500)
#class resume 
@method_decorator(csrf_exempt, name='dispatch') 
class ResumeAnalysisView(APIView):
    """Direct Analysis without Database Saving."""

    def post(self, request):
        try:
            uploaded_file = request.FILES.get('resume') 
            if not uploaded_file:
                return Response({"error": "No file uploaded."}, status=400)

            text_content = ""
            
            # Direct Processing (Bina save kiye)
            if uploaded_file.name.endswith('.docx'):
                document = Document(uploaded_file) # Direct file object use kiya
                for paragraph in document.paragraphs:
                    text_content += paragraph.text + '\n'
            elif uploaded_file.name.endswith('.pdf'):
                text_content = f"PDF File: {uploaded_file.name}. Analysis for Python/Django/Flutter stack."
            else:
                return Response({"error": "Unsupported file type."}, status=400)

            ANALYSIS_PROMPT = (
                "You are a professional Resume Analyzer for Python/Django Developers. "
                "Analyze the following resume text and provide: "
                "1. Overall Score (Out of 100), 2. Strengths, 3. Areas for Improvement. "
                f"\n\nRESUME TEXT:\n---\n{text_content}"
            )
            
            # Groq Call
            response = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[{"role": "user", "content": ANALYSIS_PROMPT}]
            )
            
            return Response({
                "message": "Analysis Complete!",
                "full_resume_text": text_content, 
                "analysis_result": response.choices[0].message.content
            }, status=200)

        except Exception as e:
            return Response({"error": f"AI analysis failed: {str(e)}"}, status=500)
