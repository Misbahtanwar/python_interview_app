from rest_framework.response import Response
from rest_framework.views import APIView
from google import genai
from google.genai import types 
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator 

# Standard Python Imports
import os
import json

# App-specific Imports
from .models import UploadedFile 
from docx import Document 

# --- Gemini Client Setup ---
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY") 
if not GEMINI_API_KEY:
    GEMINI_API_KEY = settings.GEMINI_API_KEY 

try:
    client = genai.Client(api_key=GEMINI_API_KEY)
except Exception as e:
    print(f"Gemini Client Init Error: {e}") 

global chat_session
chat_session = None

# 1. CHATBOTVIEW: (Brevity, Conflict Resolution, and Stable Memory Access)
@method_decorator(csrf_exempt, name='dispatch')
class ChatbotView(APIView):
    """Chatbot functionality with Memory (Chat History)."""
    def post(self, request):
        global chat_session 
        user_message = request.data.get('message', '').strip() 
        if not user_message:
            return Response({"error": "No message provided"}, status=400)
        
        # ✅ FINAL CONFLICT RESOLUTION PROMPT: AI ko friendly banaya
        SYSTEM_PROMPT = (
            "You are an expert Technical Interviewer focusing strictly on Python, Django, and Flutter. "
            "Your primary goal is to assess the user's technical profile based on the uploaded resume and guide their preparation. "
            "You MUST answer questions related to the 'Strengths' and 'Areas for Improvement' of the resume you have seen in the memory. "
            "Provide concise, interview-ready answers. Use bullet points for quick summaries whenever possible. "
            "You MUST maintain context of the conversation. If asked a non-technical question, gently redirect the user back to the technical topic."
        )

        try:
            # Token Limit added for brevity
            config = types.GenerateContentConfig(
                system_instruction=SYSTEM_PROMPT,
                max_output_tokens=300, 
            )
            
            if chat_session is None:
                chat_session = client.chats.create(
                    model='gemini-2.5-flash', 
                    config=config
                )
                print("New Chat Session Created!")
                
            response = chat_session.send_message(user_message)
            ai_answer = response.text
            return Response({"question": user_message, "answer": ai_answer})

        except Exception as e:
            print("Gemini API Error (with memory):", str(e))
            chat_session = None 
            return Response({"error": "AI response failed. Session reset."}, status=500)

# 2. RESUMEANALYSISVIEW: (File Saving + Analysis + MEMORY INJECTION FIX)
@method_decorator(csrf_exempt, name='dispatch') 
class ResumeAnalysisView(APIView):
    """Handles file upload and analysis via Gemini API and saves the file."""

    def post(self, request):
        global chat_session 

        try:
            client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))
        except Exception as e:
            return Response({"error": "Gemini Client initialization failed."}, status=500)

        uploaded_file = request.FILES.get('resume') 

        if not uploaded_file:
            return Response({"error": "No file uploaded."}, status=400)

        # FILE KO DATABASE AUR MEDIA FOLDER MEIN SAVE KAREIN
        uploaded_file_record = UploadedFile.objects.create(file=uploaded_file)
        
        # CRITICAL FIX: text_content ko yahan initialize kiya gaya hai
        text_content = ""
        
        # File processing logic
        if uploaded_file.name.endswith('.docx'):
            try:
                document = Document(uploaded_file_record.file) 
                for paragraph in document.paragraphs:
                    text_content += paragraph.text + '\n'
            except Exception as e:
                return Response({"error": f"Error processing DOCX file: {e}"}, status=500)
        
        elif uploaded_file.name.endswith('.pdf'):
            text_content = f"The user uploaded a PDF file named {uploaded_file.name}. Please assume the content is about the user's skills in Python, Django, and Flutter and provide a generic analysis."
        
        else:
            return Response({"error": "Unsupported file type. Only DOCX and PDF are accepted."}, status=400)

        # Gemini Analysis Prompt
        ANALYSIS_PROMPT = (
            "You are a professional Resume Analyzer for Python/Django Developers. "
            "Analyze the following resume text based on its skills, projects, and relevance to the Python/Django/Flutter stack. "
            "Provide the output in three clear sections: "
            "1. **Overall Score** (Out of 100), 2. **Strengths** (3 points), and 3. **Areas for Improvement** (3 actionable points). "
            f"\n\nRESUME TEXT:\n---\n{text_content}"
        )
        
        try:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=[ANALYSIS_PROMPT],
                config=types.GenerateContentConfig(temperature=0.2)
            )
            
            # MEMORY INJECTION FIX
            if chat_session is not None:
                chat_session.send_message(
                    f"NOTE TO SELF: The user's currently active resume content for reference is: {text_content}",
                )
            
            # Final response (with full text included for Flutter display)
            return Response({
                "message": "Analysis Complete!",
                "full_resume_text": text_content, 
                "analysis_result": response.text
            }, status=200)

        except Exception as e:
            # Clean up the file record if analysis fails
            uploaded_file_record.delete() 
            return Response({"error": f"AI analysis failed: {e}"}, status=500)