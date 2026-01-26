# interview_core/models.py

from django.db import models

# Existing Model (Aapke purane code ke anusaar)
class Question(models.Model):
    question_text = models.CharField(max_length=200)
    answer_text = models.TextField()
    domain = models.CharField(max_length=50)

    def __str__(self):
        return self.question_text

# ✅ Naya Model: File Uploads ko track aur save karne ke liye
class UploadedFile(models.Model):
    # FileField Django ko batata hai ki yeh file hai aur MEDIA_ROOT mein save hogi
    file = models.FileField(upload_to='resumes/') 
    
    # Optional: File kab upload hui
    uploaded_at = models.DateTimeField(auto_now_add=True) 

    def __str__(self):
        return self.file.name