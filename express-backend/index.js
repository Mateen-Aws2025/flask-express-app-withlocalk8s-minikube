const express = require('express');
const app = express();
const port = 3000;

app.use(express.json()); // parse JSON body

app.get('/api', (req, res) => {
    res.json({ message: "Hello from Express Backend" });
});

// Updated POST endpoint
app.post('/greet', (req, res) => {
    const { name, age, email, profession, gender } = req.body;

    if (!name) {
        return res.status(400).json({ message: "Name is required" });
    }

    const greeting = `Hello ${name}! 
You are a ${age || "N/A"} years old ${gender || "N/A"} working as ${profession || "N/A"}. 
We will contact you at ${email || "N/A"}.`;

    res.json({ message: greeting });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`Express backend running on port ${port}`);
});
