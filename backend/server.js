const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Database Connection
mongoose.connect('mongodb+srv://techkarthikmahalingam:PFXpa8U4GupQNRe0@cluster0.wkrky.mongodb.net/ticketing_system', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.log(err));

// Routes (to be added)
app.use('/api/auth', require('./routes/auth'));
app.use('/api/tickets', require('./routes/tickets'));
app.use('/api/master', require('./routes/master'));
app.use('/api/admin', require('./routes/admin'));

app.get('/', (req, res) => {
    res.send('Ticketing System API');
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
