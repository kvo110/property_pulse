# Property Pulse: Real Estate Application

Property Pulse is a modern real estate marketplace app designed to help users browse through various property listings while offering the ability to save favorites, compare listings, message sellers, etc., all in one place. 

The goal of the app is to provide a smooth, intuitive experience where buyers can explore homes, view detailed listing information, and messaging between buyers and sellers. Sellers will also gain access to create and manage property listings through a simple, mobile-friendly interface

Property Pulse focuses on core marketplace functionality: browsing listings, robust search filtering, in-app messaging, photo galleries, and a straightforward scheduling system.

# AI-Usage Log:
- 11/23/2025, Sunday, 2:38 AM;
    - "Why is my register screen working, but nothing is being sent into the Firebase database?"
        - Changes were made to register_screen.dart, main.dart, login_screen.dart for compatbility with AuthProvider and AuthServices

    - "My google-services.json is not updating after putting in my SHA keys. Can you guide me through the google console services steps to fix this issue"
        - Key issues; "Firebase can't output OAuth entries into JSON if Google Cloud has none"
        - Created credentials for OAuth client ID
        - Obtain SHA keys
        
