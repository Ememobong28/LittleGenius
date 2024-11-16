from flask import Flask, request, jsonify
from firebase_admin import firestore
from openai import OpenAI
app = Flask(__name__)
import json

from firebase_admin import credentials, firestore

import os
import json
from firebase_admin import credentials, initialize_app

# Load the service account key from the environment variable
service_account_key = os.getenv("FIREBASE_SERVICE_ACCOUNT")
if not service_account_key:
    raise ValueError("FIREBASE_SERVICE_ACCOUNT environment variable is not set.")

# Parse the JSON string into a dictionary
service_account_info = json.loads(service_account_key)

# Initialize Firebase Admin SDK
cred = credentials.Certificate(service_account_info)
initialize_app(cred)

# Initialize Firestore
db = firestore.client()

# Initialize Firestore (ensure Firebase Admin SDK is properly configured)
db = firestore.client()
@app.route('/')
def hey():
    return "Hello"

@app.route('/students', methods=['GET'])
def get_students_by_teacher_code():
    """Fetch students by teacherCode."""
    try:
        # Get teacherCode from query parameters
        teacher_code = request.args.get('teacherCode')
        if not teacher_code:
            return jsonify({"error": "teacherCode is required"}), 400

        # Query Firestore to fetch students with the specified teacherCode
        students_ref = db.collection('students').where('teacherCode', '==', teacher_code)
        students = [
            {
                "id": doc.id,  # Firestore document ID
                "student_id": doc.to_dict().get("student_id"),
                "firstName": doc.to_dict().get("firstName"),
                "lastName": doc.to_dict().get("lastName"),
                "email": doc.to_dict().get("email"),
                "grade": doc.to_dict().get("grade"),
                "role": doc.to_dict().get("role")
            }
            for doc in students_ref.stream()
        ]

        # Return the list of students
        return jsonify({"students": students}), 200

    except Exception as e:
        return jsonify({"error": f"Failed to fetch students: {str(e)}"}), 500








client = OpenAI(api_key = "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")

@app.route('/generate-material', methods=['POST'])
def generate_material():
    """Generate and store a single recommendation for the student."""
    try:
        print("Processing request...")

        # Parse incoming JSON data
        data = request.json
        teacher_review = data.get("review")
        student_id = data.get("student_id")

        # Validate input fields
        if not all([teacher_review, student_id]):
            return jsonify({"error": "Fields 'review' and 'student_id' are required"}), 400

        print(f"Teacher Review: {teacher_review}")
        print(f"Student ID: {student_id}")

        # Fetch student details from Firestore
        student_ref = db.collection('students').document(student_id)
        student_data = student_ref.get()

        if not student_data.exists:
            return jsonify({"error": "Student not found"}), 404

        student_info = student_data.to_dict()
        student_name = f"{student_info.get('firstName')} {student_info.get('lastName')}"
        current_level = student_info.get("grade")

        print(f"Student Name: {student_name}, Grade: {current_level}")

        # Generate subject and topics using OpenAI
        subject_inference_response = client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": f"""
                    The teacher has provided the following review about a student:
                    "{teacher_review}"

                    Based on this review, identify:
                    1. The subject (e.g., Mathematics, Science, etc.).
                    2. The specific topic(s) within the subject the student should focus on.

                    Respond in the form of JSON object with the following format:
                    {{
                        "subject": "Subject Name",
                        "topics": ["Topic 1", "Topic 2"]
                    }}

                     Do not include any Markdown formatting or additional text. Respond only with the JSON object.
        
                    """
                }
            ],
            model="gpt-4-turbo",
        )
        # Extract content and parse JSON
        subject_inference_content = subject_inference_response.choices[0].message.content
        print(subject_inference_content, "\n", "got")
        subject_inference_data = json.loads(subject_inference_content)  # Convert JSON string to dictionary
        subject = subject_inference_data["subject"]
        topics = subject_inference_data["topics"]

        print(f"Identified Subject: {subject}, Topics: {topics}")

        # Generate resource recommendations
        recommendations_response = client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": f"""
                    You are an AI educational assistant. A teacher has written the following review for a {current_level} student named {student_name}:
                    "{teacher_review}"

                    The student is learning {subject} and needs help with the following topics: {', '.join(topics)}.

                    Respond in the form of a JSON object containing a list of resources with the following format:
                    {{
                        "resources": [
                            {{"title": "Resource Title", "link": "URL", "description": "Why it's helpful"}},
                            ...
                        ]
                    }}
                    """
                }
            ],
            model="gpt-4-turbo",
        )
        print(recommendations_response, "\n", "first")

        # Extract content and parse JSON
        recommendations_content = recommendations_response.choices[0].message.content
        recommendations_data = json.loads(recommendations_content)  # Convert JSON string to dictionary
        resources = recommendations_data["resources"]

        print(f"Generated Recommendations: {resources}")

        # Update Firestore
        student_ref.update({
            "recommendations": {
                "subject": subject,
                "topics": topics,
                "resources": resources,
                "review": teacher_review
            }
        })

        print("Firestore updated successfully!")

        # Return success response
        return jsonify({
            "message": "Recommendations generated and saved successfully",
            "student_name": student_name,
            "current_level": current_level,
            "subject": subject,
            "topics": topics,
            "recommendations": resources
        }), 200

    except Exception as e:
        print(f"Error occurred: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run()