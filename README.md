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

- ChatGPT, 11/26/2025, Wednesday, 5:20 PM:

  - "How can I update my profile display in real time according to my firestore database?"
  - Changes all FutureBuilder related code to StreamBuilder so every new change to our database of profile details causes the UI to refresh itself with the new details.

- ChatGPT, 11/30/2025, Sunday, 3:28 PM:

  - "How to add visual indicators for a horizontal image list?"
  - Generated and explained code for a basic sample of dot indicators.
  - Tweaked and added the basic sample code for the image carousel on the details screen.

- ChatGPT, 12/09/2025, Tueday, 10:40 PM:

  - Is there a dependency I am able to use to allow me the calendar chart to display onto my application?

    - table_calendar: ^3.0.9

  - "Can you help me figure out why the edit detail screen is not keeping the year built value when I go back to edit details like the other data?"

    - add "yearBuilt": data["yearBuilt"], into property_provider.dart

  - "Can you generate me a Log-In screen logo? I want a purple glow with a 3D style visual to it and a gradient auora style background"

    - Generated a logo for the log in screen
    - I had the image regenerated with a better aesthetic visualprop
