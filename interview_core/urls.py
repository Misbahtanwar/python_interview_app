# interview_core/urls.py (App-Level File)
from django.urls import path
# Views ko yahaan import karte hain
from .views import ChatbotView, ResumeAnalysisView 

urlpatterns = [
    # Main project file mein /api/ laga hua hai, isliye yahaan /chat/ lagayenge
    path('chat/', ChatbotView.as_view(), name='chat'),
    path('resume/analyze/', ResumeAnalysisView.as_view(), name='resume_analyze'), 
]