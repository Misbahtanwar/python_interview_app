#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys
from dotenv import load_dotenv

# .env file load karo
load_dotenv()

# check karne ke liye print (Aap is line ko baad mein hata sakti hain)
print("API Key:", os.getenv("OPENAI_API_KEY"))

def main():
    """Run administrative tasks."""
    # ✅ SETTINGS MODULE KA CORRECT PATH
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'python_interview_app.settings')

    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()