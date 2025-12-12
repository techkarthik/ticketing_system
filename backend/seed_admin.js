const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

mongoose.connect('mongodb+srv://techkarthikmahalingam:PFXpa8U4GupQNRe0@cluster0.wkrky.mongodb.net/ticketing_system', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('MongoDB Connected for Admin Seeding'))
    .catch(err => console.log(err));

const seedAdmin = async () => {
    try {
        const adminUsername = 'admin';
        const exists = await User.findOne({ username: adminUsername });

        if (exists) {
            console.log('Admin user already exists');
        } else {
            const admin = new User({
                username: 'admin',
                password: 'admin', // Simple password for initial access
                role: 'Admin',
                branch: 'Chennai' // Default branch
            });
            await admin.save();
            console.log('Admin user created successfully');
        }
        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

seedAdmin();
