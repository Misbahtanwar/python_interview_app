from rest_framework.response import Response
from rest_framework.views import APIView
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator 
from groq import Groq

# Standard Python Imports
import os
import json

# App-specific Imports
from .models import UploadedFile 
from docx import Document 

# --- Groq Client Setup ---
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
            "You are a Professional AI Career Mentor. "
            "Your tone must be polite, encouraging, and professional. "
            "Do NOT use slang or very casual language. "
            "Provide constructive feedback. "
            "Speak in clear English (or a very professional Hinglish only if the user asks). "
            "Strictly avoid symbols like # and **. Use simple bullet points (-) for lists."
        )

        try:
            messages = [{"role": "system", "content": SYSTEM_PROMPT}]
            for msg in global_chat_history[-5:]:
                messages.append(msg)
            messages.append({"role": "user", "content": user_message})
            
            completion = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=messages,
                max_tokens=500,
                temperature=0.7
            )
            
            ai_answer = completion.choices[0].message.content
            
            global_chat_history.append({"role": "user", "content": user_message})
            global_chat_history.append({"role": "assistant", "content": ai_answer})

            return Response({"question": user_message, "answer": ai_answer})

        except Exception as e:
            print("Groq API Error:", str(e))
            return Response({"error": "AI response failed. Please try again."}, status=500)

# 2. RESUME ANALYSIS VIEW
@method_decorator(csrf_exempt, name='dispatch') 
class ResumeAnalysisView(APIView):
    """Direct Analysis without Database Saving (PDF & DOCX Supported)."""

    def post(self, request):
        try:
            uploaded_file = request.FILES.get('resume') 
            if not uploaded_file:
                return Response({"error": "No file uploaded."}, status=400)

            text_content = ""
            
            if uploaded_file.name.endswith('.docx'):
                try:
                    document = Document(uploaded_file)
                    for paragraph in document.paragraphs:
                        text_content += paragraph.text + '\n'
                except Exception as e:
                    return Response({"error": f"DOCX Read Error: {str(e)}"}, status=500)

            elif uploaded_file.name.endswith('.pdf'):
                try:
                    import PyPDF2
                    pdf_reader = PyPDF2.PdfReader(uploaded_file)
                    for page in pdf_reader.pages:
                        extracted_text = page.extract_text()
                        if extracted_text:
                            text_content += extracted_text + "\n"
                    
                    if not text_content.strip():
                        text_content = "Note: The PDF seems to be an image or empty."
                except Exception as e:
                    return Response({"error": f"PDF Read Error: {str(e)}"}, status=500)
            
            else:
                return Response({"error": "Unsupported file type."}, status=400)

            ANALYSIS_PROMPT = (
                "Analyze this resume professionally. Provide: 1. Overall Score (out of 100), "
                "2. Key Strengths, 3. Critical Areas for Improvement. "
                "IMPORTANT: Use ONLY plain text. No symbols like # or **. Use simple dashes (-) for points. "
                f"\n\nRESUME TEXT:\n---\n{text_content}"
            )
            
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
            print(f"Server Error: {str(e)}")
            return Response({"error": f"AI analysis failed: {str(e)}"}, status=500)
