const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/user'));
app.use('/api/branches', require('./routes/branches'));
app.use('/api/departments', require('./routes/departments'));

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
    .then(() => {
        console.log('Connected to MongoDB');
        seedAdmin();
    })
    .catch((err) => console.error('MongoDB connection error:', err));

// Seed Admin User
const seedAdmin = async () => {
    try {
        const adminEmail = 'techkarthikmahalingam@gmail.com';
        const existingUser = await User.findOne({ username: adminEmail });
        if (!existingUser) {
            const hashedPassword = await bcrypt.hash('admin', 10);
            const newAdmin = new User({
                username: adminEmail,
                password: hashedPassword,
                mobilenumber: '0000000000',
                role: 'SUPERADMIN',
                isadmin: true
            });
            await newAdmin.save();
            console.log('Default Admin user created');
        } else {
            console.log('Admin user already exists');
        }
    } catch (error) {
        console.error('Error seeding admin:', error);
    }
};

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
