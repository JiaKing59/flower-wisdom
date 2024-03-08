const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const spawn = require('child-process-promise').spawn;

const app = express();
app.use(cors());

admin.initializeApp();
const storage = admin.storage().bucket();

// Multer is a middleware to handle HTTP requests with 'multipart/form-data'
const upload = multer({ storage: multer.memoryStorage() });

app.post('/classify', upload.single('image'), async (req, res) => {
  try {
    const imageBuffer = req.file.buffer; // Get the image buffer from the request

    // Upload the image to Firebase Storage
    const fileName = `images/${Date.now()}_${Math.floor(Math.random() * 1000000)}.jpg`;
    const file = storage.file(fileName);
    await file.save(imageBuffer);

    // Call a Python script for image classification (replace 'your_script.py' with your actual script)
    const pythonProcess = spawn('python', ['assets/models/flower_model.pt', fileName]);
    const result = await pythonProcess;

    // Parse the result and send it back to the client
    res.json({ result: result.stdout });
  } catch (error) {
    console.error('Error processing image:', error);
    res.status(500).send('Internal Server Error');
  }
});

exports.api = functions.https.onRequest(app);
