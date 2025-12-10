const mongoose = require('mongoose');
const User = require('./models/User');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const restoreAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
        console.log('MongoDB Connected');

        const email = 'admin@admin.com';
        const password = 'admin'; // Temporary password
        const branch = 'Head Office';

        // Check if exists
        let admin = await User.findOne({ username: email });
        if (admin) {
            console.log('Admin user already exists. Updating role/branch if needed.');
            admin.role = 'Admin';
            admin.branch = branch;
        } else {
            console.log('Creating new Admin user...');
            admin = new User({
                username: email,
                role: 'Admin',
                branch: branch
            });
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        admin.password = await bcrypt.hash(password, salt);

        await admin.save();
        console.log('Admin User Restored/Created Successfully.');
        console.log(`Email: ${email}`);
        console.log(`Password: ${password}`);

        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

restoreAdmin();
