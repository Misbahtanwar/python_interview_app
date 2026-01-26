from django.contrib import admin
from django.urls import path, include 
# ✅ ZAROORI IMPORTS for serving media files in development
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('interview_core.urls')), 
]

# ✅ FINAL FIX: MEDIA URLS ADD KIYA GAYA 
# Yeh code Django ko batata hai ki media files ko /media/ URL par serve karo.
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)